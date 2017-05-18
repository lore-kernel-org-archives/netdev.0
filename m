From: Geert Uytterhoeven <geert@linux-m68k.org>
Subject: Re: [PATCH] ravb: add wake-on-lan support via magic packet
Date: Thu, 18 May 2017 10:52:25 +0200
Message-ID: <CAMuHMdVzRKTtDE=+hBkde+zFyYOb54iKesSGbJVJ2j_-HPZ+wQ@mail.gmail.com>
References: <CAMuHMdUXqWJMh7syd3muMs8v9wx5bJNRj_3+xEAXTQTfAv0BFA@mail.gmail.com>
 <20170512125853.GH31437@bigcity.dyn.berto.se> <20170512143242.GA13939@bigcity.dyn.berto.se>
 <CAMuHMdU+uiiZfh5u+tL_bVJinhP-c0_iF4ZQh8=9NHN+aqUs=Q@mail.gmail.com>
 <20170512211222.GI31437@bigcity.dyn.berto.se> <CAMuHMdWZ8XLX0Zu0D54Ex+3RaFNm_fJyFQvyo+qz10HpB2nGqQ@mail.gmail.com>
 <20170516090214.GA30768@bigcity.dyn.berto.se> <CAMuHMdVkitTgVmUrPu5+z2JwnwHop4bJ5anMq1SmCeFfV=OxQg@mail.gmail.com>
 <20170516110145.GA27247@verge.net.au> <CAMuHMdV9fjYvV=axAkp5WQbXTbZSXg5+g=HNubzPYSRwmStiWg@mail.gmail.com>
 <20170516121604.GF15597@bigcity.dyn.berto.se>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: quoted-printable
Cc: Simon Horman <horms@verge.net.au>,
        Sergei Shtylyov <sergei.shtylyov@cogentembedded.com>,
        "netdev@vger.kernel.org" <netdev@vger.kernel.org>,
        Linux-Renesas <linux-renesas-soc@vger.kernel.org>
To: =?UTF-8?Q?Niklas_S=C3=B6derlund?= <niklas.soderlund@ragnatech.se>
Return-path: <linux-renesas-soc-owner@vger.kernel.org>
In-Reply-To: <20170516121604.GF15597@bigcity.dyn.berto.se>
Sender: linux-renesas-soc-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hi Niklas,

On Tue, May 16, 2017 at 2:16 PM, Niklas S=C3=B6derlund
<niklas.soderlund@ragnatech.se> wrote:
> On 2017-05-16 13:36:21 +0200, Geert Uytterhoeven wrote:
>> On Tue, May 16, 2017 at 1:01 PM, Simon Horman <horms@verge.net.au> wrote=
:
>> > Is there some way for - e.g. the driver - to not enable WoL on Gen3 So=
Cs
>> > until the clock issues is sorted out? I'm quite happy to enable featur=
es
>> > where they work; not so much where they don't.
>>
>> Agreed.
>>
>> One workaround could be to disable/enable the module clock in the WoL
>> resume path, to make sure it is enabled.  Once the enable count reaches
>> 0, CCF will know it's disabled, and will really enable next time.
>> You may need a double disable/double enable though, without testing I
>> don't know remember the enable count is 1 or 2 at that point (due to PM
>> runtime).
>
> I thought about this but it feels like such a hack I did not dare
> suggest it :-) But at the same time it would be nice to enable WoL for
> the s2idle use-case where it works. Only resume from PSCI with WoL
> enabled that is broken, and WoL in PSCI suspend will never work :-)

Indeed.

> How about I add another patch in v2 on-top of this that adds the clock
> disable/enable hack? That way it's clear that this is a workaround and
> once we have support for suspend/resume in CPG/MSSR just that patch can
> be reverted? Or is it cleaner to fold it in to this patch with a big
> comment that this is a workaround? Or is it maybe better to hold of on
> this until CPG/MSSR supports suspend/resume?

Personally, I would have no problems of having the workaround integrated (a=
nd
documented, of course) in the WoL patch, as it avoids having broken PSCI
suspend in between WoL-without-workaround and a separate workaround.

It's not that dissimilar from the initial R-Car Gen3 support patch limiting
ravb to 100 Mbps.

Gr{oetje,eeting}s,

                        Geert

--
Geert Uytterhoeven -- There's lots of Linux beyond ia32 -- geert@linux-m68k=
.org

In personal conversations with technical people, I call myself a hacker. Bu=
t
when I'm talking to journalists I just say "programmer" or something like t=
hat.
                                -- Linus Torvalds
