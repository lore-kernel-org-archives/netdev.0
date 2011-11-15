From: Baruch Siach <baruch@tkos.co.il>
Subject: Re: [PATCH] net: fsl_pq_mdio: fix non tbi phy access
Date: Tue, 15 Nov 2011 17:44:24 +0200
Message-ID: <20111115154423.GA26481@sapphire.tkos.co.il>
References: <b693b45a689d42b60a8a9e29dcdd2fb27e20df82.1321251618.git.baruch@tkos.co.il>
 <C89A2124-7AB4-45B6-ACD1-8C5936027531@freescale.com>
 <20111115051713.GA4052@sapphire.tkos.co.il>
 <74631EEB-F6F8-4969-AD05-81DEAFB0EAB4@freescale.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: "netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	linuxppc-dev@lists.ozlabs.org
To: Andy Fleming <afleming@freescale.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from tango.tkos.co.il ([62.219.50.35]:54301 "EHLO tango.tkos.co.il"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1756349Ab1KOPov (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 15 Nov 2011 10:44:51 -0500
Content-Disposition: inline
In-Reply-To: <74631EEB-F6F8-4969-AD05-81DEAFB0EAB4@freescale.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi Andy,

On Tue, Nov 15, 2011 at 09:06:03AM -0600, Andy Fleming wrote:
> On Nov 14, 2011, at 11:17 PM, Baruch Siach wrote:
> > On Mon, Nov 14, 2011 at 09:04:47PM +0000, Fleming Andy-AFLEMING wrote:

[snip]

> >> And looking at the p1010si.dtsi, I see that it's automatically there for 
> >> you.
> >> 
> >> How were you breaking?
> > 
> > Adding linuxppc to Cc.
> > 
> > My board is P1011 based, the single core version of P1020, not P1010. In 
> > p1020si.dtsi I see no tbi node. In p1020rdb.dts I see a tbi node but only for 
> > mdio@25000, not mdio@24000, which is what I'm using.
> > 
> > Am I missing something?
> 
> Well, that's a bug. In truth, the silicon dtsi trees should not have tbi 
> nodes, as that's highly machine-specific. The p1020rdb is apparently relying 
> on the old behavior, which is broken, and due to the fact that the first 
> ethernet interface doesn't *use* the TBI PHY.
> 
> You should add this to your board tree:
> 
>                 mdio@24000 {
> 
>                         tbi0: tbi-phy@11 {
>                                 reg = <0x11>;
>                                 device_type = "tbi-phy";
>                         };
>                 };
> 
> And add the PHYs you use, as well as set reg (and the value after the "@") 
> to something that makes sense for your board.

Thanks for your detailed explanation and prompt response. I've added a tbi 
node, dropped my patch, and now my board works as expected.

> I am going to go right now, and add tbi nodes for all of the Freescale 
> platforms. I will also modify the fsl_pq_mdio code to be more explicit about 
> its reason for failure.

Please Cc me on these.

Thanks,
baruch

-- 
                                                     ~. .~   Tk Open Systems
=}------------------------------------------------ooO--U--Ooo------------{=
   - baruch@tkos.co.il - tel: +972.2.679.5364, http://www.tkos.co.il -
