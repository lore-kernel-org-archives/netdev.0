From: David Miller <davem@davemloft.net>
Subject: Re: [RFC] New Qlogic 10Gb Ethernet driver for 2.6.28
Date: Fri, 22 Aug 2008 14:43:43 -0700 (PDT)
Message-ID: <20080822.144343.231567307.davem@davemloft.net>
References: <48AE8549.6090705@garzik.org>
	<20080822.024252.193704871.davem@davemloft.net>
	<20080822174626.GC2551@susedev.qlogic.org>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: jeff@garzik.org, Linux-Driver@qlogic.com, netdev@vger.kernel.org
To: ron.mercer@qlogic.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:33000
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1754545AbYHVVno (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 22 Aug 2008 17:43:44 -0400
In-Reply-To: <20080822174626.GC2551@susedev.qlogic.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Ron Mercer <ron.mercer@qlogic.com>
Date: Fri, 22 Aug 2008 10:46:26 -0700

> On Fri, Aug 22, 2008 at 02:42:52AM -0700, David Miller wrote:
> > I also notice that this driver does not do:
> > 
> > 	skb_reserve(skb, NET_IP_ALIGN);
> > 
> > on RX packets to get the IP headers properly 4-byte aligned aligned
> > after the ethernet header.
> 
> The chip currenly has problems with 2-byte aligned receive buffers.
> It will be fixed in the next turn.

If the chip cannot handle this, you will need to copy into a properly
aligned buffer.

Otherwise some RISC platforms will take unaligned access traps, which
run extremely slowly, when 32-bit and larger members of the protocol
headers are read by the networking stack.
