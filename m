From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net] vrf: fix double free and memory corruption on
 register_netdevice failure
Date: Mon, 23 Nov 2015 17:53:37 -0500 (EST)
Message-ID: <20151123.175337.380614330138907039.davem@davemloft.net>
References: <1448131579-20525-1-git-send-email-razor@blackwall.org>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, dsa@cumulusnetworks.com,
	shm@cumulusnetworks.com, nikolay@cumulusnetworks.com
To: razor@blackwall.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:57155 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751104AbbKWWxn (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 23 Nov 2015 17:53:43 -0500
In-Reply-To: <1448131579-20525-1-git-send-email-razor@blackwall.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Nikolay Aleksandrov <razor@blackwall.org>
Date: Sat, 21 Nov 2015 19:46:19 +0100

> From: Nikolay Aleksandrov <nikolay@cumulusnetworks.com>
> 
> When vrf's ->newlink is called, if register_netdevice() fails then it
> does free_netdev(), but that's also done by rtnl_newlink() so a second
> free happens and memory gets corrupted, to reproduce execute the
> following line a couple of times (1 - 5 usually is enough):
> $ for i in `seq 1 5`; do ip link add vrf: type vrf table 1; done;
> This works because we fail in register_netdevice() because of the wrong
> name "vrf:".
> 
> And here's a trace of one crash:
 ...
> Fixes: 193125dbd8eb ("net: Introduce VRF device driver")
> Signed-off-by: Nikolay Aleksandrov <nikolay@cumulusnetworks.com>

Applied and queued up for -stable, thanks.
