From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next] ila: Fix checksum neutral mapping
Date: Wed, 15 Jun 2016 21:44:02 -0700 (PDT)
Message-ID: <20160615.214402.1975081304384066829.davem@davemloft.net>
References: <1465946955-3088294-1-git-send-email-tom@herbertland.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, kernel-team@fb.com, haoxuany@fb.com
To: tom@herbertland.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:36512 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750895AbcFPEoE (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 16 Jun 2016 00:44:04 -0400
In-Reply-To: <1465946955-3088294-1-git-send-email-tom@herbertland.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Tom Herbert <tom@herbertland.com>
Date: Tue, 14 Jun 2016 16:29:15 -0700

> The algorithm for checksum neutral mapping is incorrect. This problem
> was being hidden since we were previously always performing checksum
> offload on the translated addresses and only with IPv6 HW csum.
> Enabling an ILA router shows the issue.
> 
> Corrected algorithm:
> 
> old_loc is the original locator in the packet, new_loc is the value
> to overwrite with and is found in the lookup table. old_flag is
> the old flag value (zero of CSUM_NEUTRAL_FLAG) and new_flag is
> then (old_flag ^ CSUM_NEUTRAL_FLAG) & CSUM_NEUTRAL_FLAG.
> 
> Need SUM(new_id + new_flag + diff) == SUM(old_id + old_flag) for
> checksum neutral translation.
> 
> Solving for diff gives:
> 
> diff = (old_id - new_id) + (old_flag - new_flag)
> 
> compute_csum_diff8(new_id, old_id) gives old_id - new_id
> 
> If old_flag is set
>    old_flag - new_flag = old_flag = CSUM_NEUTRAL_FLAG
> Else
>    old_flag - new_flag = -new_flag = ~CSUM_NEUTRAL_FLAG
> 
> Tested:
>   - Implemented a user space program that creates random addresses
>     and random locators to overwrite. Compares the checksum over
>     the address before and after translation (must always be equal)
>   - Enabled ILA router and showed proper operation.
> 
> Signed-off-by: Tom Herbert <tom@herbertland.com>

Applied.
