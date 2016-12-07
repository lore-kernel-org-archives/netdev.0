From: Geert Uytterhoeven <geert@linux-m68k.org>
Subject: Re: [PATCH] sh_eth: add wake-on-lan support via magic packet
Date: Wed, 7 Dec 2016 19:14:40 +0100
Message-ID: <CAMuHMdVK1DtJMajqD-eZ82QSP2ZRozwaR4zNc0ae1YT21Exq0w@mail.gmail.com>
References: <20161207162843.4731-1-niklas.soderlund+renesas@ragnatech.se>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: quoted-printable
Cc: Sergei Shtylyov <sergei.shtylyov@cogentembedded.com>,
        Simon Horman <horms+renesas@verge.net.au>,
        "netdev@vger.kernel.org" <netdev@vger.kernel.org>,
        Linux-Renesas <linux-renesas-soc@vger.kernel.org>
To: =?UTF-8?Q?Niklas_S=C3=B6derlund?=
        <niklas.soderlund+renesas@ragnatech.se>
Return-path: <linux-renesas-soc-owner@vger.kernel.org>
In-Reply-To: <20161207162843.4731-1-niklas.soderlund+renesas@ragnatech.se>
Sender: linux-renesas-soc-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hi Niklas,

On Wed, Dec 7, 2016 at 5:28 PM, Niklas S=C3=B6derlund
<niklas.soderlund+renesas@ragnatech.se> wrote:
> Signed-off-by: Niklas S=C3=B6derlund <niklas.soderlund+renesas@ragnatech.=
se>

Thanks, works fine on r8a7791/koelsch!

Tested-by: Geert Uytterhoeven <geert+renesas@glider.be>

> --- a/drivers/net/ethernet/renesas/sh_eth.c
> +++ b/drivers/net/ethernet/renesas/sh_eth.c
> @@ -624,7 +624,7 @@ static struct sh_eth_cpu_data r8a779x_data =3D {
>
>         .register_type  =3D SH_ETH_REG_FAST_RCAR,
>
> -       .ecsr_value     =3D ECSR_PSRTO | ECSR_LCHNG | ECSR_ICD,
> +       .ecsr_value     =3D ECSR_PSRTO | ECSR_LCHNG | ECSR_ICD | ECSR_MPD=
,

Interestingly, the ECSR_MPD bit is already set for several SoCs.

Hence adding ".magic =3D 1" to the entry for r8a7740 instantly gave me work=
ing
WoL support on r8a7740/armadillo. Cool!

> --- a/drivers/net/ethernet/renesas/sh_eth.h
> +++ b/drivers/net/ethernet/renesas/sh_eth.h
> @@ -493,6 +493,7 @@ struct sh_eth_cpu_data {
>         unsigned shift_rd0:1;   /* shift Rx descriptor word 0 right by 16=
 */
>         unsigned rmiimode:1;    /* EtherC has RMIIMODE register */
>         unsigned rtrate:1;      /* EtherC has RTRATE register */
> +       unsigned magic:1;       /* EtherC have PMDE in ECMR and MPDIP in =
ECSIPR */

Instead of adding a new flag, perhaps you can just check for the ECSR_MPD f=
lag
in ecsr_value?

> @@ -529,6 +530,9 @@ struct sh_eth_private {
>         unsigned no_ether_link:1;
>         unsigned ether_link_active_low:1;
>         unsigned is_opened:1;
> +
> +       bool wol_enabled;

"unsigned wol_enabled:1", to merge with the bitfield above?

> +       struct clk *clk;

It's a good practice to keep all pointers at the top of the struct, to avoi=
d
gaps due to alignment restrictions, especially on 64-bit (I know that's not
the case here).

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
