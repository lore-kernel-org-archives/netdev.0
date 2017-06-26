From: Geert Uytterhoeven <geert@linux-m68k.org>
Subject: Re: [PATCH 1/2] fsl/fman: propagate dma_ops
Date: Mon, 26 Jun 2017 18:24:17 +0200
Message-ID: <CAMuHMdXAKTBGiFc37jQjjCV_9Mb2SE2t7KHWASSwdMcFpFKmrA@mail.gmail.com>
References: <1497884657-3744-1-git-send-email-madalin.bucur@nxp.com>
 <1497884657-3744-2-git-send-email-madalin.bucur@nxp.com> <CAMuHMdU6hkU03s2ZBYEYdOqO3M1djbjZ0YKw8VbHYEvsNxLZxw@mail.gmail.com>
 <AM5PR0402MB26914A0A9BB0877F420848B9ECDF0@AM5PR0402MB2691.eurprd04.prod.outlook.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: quoted-printable
Cc: "netdev@vger.kernel.org" <netdev@vger.kernel.org>,
        "David S. Miller" <davem@davemloft.net>,
        "linuxppc-dev@lists.ozlabs.org" <linuxppc-dev@lists.ozlabs.org>,
        "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>
To: Madalin-cristian Bucur <madalin.bucur@nxp.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <AM5PR0402MB26914A0A9BB0877F420848B9ECDF0@AM5PR0402MB2691.eurprd04.prod.outlook.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hi Madalin,

On Mon, Jun 26, 2017 at 4:55 PM, Madalin-cristian Bucur
<madalin.bucur@nxp.com> wrote:
>> -----Original Message-----
>> From: geert.uytterhoeven@gmail.com [mailto:geert.uytterhoeven@gmail.com]
>> On Behalf Of Geert Uytterhoeven
>> Sent: Monday, June 26, 2017 10:49 AM
>> To: Madalin-cristian Bucur <madalin.bucur@nxp.com>
>> Cc: netdev@vger.kernel.org; David S. Miller <davem@davemloft.net>;
>> linuxppc-dev@lists.ozlabs.org; linux-kernel@vger.kernel.org
>> Subject: Re: [PATCH 1/2] fsl/fman: propagate dma_ops
>>
> On Mon, Jun 19, 2017 at 5:04 PM, Madalin Bucur <madalin.bucur@nxp.com>
>> wrote:
>> > Make sure dma_ops are set, to be later used by the Ethernet driver.
>> >
>> > Signed-off-by: Madalin Bucur <madalin.bucur@nxp.com>
>> > ---
>> >  drivers/net/ethernet/freescale/fman/mac.c | 2 ++
>> >  1 file changed, 2 insertions(+)
>> >
>> > diff --git a/drivers/net/ethernet/freescale/fman/mac.c
>> b/drivers/net/ethernet/freescale/fman/mac.c
>> > index 0b31f85..6e67d22f 100644
>> > --- a/drivers/net/ethernet/freescale/fman/mac.c
>> > +++ b/drivers/net/ethernet/freescale/fman/mac.c
>> > @@ -623,6 +623,8 @@ static struct platform_device
>> *dpaa_eth_add_device(int fman_id,
>> >                 goto no_mem;
>> >         }
>> >
>> > +       set_dma_ops(&pdev->dev, get_dma_ops(priv->dev));
>> > +
>>
>> When compile-testing with f NO_DMA=3Dy:
>>
>>     drivers/net/ethernet/freescale/fman/mac.c: In function
>> =E2=80=98dpaa_eth_add_device=E2=80=99:
>>     drivers/net/ethernet/freescale/fman/mac.c:626: error: implicit
>> declaration of function =E2=80=98set_dma_ops=E2=80=99
>>
>> Reverting commit 5567e989198b5a8d fixes this regression in v4.12-rc7.
>>
>> Why is this change needed?
>> There's no single other call to the DMA API in this file?
>
> We're setting here the dma_ops that are later used in the other driver/pa=
tch.
> The problem is we now depend upon DMA but do not explicitly declare it:
>
> <<Code that depends on the dma-mapping API needs to set 'depends on HAS_D=
MA'
> in its Kconfig>>

Sure. But only if the driver really uses DMA.
I can stick a set_dma_ops() call in whatever driver, but that doesn't
mean it will
suddenly use DMA.
Why does the FMan driver suddenly has a dependency on DMA, if it doesn't
use DMA?

> I'll need to add this to the FMan driver Kconfig.

Why does the FMan driver need this?
Why can't his call be done in the driver that uses the DMA APIO?

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
