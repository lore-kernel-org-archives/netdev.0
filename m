From: Kristian Larsson <kristian@spritelink.net>
Subject: Re: pktgen IP address stepping
Date: Thu, 16 Dec 2010 21:34:30 +0100
Message-ID: <20101216203430.GE8404@spritelink.se>
References: <20101216172800.GA8404@spritelink.se>
 <1292522532.29894.33.camel@Joe-Laptop>
 <20101216183004.GC8404@spritelink.se>
 <1292527132.29894.52.camel@Joe-Laptop>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: "David S. Miller" <davem@davemloft.net>, netdev@vger.kernel.org
To: Joe Perches <joe@perches.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from Mail2.SpriteLink.NET ([195.182.5.83]:49630 "EHLO
	Mail2.SpriteLink.NET" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756511Ab0LPUgJ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 16 Dec 2010 15:36:09 -0500
Content-Disposition: inline
In-Reply-To: <1292527132.29894.52.camel@Joe-Laptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, Dec 16, 2010 at 11:18:52AM -0800, Joe Perches wrote:
> On Thu, 2010-12-16 at 19:30 +0100, Kristian Larsson wrote:
> > > I suggest using actual ipv4 addresses (and ipv6 if you ever
> > > need it) as increment/mask.
> > Not sure I follow you, should the stepping be specified as
> > 0.0.0.213 if I would like to increase with 213 or 0.0.255.255 if
> > I want to increase by a /16 at a time?
> 
> More like:
> 
> Initial IPv4 address:	0.0.0.1
> Step:			0.1.0.0
> Mask:			127.0.0.1
> 
> addr = (addr + step) & mask;
> 
> Cycles through all /16's below 128

Which I guess is doable with the patch using these options;
(dst|src)_min 0.0.0.1
(dst|src)_max 128.0.0.0
(dst|src)_step 65535

but you want (dst|src)_step to be specified using dot-quad
instead of an integer?

   Kristian.

-- 
Kristian Larsson                                        KLL-RIPE
+46 704 264511			              kll@spritelink.net
