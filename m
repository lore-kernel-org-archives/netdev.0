From: Simon Horman <horms@verge.net.au>
Subject: Re: [PATCH] sh_eth: add wake-on-lan support via magic packet
Date: Thu, 8 Dec 2016 16:31:44 +0100
Message-ID: <20161208153142.GA31836@verge.net.au>
References: <20161207162843.4731-1-niklas.soderlund+renesas@ragnatech.se>
 <CAMuHMdVK1DtJMajqD-eZ82QSP2ZRozwaR4zNc0ae1YT21Exq0w@mail.gmail.com>
 <20161208071620.GG21834@bigcity.dyn.berto.se>
 <20161208132241.GA7150@verge.net.au>
 <20161208150105.GI21834@bigcity.dyn.berto.se>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 8bit
Cc: Geert Uytterhoeven <geert@linux-m68k.org>,
        Sergei Shtylyov <sergei.shtylyov@cogentembedded.com>,
        "netdev@vger.kernel.org" <netdev@vger.kernel.org>,
        Linux-Renesas <linux-renesas-soc@vger.kernel.org>
To: Niklas =?utf-8?Q?S=C3=B6derlund?= <niklas.soderlund@ragnatech.se>
Return-path: <netdev-owner@vger.kernel.org>
Received: from kirsty.vergenet.net ([202.4.237.240]:34683 "EHLO
        kirsty.vergenet.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1752328AbcLHPcU (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 8 Dec 2016 10:32:20 -0500
Content-Disposition: inline
In-Reply-To: <20161208150105.GI21834@bigcity.dyn.berto.se>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, Dec 08, 2016 at 04:01:05PM +0100, Niklas Söderlund wrote:
> Hi Simon,
> 
> Thanks for your feedback.
> 
> On 2016-12-08 14:22:44 +0100, Simon Horman wrote:
> 
> <snip>
> 
> > > > 
> > > > > --- a/drivers/net/ethernet/renesas/sh_eth.h
> > > > > +++ b/drivers/net/ethernet/renesas/sh_eth.h
> > > > > @@ -493,6 +493,7 @@ struct sh_eth_cpu_data {
> > > > >         unsigned shift_rd0:1;   /* shift Rx descriptor word 0 right by 16 */
> > > > >         unsigned rmiimode:1;    /* EtherC has RMIIMODE register */
> > > > >         unsigned rtrate:1;      /* EtherC has RTRATE register */
> > > > > +       unsigned magic:1;       /* EtherC have PMDE in ECMR and MPDIP in ECSIPR */
> > > > 
> > > > Instead of adding a new flag, perhaps you can just check for the ECSR_MPD flag
> > > > in ecsr_value?
> > > 
> > > I briefly considered this but decided against it since I do not have 
> > > documentation for all versions of the device and no way to test it. You 
> > > tested and confirmed functionality on r8a7740, which leaves:
> > > 
> > > - sh7734-gether
> > > - sh7763-gether
> > > - sh7757-gether
> > > 
> > > To figure out if they support MagicPacket in the same fashion as r8a7740 
> > > and r8a779x. If anyone have access to documentation or hardware to 
> > > confirm this I be more then happy to get rid of the magic flag in favor 
> > > och checking for ECSR_MPD in ecsr_value.
> > 
> > Perhaps documentation can be found but if not I wonder if we can use some
> > other mechanism to blacklist SoC which we are unsure about.
> > 
> > From my POV it would be very nice if things just worked™ on SoCs where
> > the feature has been verified.
> 
> I agree, I will follow Sergies advice and Geerts testing to enable Gen2 
> family and r8a7740/armadillo in two separate patches. Then if we later 
> can confirm it works on other models we can enable them in separate 
> patches by setting the magic flag in struct sh_eth_cpu_data for those 
> models. Do you agree this is the best way to handle this?

Yes, I think that is reasonable.
