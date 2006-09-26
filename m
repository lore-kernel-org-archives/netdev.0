From: Michael Buesch <mb@bu3sch.de>
Subject: Re: [patch 09/11] b44: fix eeprom endianess issue
Date: Tue, 26 Sep 2006 18:20:46 +0200
Message-ID: <200609261820.46308.mb@bu3sch.de>
References: <200609252339.k8PNdNE4002654@shell0.pdx.osdl.net> <200609261804.37422.mb@bu3sch.de> <4519508A.4010004@garzik.org>
Mime-Version: 1.0
Content-Type: text/plain;
  charset="iso-8859-1"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, Gary Zambrano <zambrano@broadcom.com>,
	akpm@osdl.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from static-ip-62-75-166-246.inaddr.intergenia.de ([62.75.166.246]:50917
	"EHLO bu3sch.de") by vger.kernel.org with ESMTP id S932348AbWIZQWV
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 26 Sep 2006 12:22:21 -0400
To: Jeff Garzik <jeff@garzik.org>
In-Reply-To: <4519508A.4010004@garzik.org>
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Tuesday 26 September 2006 18:08, Jeff Garzik wrote:
> Michael Buesch wrote:
> > No it isn't. There are lots of other parameters in the ssb SPROM.
> > And most of them are _not_ in bigendian.
> > I think we also read the PHYport or something in b44.
> > See bcm43xx or the ssb module for the rest of the values.
> > 
> > Returning a SPROM bytearray as BABABABA is just plain wrong.
> > It must always be ABABABAB, because we expect this. This patch
> > encures ABABAB order on every platform. The interpret function
> > must not know on which platform we are, as it's just interpreting
> > the _byte_ array (byte array, without any endian semantics).
> > 
> > This _fixes_ a bug (In the correct way, so that future bugs will
> > not appear)
> 
> 
> It's amusing to call something incorrect, when my suggested solution 
> will interpret the correct values from b44_get_invariants() simply by 
> changing the b44_get_invariants() code from reading BABABABA to ABABABAB.

Jeff, I officially do not care about b44 any longer now.
I am not going to waste my time now.
If you don't want this patch, stay with current buggy code. It's OK
to me.

Maybe the following line of code from get_invariants explains best
why my fix is the correct one:


	bp->phy_addr = eeprom[90] & 0x1f;

If you don't swap to LE in b44_read_eeprom this _won't_ lead
to the expected result of getting byte 90 of the SPROM (on BE archs).

Wanna have code like this?

#ifdef BIG_ENDIAN
	bp->phy_addr = eeprom[91] & 0x1f;
#else
	bp->phy_addr = eeprom[90] & 0x1f;
#endif


Or maybe

	bp->phy_addr = ((u16 *)eeprom)[90/2] & 0x1f;

I don't really think so.

-- 
Greetings Michael.
