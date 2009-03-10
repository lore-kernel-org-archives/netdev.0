From: Gary Thomas <gary@mlbassoc.com>
Subject: Re: Marvell 88E609x switch?
Date: Tue, 10 Mar 2009 05:20:30 -0600
Message-ID: <49B64CFE.2000805@mlbassoc.com>
References: <20090227151441.GE17040@xi.wantstofly.org> <49A80606.1040508@mlbassoc.com> <20090227152721.GG17040@xi.wantstofly.org> <49A806C5.1010200@mlbassoc.com> <20090227153102.GH17040@xi.wantstofly.org> <49A80A75.8000101@mlbassoc.com> <20090227155224.GK17040@xi.wantstofly.org> <Pine.LNX.4.64.0902272211260.19905@ask.diku.dk> <20090227222802.GZ17040@xi.wantstofly.org> <1235991382.30736.62.camel@localhost.localdomain> <20090310093915.GK4738@xi.wantstofly.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: Jesper Dangaard Brouer <jdb@comx.dk>,
	Jesper Dangaard Brouer <hawk@diku.dk>,
	netdev <netdev@vger.kernel.org>
To: Lennert Buytenhek <buytenh@wantstofly.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from 137-67-76-76.skybeam.com ([76.76.67.137]:4601 "EHLO
	mail.chez-thomas.org" rhost-flags-OK-FAIL-OK-OK) by vger.kernel.org
	with ESMTP id S1751941AbZCJLjf (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 10 Mar 2009 07:39:35 -0400
In-Reply-To: <20090310093915.GK4738@xi.wantstofly.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Lennert Buytenhek wrote:
> On Mon, Mar 02, 2009 at 11:56:22AM +0100, Jesper Dangaard Brouer wrote:
> 
>>> The main conclusion so far is that this write (net/dsa/mv88e6131.c):
>>>
>>> 	/*
>>> 	 * MAC Forcing register: don't force link, speed, duplex
>>> 	 * or flow control state to any particular values.
>>> 	 */
>>> 	REG_WRITE(addr, 0x01, 0x0003);
>> This sort of enables auto-detection of speed.
>>
>>> isn't correct on ports that can either be CPU ports or external ports.
>> For external ports I had to enabled the PPU to allow the external PHYs
>> to negotiate.
> 
> The PPU should be re-enabled 10ms after the last MII access.
> 
> 
>> Also, on external PHYs ports 8 and 9, I write 0x0403 not 0x0003 (to
>> register 0x1, PCS Control Register).  Which also enables inband
>> auto-negotiation, but I'm not sure this is necessary.
> 
> Not sure whether it is.  Gary?
> 

I'm not sure either.  On my system, these ports are SERDES used to
cascade switches.  When we get that part working, we may learn if
these bits are important.

> 
>>> Forcing the link up on the CPU port helps somewhat, but things aren't
>>> 100% working yet.
>> On the CPU port I force link-up and force speed+duplex setting.  I only
>> got 100Mbit/s to the CPU port...
> 
> I suppose the cpu port speed should be made into a platform data
> config option in case there's only a 100 Mb/s link on a gigabit
> capable switch?

I agree.

-- 
------------------------------------------------------------
Gary Thomas                 |  Consulting for the
MLB Associates              |    Embedded world
------------------------------------------------------------
