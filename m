From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH v2] net/hyperv: fix the issue that large packets be
 dropped under bridge
Date: Thu, 02 Feb 2012 14:22:08 -0500 (EST)
Message-ID: <20120202.142208.1717482462537460304.davem@davemloft.net>
References: <CAPgLHd-Z5azR2_5O+GkdjBF45k8YY1te0huMo75pFULGHG+izg@mail.gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: haiyangz@microsoft.com, kys@microsoft.com, netdev@vger.kernel.org
To: weiyj.lk@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([198.137.202.13]:44740 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932629Ab2BBTWM (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 2 Feb 2012 14:22:12 -0500
In-Reply-To: <CAPgLHd-Z5azR2_5O+GkdjBF45k8YY1te0huMo75pFULGHG+izg@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Wei Yongjun <weiyj.lk@gmail.com>
Date: Thu, 2 Feb 2012 14:17:23 +0800

> From: Wei Yongjun <yongjun_wei@trendmicro.com.cn>
> 
> The packets with size larger than 1452 will be dropped by bridge
> which with two hyperv netdevice ports. This cause by hyperv netvsc
> driver always copy the trailer padding to the data packet, and then
> the skb received from netdevice may include wrong skb->len (20 bytes
> larger than the real size normally). The captured packet may like
> this:
> 
>   Ethernet II, Src: Microsof_00:00:07 (00:15:5d:00:00:07),
>                Dst: HewlettP_00:00:4e (00:1f:29:00:00:4e)
>     Destination: HewlettP_e6:00:4e (00:1f:29:00:00:4e)
>     Source: Microsof_f6:6d:07 (00:15:5d:f6:6d:07)
>     Type: IP (0x0800)
>     Trailer: 1415161718191A1B1C1D1E1F20212223
>     Frame check sequence: 0x24252627 [incorrect, should be 0x7c2e5a5e]
> 
> The following command help to reproduction it, and the ping ICMP
> packets will be dropped by bridge.
>   $ ping ip -s 1453
> 
> This patch fixed it by removing the trailer padding from the data
> packet.
> 
> Signed-off-by: Wei Yongjun <yongjun_wei@trendmicro.com.cn>

Applied.
