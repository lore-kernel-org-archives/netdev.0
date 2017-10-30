From: Geert Uytterhoeven <geert@linux-m68k.org>
Subject: Re: [PATCH] sr9800: Use common error handling code in sr9800_phy_powerup()
Date: Mon, 30 Oct 2017 10:59:20 +0100
Message-ID: <CAMuHMdWpaohd4rFxLzBaBDE2v79487Ak8WQjJpjR465wnRvhXA@mail.gmail.com>
References: <10f2b5a4-1dbd-2c4f-caaa-4225dff35296@users.sourceforge.net>
 <CAMuHMdU6K+KPZvsStfwPev9Z5v1RRYAwLr04FHjmeC=VUEMC+Q@mail.gmail.com> <0600e4f9-dd53-158c-556b-8a87dfc928e6@users.sourceforge.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: quoted-printable
Cc: "netdev@vger.kernel.org" <netdev@vger.kernel.org>,
        USB list <linux-usb@vger.kernel.org>,
        =?UTF-8?Q?Bj=C3=B8rn_Mork?= <bjorn@mork.no>,
        "David S. Miller" <davem@davemloft.net>,
        Greg Ungerer <gerg@linux-m68k.org>,
        Liu Junliang <liujunliang_ljl@163.com>,
        Philippe Reynes <tremyfr@gmail.com>,
        LKML <linux-kernel@vger.kernel.org>,
        "kernel-janitors@vger.kernel.org" <kernel-janitors@vger.kernel.org>
To: SF Markus Elfring <elfring@users.sourceforge.net>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <0600e4f9-dd53-158c-556b-8a87dfc928e6@users.sourceforge.net>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hi Markus,

On Sun, Oct 29, 2017 at 1:03 PM, SF Markus Elfring
<elfring@users.sourceforge.net> wrote:
>>> @@ -700,10 +700,9 @@ static int sr9800_phy_powerup(struct usbnet *dev)
>>>
>>>         /* set the embedded Ethernet PHY in power-up state */
>>>         ret =3D sr_sw_reset(dev, SR_SWRESET_IPRL);
>>> -       if (ret < 0) {
>>> -               netdev_err(dev->net, "Failed to reset PHY: %d\n", ret);
>>> -               return ret;
>>> -       }
>>> +       if (ret < 0)
>>> +               goto report_reset_failure;
>>
>> So now I have to look below to see what error handling it does...
>
> Yes. - Can this be an usual consequence if you apply information from
> the section =E2=80=9C7) Centralized exiting of functions=E2=80=9D in the =
document
> =E2=80=9Ccoding-style.rst=E2=80=9D a bit more?

That section is useful if several cleanups steps have to be performed.
In this case, the only common part is the printing of the error message.
Printing error messages is not a cleanup step.

What's also bad in this case, is that after the first "goto", there are oth=
er
error cases that don't use goto, but just return, because there's no cleanu=
p
to do there.

Hence:
NAKed-by: Geert Uytterhoeven <geert@linux-m68k.org>

>> Hence I prefer the original version, which had _less_ lines of code...
>
> My update suggestion is only one line =E2=80=9Cbigger=E2=80=9D in this ca=
se, isn't it?
>
> I propose an other source code layout so that a bit smaller executable
> object code could be achieved.
> Do find such a software design direction feasible?

If you play the "smaller executable object code" card, people expect that
you provide the actual numbers, too.

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
