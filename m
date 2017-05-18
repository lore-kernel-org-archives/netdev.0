From: Simon Horman <horms@verge.net.au>
Subject: Re: [PATCH] ravb: add wake-on-lan support via magic packet
Date: Thu, 18 May 2017 15:40:43 +0200
Message-ID: <20170518134043.GC9440@verge.net.au>
References: <20170512125853.GH31437@bigcity.dyn.berto.se>
 <20170512143242.GA13939@bigcity.dyn.berto.se>
 <CAMuHMdU+uiiZfh5u+tL_bVJinhP-c0_iF4ZQh8=9NHN+aqUs=Q@mail.gmail.com>
 <20170512211222.GI31437@bigcity.dyn.berto.se>
 <CAMuHMdWZ8XLX0Zu0D54Ex+3RaFNm_fJyFQvyo+qz10HpB2nGqQ@mail.gmail.com>
 <20170516090214.GA30768@bigcity.dyn.berto.se>
 <CAMuHMdVkitTgVmUrPu5+z2JwnwHop4bJ5anMq1SmCeFfV=OxQg@mail.gmail.com>
 <20170516110145.GA27247@verge.net.au>
 <CAMuHMdV9fjYvV=axAkp5WQbXTbZSXg5+g=HNubzPYSRwmStiWg@mail.gmail.com>
 <20170516121604.GF15597@bigcity.dyn.berto.se>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 8bit
Cc: Geert Uytterhoeven <geert@linux-m68k.org>,
        Sergei Shtylyov <sergei.shtylyov@cogentembedded.com>,
        "netdev@vger.kernel.org" <netdev@vger.kernel.org>,
        Linux-Renesas <linux-renesas-soc@vger.kernel.org>
To: Niklas =?utf-8?Q?S=C3=B6derlund?= <niklas.soderlund@ragnatech.se>
Return-path: <netdev-owner@vger.kernel.org>
Received: from kirsty.vergenet.net ([202.4.237.240]:36973 "EHLO
        kirsty.vergenet.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1754282AbdERNku (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 18 May 2017 09:40:50 -0400
Content-Disposition: inline
In-Reply-To: <20170516121604.GF15597@bigcity.dyn.berto.se>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, May 16, 2017 at 02:16:04PM +0200, Niklas Söderlund wrote:
> Hi,
> 
> On 2017-05-16 13:36:21 +0200, Geert Uytterhoeven wrote:
> > Hi Simon,
> > 
> > On Tue, May 16, 2017 at 1:01 PM, Simon Horman <horms@verge.net.au> wrote:
> > > On Tue, May 16, 2017 at 11:07:34AM +0200, Geert Uytterhoeven wrote:
> > >> On Tue, May 16, 2017 at 11:02 AM, Niklas Söderlund
> > >> <niklas.soderlund@ragnatech.se> wrote:
> > >> >> > Whit all this being said I still like to withdraw this patch as I found
> > >> >> > another fault with it, ravb_wol_restore() will unconditionally be called
> > >> >> > while ravb_wol_setup() will only be called if netif_running(ndev). This
> > >> >> > is en easy fix and I will send out a v2 once we figure out what to do
> > >> >> > about the clock.
> > >> >>
> > >> >> The clock issue is external to the ravb driver. If it works with
> > >> >> s2idle, it should
> > >> >> be OK.
> > >> >
> > >> > Do you think it's a good idea to move ahead with a v2 of the ravb WoL
> > >> > patch to fix the unrelated issue and aim for it to be picked up prior to
> > >> > suspend/resume support is added to the CPG/MSSR?
> > >>
> > >> Sure.
> > >>
> > >> It can still be used on R-Car Gen2, where we're not s*d by mandatory PSCI.
> > >
> > > Is there some way for - e.g. the driver - to not enable WoL on Gen3 SoCs
> > > until the clock issues is sorted out? I'm quite happy to enable features
> > 
> > "priv->chip_id != RCAR_GEN3". However, as we don't have RAVB enabled
> > on any R-Car Gen2 board, its use is limited.
> 
> I agree that it's not so useful to enable this on Gen2 only.

Yeah, agreed. I had forgotten that RAVB only enabled on Gen3.

...
