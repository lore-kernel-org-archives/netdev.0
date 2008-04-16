From: Benjamin Herrenschmidt <benh@kernel.crashing.org>
Subject: Re: Phy read timeout in ibm_new_emac driver
Date: Wed, 16 Apr 2008 22:09:51 +1000
Message-ID: <1208347791.6958.279.camel@pasglop>
References: <6a6049b80804160349q42120b4bs1c0db49ea5ad055d@mail.gmail.com>
Reply-To: benh@kernel.crashing.org
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, ppc-dev <linuxppc-dev@ozlabs.org>
To: M B <super.firetwister@googlemail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from gate.crashing.org ([63.228.1.57]:54742 "EHLO gate.crashing.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1759730AbYDPMKP (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 16 Apr 2008 08:10:15 -0400
In-Reply-To: <6a6049b80804160349q42120b4bs1c0db49ea5ad055d@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


> My Micrel/Kendin KSZ8721BT on my ppc405EP board needs one us longer to
> finish. I was able to reproduce this all the time. So I wonder if the
> timeout of 100us is defined by the MII standard, or by the author of
> the driver?
> If it's a standard I've still a bad feeling if we just correct the
> timeout to 100us, maybe 110 should be fine. If it's not defined by the
> standard, I would add 50% to the timeout. It won't slow down other
> phys, but a scan on the phy bus might get slowed down.
> Same applies for __emac_mdio_write.
> 
> Oh and we could save a us by putting the udelay(1) after the if section ;-)

Increasing the timeout is fine. In fact, EMAC specifically can sleep in
it's MDIO access routines (it already takes mutexes) so maybe a good
option here is to use longer sleeping delays and less iterations.

Somebody knows off hand what the standard says the timeout should be ? I
can check that tomorrow, I don't have it at hand right now and it's
getting late but feel free to beat me to it :-) 

Cheers,
Ben.

