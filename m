From: Geert Uytterhoeven <geert@linux-m68k.org>
Subject: Re: [PATCH] ravb: add wake-on-lan support via magic packet
Date: Tue, 16 May 2017 13:36:21 +0200
Message-ID: <CAMuHMdV9fjYvV=axAkp5WQbXTbZSXg5+g=HNubzPYSRwmStiWg@mail.gmail.com>
References: <20170511222735.10706-1-niklas.soderlund+renesas@ragnatech.se>
 <CAMuHMdUXqWJMh7syd3muMs8v9wx5bJNRj_3+xEAXTQTfAv0BFA@mail.gmail.com>
 <20170512125853.GH31437@bigcity.dyn.berto.se> <20170512143242.GA13939@bigcity.dyn.berto.se>
 <CAMuHMdU+uiiZfh5u+tL_bVJinhP-c0_iF4ZQh8=9NHN+aqUs=Q@mail.gmail.com>
 <20170512211222.GI31437@bigcity.dyn.berto.se> <CAMuHMdWZ8XLX0Zu0D54Ex+3RaFNm_fJyFQvyo+qz10HpB2nGqQ@mail.gmail.com>
 <20170516090214.GA30768@bigcity.dyn.berto.se> <CAMuHMdVkitTgVmUrPu5+z2JwnwHop4bJ5anMq1SmCeFfV=OxQg@mail.gmail.com>
 <20170516110145.GA27247@verge.net.au>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: quoted-printable
Cc: =?UTF-8?Q?Niklas_S=C3=B6derlund?= <niklas.soderlund@ragnatech.se>,
        Sergei Shtylyov <sergei.shtylyov@cogentembedded.com>,
        "netdev@vger.kernel.org" <netdev@vger.kernel.org>,
        Linux-Renesas <linux-renesas-soc@vger.kernel.org>
To: Simon Horman <horms@verge.net.au>
Return-path: <linux-renesas-soc-owner@vger.kernel.org>
In-Reply-To: <20170516110145.GA27247@verge.net.au>
Sender: linux-renesas-soc-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hi Simon,

On Tue, May 16, 2017 at 1:01 PM, Simon Horman <horms@verge.net.au> wrote:
> On Tue, May 16, 2017 at 11:07:34AM +0200, Geert Uytterhoeven wrote:
>> On Tue, May 16, 2017 at 11:02 AM, Niklas S=C3=B6derlund
>> <niklas.soderlund@ragnatech.se> wrote:
>> >> > Whit all this being said I still like to withdraw this patch as I f=
ound
>> >> > another fault with it, ravb_wol_restore() will unconditionally be c=
alled
>> >> > while ravb_wol_setup() will only be called if netif_running(ndev). =
This
>> >> > is en easy fix and I will send out a v2 once we figure out what to =
do
>> >> > about the clock.
>> >>
>> >> The clock issue is external to the ravb driver. If it works with
>> >> s2idle, it should
>> >> be OK.
>> >
>> > Do you think it's a good idea to move ahead with a v2 of the ravb WoL
>> > patch to fix the unrelated issue and aim for it to be picked up prior =
to
>> > suspend/resume support is added to the CPG/MSSR?
>>
>> Sure.
>>
>> It can still be used on R-Car Gen2, where we're not s*d by mandatory PSC=
I.
>
> Is there some way for - e.g. the driver - to not enable WoL on Gen3 SoCs
> until the clock issues is sorted out? I'm quite happy to enable features

"priv->chip_id !=3D RCAR_GEN3". However, as we don't have RAVB enabled
on any R-Car Gen2 board, its use is limited.

> where they work; not so much where they don't.

Agreed.

One workaround could be to disable/enable the module clock in the WoL
resume path, to make sure it is enabled.  Once the enable count reaches
0, CCF will know it's disabled, and will really enable next time.
You may need a double disable/double enable though, without testing I
don't know remember the enable count is 1 or 2 at that point (due to PM
runtime).

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
