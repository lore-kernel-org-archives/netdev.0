From: Jesper Dangaard Brouer <jdb@comx.dk>
Subject: Re: Marvell 88E609x switch?
Date: Mon, 02 Mar 2009 11:14:45 +0100
Message-ID: <1235988885.30736.44.camel@localhost.localdomain>
References: <20090227144004.GC17040@xi.wantstofly.org>
	 <49A7FEE1.2020705@mlbassoc.com> <20090227145746.GD17040@xi.wantstofly.org>
	 <49A801E6.1040502@mlbassoc.com> <20090227151441.GE17040@xi.wantstofly.org>
	 <49A80606.1040508@mlbassoc.com> <20090227152721.GG17040@xi.wantstofly.org>
	 <49A806C5.1010200@mlbassoc.com> <20090227153102.GH17040@xi.wantstofly.org>
	 <49A80A75.8000101@mlbassoc.com> <20090227155224.GK17040@xi.wantstofly.org>
	 <Pine.LNX.4.64.0902272211260.19905@ask.diku.dk>
	 <49A97669.80309@mlbassoc.com>
	 <Pine.LNX.4.64.0902282004340.9845@ask.diku.dk>
Reply-To: jdb@comx.dk
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: Gary Thomas <gary@mlbassoc.com>,
	Lennert Buytenhek <buytenh@wantstofly.org>,
	netdev <netdev@vger.kernel.org>
To: Jesper Dangaard Brouer <hawk@diku.dk>
Return-path: <netdev-owner@vger.kernel.org>
Received: from lanfw001a.cxnet.dk ([87.72.215.196]:36747 "EHLO
	lanfw001a.cxnet.dk" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754022AbZCBKOt (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 2 Mar 2009 05:14:49 -0500
In-Reply-To: <Pine.LNX.4.64.0902282004340.9845@ask.diku.dk>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sat, 2009-02-28 at 20:10 +0100, Jesper Dangaard Brouer wrote:

> If you will send me the current patches/code, then I'll use some time 
> monday to look at the register settings to see if I can spot the problem, 
> by corrolating with my device driver.

Looking through my old code I found this comment, which indicate that
you should take care of PPU (Phy Polling Unit) state... I had to support
both the 6095 and 6097 chip.

Cite code:

 /*** Setup PHY's ***/
 /*
   Accessing the PHY devices is special.  Direct access to a PHY
   device requires that the PPU (Phy Polling Unit) has been
   disabled.  The 6097 series support indirect access through SMI
   registers (GLOBAL_DEV2 registers 0x18 and 0x19).

   Disabling the PPU _here_ is not necessary, as the drivers R/W
   operation handles disabling the PPU or does indirect SMI access
   (if supported by the chip).

   Notice, that there is a catch with the 6097 SMI access, as it
   requires the PPU to be enabled (or else it will returns
   0xFFFF).
 */

Thus, you should make sure that the PPU is disabled during setup of the
PHYs.

Well, I don't think this will solve all your issues... I'm still looking
for the missing link...

-- 
Med venlig hilsen / Best regards
  Jesper Brouer
  ComX Networks A/S
  Linux Network developer
  Cand. Scient Datalog / MSc.
  Author of http://adsl-optimizer.dk
  LinkedIn: http://www.linkedin.com/in/brouer
