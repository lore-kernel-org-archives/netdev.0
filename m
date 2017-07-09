From: Geert Uytterhoeven <geert@linux-m68k.org>
Subject: Re: [PATCH] of_mdio: Fix broken PHY IRQ in case of probe deferral
Date: Sun, 9 Jul 2017 21:38:11 +0200
Message-ID: <CAMuHMdX13Dx=xMwWUpyhFZ25HT9h4R5GW314iYBZgy6VCuxmng@mail.gmail.com>
References: <1495112345-24795-1-git-send-email-geert+renesas@glider.be>
 <f0ed61c3-062b-cec6-fe19-7412231e8ef1@gmail.com> <CAMuHMdWYeSzofU57LmT_M3KkcHhvjfJy7nkHvcXkKzOYmvhqqA@mail.gmail.com>
 <20170518193453.GB13759@lunn.ch> <CAMuHMdV+jfh=EGt3SvjtrtVfWQ6P8ofp_JxeQZjRrSEfDWs5hA@mail.gmail.com>
 <08a89dd5-b707-8b8f-b8e1-e20b9ed630b7@gmail.com> <CAMuHMdWWfaP8=H7H+UzrmOYpydi2mGLFGzuk9FQWJtEOug6u5g@mail.gmail.com>
 <CAMuHMdUt6yOQ9=02z_7WG58YGxFYD=_zn7SeLEqGmfTrNBFJXw@mail.gmail.com>
 <CAMuHMdW8yzREzTE4GiW_8HU9h-T-fdDmLtZAXYkJrjuypN8BDg@mail.gmail.com>
 <38cc7c65-e4ca-cb8a-f43b-ca53e87724cf@gmail.com> <20170709172815.GA28183@lunn.ch>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Cc: Rob Herring <robh+dt@kernel.org>,
        Frank Rowand <frowand.list@gmail.com>,
        Thomas Petazzoni <thomas.petazzoni@free-electrons.com>,
        Sergei Shtylyov <sergei.shtylyov@cogentembedded.com>,
        "netdev@vger.kernel.org" <netdev@vger.kernel.org>,
        "devicetree@vger.kernel.org" <devicetree@vger.kernel.org>,
        Linux-Renesas <linux-renesas-soc@vger.kernel.org>,
        "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>
To: Andrew Lunn <andrew@lunn.ch>,
        Florian Fainelli <f.fainelli@gmail.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20170709172815.GA28183@lunn.ch>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hi Florian, Andrew,

On Sun, Jul 9, 2017 at 7:28 PM, Andrew Lunn <andrew@lunn.ch> wrote:
>> It sure does fix a real issue, but I am really concerned about the
>> inability to test this patch in a configuration where we have multiple
>> PHY(s) or MDIO device(s) hanging off the same MDIO bus and one of those
>> requesting an EPROBE_DEFER.

If that case happens now, it silently falls back to polling, hiding the
problem.

Actually it means there may be users that rely on this broken behavior,
that start to fail when their interrupts are suddenly handled :-(

>> I currently don't have a setup where I could exercise this, Andrew, do you?
>
> What i do have, is a switch with some built in copper Marvell PHYs and
> external SFF modules which use fixed link. I can probably hack the
> fixed-link driver to return EPROBE_DEFER a few times.

That would be great, thanks!

Gr{oetje,eeting}s,

                        Geert

--
Geert Uytterhoeven -- There's lots of Linux beyond ia32 -- geert@linux-m68k.org

In personal conversations with technical people, I call myself a hacker. But
when I'm talking to journalists I just say "programmer" or something like that.
                                -- Linus Torvalds
