From: Alexey Kuznetsov <kuznet@ms2.inr.ac.ru>
Subject: Re: [PATCH RESEND] ip_gre: sendto/recvfrom NBMA address
Date: Wed, 24 Oct 2007 00:20:36 +0400
Message-ID: <20071023202036.GA12066@ms2.inr.ac.ru>
References: <471E05BD.7040407@iki.fi> <471E0638.9040405@trash.net> <471E19E5.5040509@iki.fi>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Patrick McHardy <kaber@trash.net>, davem@davemloft.net,
	netdev@vger.kernel.org
To: Timo Ter?s <timo.teras@iki.fi>
Return-path: <netdev-owner@vger.kernel.org>
Received: from minus.inr.ac.ru ([194.67.69.97]:36855 "HELO ms2.inr.ac.ru"
	rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with SMTP
	id S1752309AbXJWUUr (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 23 Oct 2007 16:20:47 -0400
Content-Disposition: inline
In-Reply-To: <471E19E5.5040509@iki.fi>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hello!

Me wrote:

> Ack. This is good idea.
> 
> Frankly, I was sure ip_gre worked in this way all these years.
> I do not remember any reasons why it was crippled.
> 
> The only dubious case is when next hop is set using routing tables.
> But code in ipgre_tunnel_xmit() is ready to accept this situation,
> it checks for zero destination address and fixes it when it is able to.

Nevertheless, it does not work.

The reason is that NOARP arp entries on device with initialized
hard_header are initialized not to all zeros, but to dev->dev_addr.
So that, netxthop from routing tables is ignored and all gre packets
are lost in loopback. Not good.

The problem can be ignored. I am even not sure that someone uses
this feature. Actually, it was not recommended in documentation.

Alternatively, arp.c can be changed to generate 0 addresses instead
of dev->dev_addr. Normally it is equally good, but I am not sure
about possible side effects.

Another thoughts?

Alexey
