From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next] net: Fix race condition in store_rps_map
Date: Fri, 07 Aug 2015 15:57:26 -0700 (PDT)
Message-ID: <20150807.155726.1475197462744121004.davem@davemloft.net>
References: <1438792767-76704-1-git-send-email-tom@herbertland.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, kernel-team@fb.com
To: tom@herbertland.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:51560 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1946356AbbHGW51 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 7 Aug 2015 18:57:27 -0400
In-Reply-To: <1438792767-76704-1-git-send-email-tom@herbertland.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Tom Herbert <tom@herbertland.com>
Date: Wed, 5 Aug 2015 09:39:27 -0700

> There is a race condition in store_rps_map that allows jump label
> count in rps_needed to go below zero. This can happen when
> concurrently attempting to set and a clear map.
> 
> Scenario:
> 
> 1. rps_needed count is zero
> 2. New map is assigned by setting thread, but rps_needed count _not_ yet
>    incremented (rps_needed count still zero)
> 2. Map is cleared by second thread, old_map set to that just assigned
> 3. Second thread performs static_key_slow_dec, rps_needed count now goes
>    negative
> 
> Fix is to increment or decrement rps_needed under the spinlock.
> 
> Signed-off-by: Tom Herbert <tom@herbertland.com>

Applied, thanks Tom.
