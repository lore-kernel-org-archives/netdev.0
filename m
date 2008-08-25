From: Ron Mercer <ron.mercer@qlogic.com>
Subject: Re: [RFC] New Qlogic 10Gb Ethernet driver for 2.6.28
Date: Mon, 25 Aug 2008 10:01:48 -0700
Message-ID: <20080825170148.GA31059@susedev.qlogic.org>
References: <48AE8549.6090705@garzik.org> <20080822.024252.193704871.davem@davemloft.net> <20080822174626.GC2551@susedev.qlogic.org> <20080822.144343.231567307.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: jeff@garzik.org, Linux-Driver@qlogic.com, netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from avexch1.qlogic.com ([198.70.193.115]:17693 "EHLO
	avexch1.qlogic.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753449AbYHYRCa (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 25 Aug 2008 13:02:30 -0400
Content-Disposition: inline
In-Reply-To: <20080822.144343.231567307.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, Aug 22, 2008 at 02:43:43PM -0700, David Miller wrote:
> From: Ron Mercer <ron.mercer@qlogic.com>
> Date: Fri, 22 Aug 2008 10:46:26 -0700
> 
> > On Fri, Aug 22, 2008 at 02:42:52AM -0700, David Miller wrote:
> > > I also notice that this driver does not do:
> > > 
> > > 	skb_reserve(skb, NET_IP_ALIGN);
> > > 
> > > on RX packets to get the IP headers properly 4-byte aligned aligned
> > > after the ethernet header.
> > 
> > The chip currenly has problems with 2-byte aligned receive buffers.
> > It will be fixed in the next turn.
> 
> If the chip cannot handle this, you will need to copy into a properly
> aligned buffer.
> 
> Otherwise some RISC platforms will take unaligned access traps, which
> run extremely slowly, when 32-bit and larger members of the protocol
> headers are read by the networking stack.

I see your point.  I will add the re-alignment but would like to jump
over it for platforms that don't need it.  Is there a list somewhere of
the RISC platforms that take a trap on unaligned accesses?  Or better
yet, a list of those that don't?


