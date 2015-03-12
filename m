From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] net: sysctl_net_core: check SNDBUF and RCVBUF for min
 length
Date: Wed, 11 Mar 2015 21:25:45 -0400 (EDT)
Message-ID: <20150311.212545.1595223451693204245.davem@davemloft.net>
References: <1426073357-6211-1-git-send-email-alexey.kodanev@oracle.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	vasily.isaenko@oracle.com
To: alexey.kodanev@oracle.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:54534 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751415AbbCLBZr (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 11 Mar 2015 21:25:47 -0400
In-Reply-To: <1426073357-6211-1-git-send-email-alexey.kodanev@oracle.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Alexey Kodanev <alexey.kodanev@oracle.com>
Date: Wed, 11 Mar 2015 14:29:17 +0300

> sysctl has sysctl.net.core.rmem_*/wmem_* parameters which can be
> set to incorrect values. Given that 'struct sk_buff' allocates from
> rcvbuf, incorrectly set buffer length could result to memory
> allocation failures. For example, set them as follows:
> 
>     # sysctl net.core.rmem_default=64
>       net.core.wmem_default = 64
>     # sysctl net.core.wmem_default=64
>       net.core.wmem_default = 64
>     # ping localhost -s 1024 -i 0 > /dev/null
> 
> This could result to the following failure:
 ...
> Signed-off-by: Alexey Kodanev <alexey.kodanev@oracle.com>

Applied, but someone needs to followup with fixes to AF_UNIX etc.
