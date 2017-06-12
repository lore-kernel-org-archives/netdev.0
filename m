From: Niklas =?iso-8859-1?Q?S=F6derlund?=
        <niklas.soderlund@ragnatech.se>
Subject: Re: [PATCH] ravb: add wake-on-lan support via magic packet
Date: Mon, 12 Jun 2017 13:32:10 +0200
Message-ID: <20170612113210.GH17461@bigcity.dyn.berto.se>
References: <20170512143242.GA13939@bigcity.dyn.berto.se>
 <CAMuHMdU+uiiZfh5u+tL_bVJinhP-c0_iF4ZQh8=9NHN+aqUs=Q@mail.gmail.com>
 <20170512211222.GI31437@bigcity.dyn.berto.se>
 <CAMuHMdWZ8XLX0Zu0D54Ex+3RaFNm_fJyFQvyo+qz10HpB2nGqQ@mail.gmail.com>
 <20170516090214.GA30768@bigcity.dyn.berto.se>
 <CAMuHMdVkitTgVmUrPu5+z2JwnwHop4bJ5anMq1SmCeFfV=OxQg@mail.gmail.com>
 <20170516110145.GA27247@verge.net.au>
 <CAMuHMdV9fjYvV=axAkp5WQbXTbZSXg5+g=HNubzPYSRwmStiWg@mail.gmail.com>
 <20170516121604.GF15597@bigcity.dyn.berto.se>
 <CAMuHMdVzRKTtDE=+hBkde+zFyYOb54iKesSGbJVJ2j_-HPZ+wQ@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Transfer-Encoding: 8bit
Cc: Simon Horman <horms@verge.net.au>,
        Sergei Shtylyov <sergei.shtylyov@cogentembedded.com>,
        "netdev@vger.kernel.org" <netdev@vger.kernel.org>,
        Linux-Renesas <linux-renesas-soc@vger.kernel.org>
To: Geert Uytterhoeven <geert@linux-m68k.org>
Return-path: <linux-renesas-soc-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <CAMuHMdVzRKTtDE=+hBkde+zFyYOb54iKesSGbJVJ2j_-HPZ+wQ@mail.gmail.com>
Sender: linux-renesas-soc-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hi Geert,

On 2017-05-18 10:52:25 +0200, Geert Uytterhoeven wrote:
> Hi Niklas,
> 
> On Tue, May 16, 2017 at 2:16 PM, Niklas Söderlund
> <niklas.soderlund@ragnatech.se> wrote:
> > On 2017-05-16 13:36:21 +0200, Geert Uytterhoeven wrote:
> >> On Tue, May 16, 2017 at 1:01 PM, Simon Horman <horms@verge.net.au> wrote:
> >> > Is there some way for - e.g. the driver - to not enable WoL on Gen3 SoCs
> >> > until the clock issues is sorted out? I'm quite happy to enable features
> >> > where they work; not so much where they don't.
> >>
> >> Agreed.
> >>
> >> One workaround could be to disable/enable the module clock in the WoL
> >> resume path, to make sure it is enabled.  Once the enable count reaches
> >> 0, CCF will know it's disabled, and will really enable next time.
> >> You may need a double disable/double enable though, without testing I
> >> don't know remember the enable count is 1 or 2 at that point (due to PM
> >> runtime).
> >
> > I thought about this but it feels like such a hack I did not dare
> > suggest it :-) But at the same time it would be nice to enable WoL for
> > the s2idle use-case where it works. Only resume from PSCI with WoL
> > enabled that is broken, and WoL in PSCI suspend will never work :-)
> 
> Indeed.
> 
> > How about I add another patch in v2 on-top of this that adds the clock
> > disable/enable hack? That way it's clear that this is a workaround and
> > once we have support for suspend/resume in CPG/MSSR just that patch can
> > be reverted? Or is it cleaner to fold it in to this patch with a big
> > comment that this is a workaround? Or is it maybe better to hold of on
> > this until CPG/MSSR supports suspend/resume?
> 
> Personally, I would have no problems of having the workaround integrated (and
> documented, of course) in the WoL patch, as it avoids having broken PSCI
> suspend in between WoL-without-workaround and a separate workaround.

You have now posted '[PATCH/RFC] clk: renesas: cpg-mssr: Restore module 
clock registers during resume' which solves this issue. Do you think it 
would be OK for me to resubmit this patch due to an unrelated fix and 
state that it depends on your patch or do you feel it still would be 
valuable to include a workaround in the RAVB driver as to not make it 
dependent on your patch?

> 
> It's not that dissimilar from the initial R-Car Gen3 support patch limiting
> ravb to 100 Mbps.
> 
> Gr{oetje,eeting}s,
> 
>                         Geert
> 
> --
> Geert Uytterhoeven -- There's lots of Linux beyond ia32 -- geert@linux-m68k.org
> 
> In personal conversations with technical people, I call myself a hacker. But
> when I'm talking to journalists I just say "programmer" or something like that.
>                                 -- Linus Torvalds

-- 
Regards,
Niklas Söderlund
