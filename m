From: Geert Uytterhoeven <geert@linux-m68k.org>
Subject: Re: [PATCH] ravb: add wake-on-lan support via magic packet
Date: Fri, 12 May 2017 15:03:15 +0200
Message-ID: <CAMuHMdWBDEoRhgMKun_AjOqkuq0xRvGBjnpnJmCiLHMcev7OdA@mail.gmail.com>
References: <20170511222735.10706-1-niklas.soderlund+renesas@ragnatech.se>
 <CAMuHMdUXqWJMh7syd3muMs8v9wx5bJNRj_3+xEAXTQTfAv0BFA@mail.gmail.com> <20170512125853.GH31437@bigcity.dyn.berto.se>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: quoted-printable
Cc: Sergei Shtylyov <sergei.shtylyov@cogentembedded.com>,
        "netdev@vger.kernel.org" <netdev@vger.kernel.org>,
        Linux-Renesas <linux-renesas-soc@vger.kernel.org>
To: =?UTF-8?Q?Niklas_S=C3=B6derlund?= <niklas.soderlund@ragnatech.se>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-io0-f169.google.com ([209.85.223.169]:35558 "EHLO
        mail-io0-f169.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1755479AbdELNDR (ORCPT
        <rfc822;netdev@vger.kernel.org>); Fri, 12 May 2017 09:03:17 -0400
In-Reply-To: <20170512125853.GH31437@bigcity.dyn.berto.se>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi Niklas,

On Fri, May 12, 2017 at 2:58 PM, Niklas S=C3=B6derlund
<niklas.soderlund@ragnatech.se> wrote:
> On 2017-05-12 14:47:53 +0200, Geert Uytterhoeven wrote:
>> On Fri, May 12, 2017 at 12:27 AM, Niklas S=C3=B6derlund
>> <niklas.soderlund+renesas@ragnatech.se> wrote:
>> > WoL is enabled in the suspend callback by setting MagicPacket detectio=
n
>> > and disabling all interrupts expect MagicPacket. In the resume path th=
e
>> > driver needs to reset the hardware to rearm the WoL logic, this preven=
ts
>> > the driver from simply restoring the registers and to take advantage o=
f
>> > that ravb was not suspended to reduce resume time. To reset the
>> > hardware the driver closes the device, sets it in reset mode and reope=
ns
>> > the device just like it would do in a normal suspend/resume scenario
>> > without WoL enabled, but it both closes and opens the device in the
>> > resume callback since the device needs to be reset for WoL to work.
>> >
>> > One quirk needed for WoL is that the module clock needs to be prevente=
d
>> > from being switched off by Runtime PM. To keep the clock alive the
>> > suspend callback need to call clk_enable() directly to increase the
>> > usage count of the clock. Then when Runtime PM decreases the clock usa=
ge
>> > count it won't reach 0 and be switched off.
>> >
>> > Signed-off-by: Niklas S=C3=B6derlund <niklas.soderlund+renesas@ragnate=
ch.se>
>>
>> Thanks for your patch!
>>
>> Wake-on-LAN now works for me on Salvator-X (both H3 and M3).
>>
>> However, after a few cycles, Ethernet stopped working, because CMA ran o=
ut of
>> memory:
>>
>>     cma: cma_alloc: alloc failed, req-size: 6 pages, ret: -4
>>     dpm_run_callback(): ravb_resume+0x0/0x148 returns -12
>>     PM: Device e6800000.ethernet failed to resume: error -12
>>
>> Are we still missing some ravb patches in net-next, or is this a differe=
nt
>> issue?
>
> Interesting, I did a 100 loop test on H3 based on v4.11 without any
> issues. What are you using as a base for your test and I will test if I
> can reproduce it.

Something based on last renesas-drivers.

Gr{oetje,eeting}s,

                        Geert
