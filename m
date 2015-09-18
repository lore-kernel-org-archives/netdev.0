From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH v2] solos-pci: Increase headroom on received packets
Date: Thu, 17 Sep 2015 21:29:21 -0700 (PDT)
Message-ID: <20150917.212921.1620012798738986807.davem@davemloft.net>
References: <1442399145.131189.56.camel@infradead.org>
	<1442400813.4116.48.camel@edumazet-glaptop2.roam.corp.google.com>
	<1442403300.131189.73.camel@infradead.org>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=iso-2022-jp
Content-Transfer-Encoding: 7bit
Cc: eric.dumazet@gmail.com, netdev@vger.kernel.org, simon@fire.lp0.eu,
	guy@traverse.com.au, linux-atm-general@lists.sourceforge.net
To: dwmw2@infradead.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:48320 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752351AbbIRE3W (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 18 Sep 2015 00:29:22 -0400
In-Reply-To: <1442403300.131189.73.camel@infradead.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: David Woodhouse <dwmw2@infradead.org>
Date: Wed, 16 Sep 2015 12:35:00 +0100

> A comment in include/linux/skbuff.h says that:
> 
>  * Various parts of the networking layer expect at least 32 bytes of
>  * headroom, you should not reduce this.
> 
> This was demonstrated by a panic when handling fragmented IPv6 packets:
> http://marc.info/?l=linux-netdev&m=144236093519172&w=2
> 
> It's not entirely clear if that comment is still valid ― and if it is,
> perhaps netif_rx() ought to be enforcing it with a warning.
> 
> But either way, it is rather stupid from a performance point of view
> for us to be receiving packets into a buffer which doesn't have enough
> room to prepend an Ethernet header ― it means that *every* incoming
> packet is going to be need to be reallocated. So let's fix that.
> 
> Signed-off-by: David Woodhouse <David.Woodhouse@intel.com>

Applied, thanks David.
