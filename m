From: Geert Uytterhoeven <geert@linux-m68k.org>
Subject: Re: [PATCH] net/fsl: simplify Kconfig dependency list for fsl networking
Date: Fri, 14 Aug 2015 10:04:56 +0200
Message-ID: <CAMuHMdU2NiaPx5t7Aa2DF6OPc2ajW0yVV-vn_QS6JyWTw7rivw@mail.gmail.com>
References: <1439503319-25453-1-git-send-email-stuart.yoder@freescale.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: "David S. Miller" <davem@davemloft.net>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>,
	Scott Wood <scottwood@freescale.com>
To: Stuart Yoder <stuart.yoder@freescale.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1439503319-25453-1-git-send-email-stuart.yoder@freescale.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Fri, Aug 14, 2015 at 12:01 AM, Stuart Yoder
<stuart.yoder@freescale.com> wrote:
> make the list of Kconfig dependencies for Freescale
> networking more general. Simplify to supported
> architectures: ARM, ARM64, PPC, M68K
>
> Signed-off-by: Stuart Yoder <stuart.yoder@freescale.com>
> ---
>  drivers/net/ethernet/freescale/Kconfig | 4 +---
>  1 file changed, 1 insertion(+), 3 deletions(-)
>
> diff --git a/drivers/net/ethernet/freescale/Kconfig b/drivers/net/eth=
ernet/freescale/Kconfig
> index ff76d4e..70782d7 100644
> --- a/drivers/net/ethernet/freescale/Kconfig
> +++ b/drivers/net/ethernet/freescale/Kconfig
> @@ -5,9 +5,7 @@
>  config NET_VENDOR_FREESCALE
>         bool "Freescale devices"
>         default y
> -       depends on FSL_SOC || QUICC_ENGINE || CPM1 || CPM2 || PPC_MPC=
512x || \
> -                  M523x || M527x || M5272 || M528x || M520x || M532x=
 || \
> -                  ARCH_MXC || ARCH_MXS || (PPC_MPC52xx && PPC_BESTCO=
MM)
> +       depends on M68K || PPC || ARM || ARM64
>         ---help---
>           If you have a network (Ethernet) card belonging to this cla=
ss, say Y.

This breaks m68k/allmodconfig:

drivers/net/ethernet/freescale/gianfar.c: In function =E2=80=98gfar_par=
se_group=E2=80=99:
drivers/net/ethernet/freescale/gianfar.c:684: error: =E2=80=98NO_IRQ=E2=
=80=99
undeclared (first use in this function)
drivers/net/ethernet/freescale/gianfar.c:684: error: (Each undeclared
identifier is reported only once
drivers/net/ethernet/freescale/gianfar.c:684: error: for each function
it appears in.)

P.S. Hint: Would have been caught earlier if the NET_VENDOR_* symbol
     had "|| COMPILE_TEST" among its dependencies.

Gr{oetje,eeting}s,

                        Geert

--
Geert Uytterhoeven -- There's lots of Linux beyond ia32 -- geert@linux-=
m68k.org

In personal conversations with technical people, I call myself a hacker=
=2E But
when I'm talking to journalists I just say "programmer" or something li=
ke that.
                                -- Linus Torvalds
