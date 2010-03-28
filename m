From: Al Viro <viro@ZenIV.linux.org.uk>
Subject: Re: [PATCH] r8169: fix broken register writes
Date: Sun, 28 Mar 2010 23:19:24 +0100
Message-ID: <20100328221924.GG30031@ZenIV.linux.org.uk>
References: <4BAE6C92.2060801@iki.fi>
 <20100327211133.GA3624@electric-eye.fr.zoreil.com>
 <1269732054.8653.155.camel@localhost>
 <20100327.163005.28815553.davem@davemloft.net>
 <20100328003143.GA8501@electric-eye.fr.zoreil.com>
 <1269737245.8653.162.camel@localhost>
 <20100328212858.GA4220@electric-eye.fr.zoreil.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Ben Hutchings <ben@decadent.org.uk>,
	David Miller <davem@davemloft.net>, timo.teras@iki.fi,
	ivecera@redhat.com, netdev@vger.kernel.org
To: Fran?ois Romieu <romieu@fr.zoreil.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from zeniv.linux.org.uk ([195.92.253.2]:44105 "EHLO
	ZenIV.linux.org.uk" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755285Ab0C1WTc (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 28 Mar 2010 18:19:32 -0400
Content-Disposition: inline
In-Reply-To: <20100328212858.GA4220@electric-eye.fr.zoreil.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sun, Mar 28, 2010 at 11:28:58PM +0200, Fran?ois Romieu wrote:
> Ben Hutchings <ben@decadent.org.uk> :
> [...]
> > Thanks Fran?ois.  Which hardware have you tested this on so far ?
> 
> 10ec:8169 (rev 10) / RTL8169sb/8110sb / XID 10000000
> 
> Timo's is a 10ec:8167 / RTL8169sc/8110sc / XID 18000000. He only tested
> the MAC[04] part.

FWIW, XID18000000 here (J7F4) loses MAC4 on shutdown; hadn't tested the patch
yet.  2.6.26 (on that box) and 2.6.31 (on identical mb) work, 2.6.33 doesn't.
I suspect that bisect would lead to commit cc098dc70 (i.e. the place where we
started to set address on shutdown).  One more data point: ifconfig hw ether
done under 2.6.26 did restore the address.  And that's the same function,
isn't it?

Another interesting bit: unlike the older kernel, grep for eth0 in .33 dmesg

eth0: RTL8169sc/8110sc at 0xf87fc000, 00:30:18:a4:65:89, XID 18000000 IRQ 18
r8169: eth0: link down
ADDRCONF(NETDEV_UP): eth0: link is not ready
r8169: eth0: link up
ADDRCONF(NETDEV_CHANGE): eth0: link becomes ready

where with .26 (with the same userland) had

eth0: RTL8169sc/8110sc at 0xf87fc000, 00:30:18:a4:65:89, XID 18000000 IRQ 18
r8169: eth0: link up
ADDRCONF(NETDEV_CHANGE): eth0: link becomes ready

Same for .31 on another box, modulo different address there...
