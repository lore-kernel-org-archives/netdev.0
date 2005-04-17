From: "Luis R. Rodriguez" <mcgrof@gmail.com>
Subject: Re: [PATCH] prism54: fix printk format warnings
Date: Sun, 17 Apr 2005 18:24:53 -0400
Message-ID: <43e72e8905041715247c8765f0@mail.gmail.com>
References: <20050301212137.57f9532f.rddunlap@osdl.org>
Reply-To: "Luis R. Rodriguez" <mcgrof@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: quoted-printable
Cc: netdev@oss.sgi.com, jgarzik <jgarzik@pobox.com>,
	prism54-devel@prism54.org
Return-path: <prism54-devel-bounces@prism54.org>
To: "Randy.Dunlap" <rddunlap@osdl.org>
In-Reply-To: <20050301212137.57f9532f.rddunlap@osdl.org>
Content-Disposition: inline
List-Unsubscribe: <http://prism54.org/mailman/listinfo/prism54-devel>,
	<mailto:prism54-devel-request@prism54.org?subject=unsubscribe>
List-Archive: <http://prism54.org/pipermail/prism54-devel>
List-Post: <mailto:prism54-devel@prism54.org>
List-Help: <mailto:prism54-devel-request@prism54.org?subject=help>
List-Subscribe: <http://prism54.org/mailman/listinfo/prism54-devel>,
	<mailto:prism54-devel-request@prism54.org?subject=subscribe>
Sender: prism54-devel-bounces@prism54.org
Errors-To: prism54-devel-bounces@prism54.org
List-Id: netdev.vger.kernel.org

Thanks Randy. This is already in prism54 svn tree. Feel free to apply Jeff.

  Luis

On 3/2/05, Randy.Dunlap <rddunlap@osdl.org> wrote:
>=20
> prism54 build shows some printk format complaints:
> (sparc64 build warning)
>=20
> drivers/net/wireless/prism54/isl_38xx.c:131: warning: long int format, di=
fferent type arg (arg 3)
> drivers/net/wireless/prism54/isl_38xx.c:151: warning: long int format, di=
fferent type arg (arg 3)
>=20
> cross-compile results:
> https://www.osdl.org/plm-cgi/plm?module=3Dpatch_info&patch_id=3D4240
>=20
> Signed-off-by: Randy Dunlap <rddunlap@osdl.org>
>=20
> diffstat:=3D
>  drivers/net/wireless/prism54/isl_38xx.c |   12 ++++++------
>  1 files changed, 6 insertions(+), 6 deletions(-)
>=20
> diff -Naurp ./drivers/net/wireless/prism54/isl_38xx.c~prism_printk ./driv=
ers/net/wireless/prism54/isl_38xx.c
> --- ./drivers/net/wireless/prism54/isl_38xx.c~prism_printk      2004-12-2=
4 13:34:45.000000000 -0800
> +++ ./drivers/net/wireless/prism54/isl_38xx.c   2005-03-01 20:15:00.18999=
5120 -0800
> @@ -125,11 +125,11 @@ isl38xx_trigger_device(int asleep, void
>  #if VERBOSE > SHOW_ERROR_MESSAGES
>                 do_gettimeofday(&current_time);
>                 DEBUG(SHOW_TRACING, "%08li.%08li Device wakeup triggered\=
n",
> -                     current_time.tv_sec, current_time.tv_usec);
> +                     current_time.tv_sec, (long)current_time.tv_usec);
>  #endif
>=20
>                 DEBUG(SHOW_TRACING, "%08li.%08li Device register read %08=
x\n",
> -                     current_time.tv_sec, current_time.tv_usec,
> +                     current_time.tv_sec, (long)current_time.tv_usec,
>                       readl(device_base + ISL38XX_CTRL_STAT_REG));
>                 udelay(ISL38XX_WRITEIO_DELAY);
>=20
> @@ -139,7 +139,7 @@ isl38xx_trigger_device(int asleep, void
>                         do_gettimeofday(&current_time);
>                         DEBUG(SHOW_TRACING,
>                               "%08li.%08li Device register abadface\n",
> -                             current_time.tv_sec, current_time.tv_usec);
> +                             current_time.tv_sec, (long)current_time.tv_=
usec);
>  #endif
>                         /* read the Device Status Register until Sleepmod=
e bit is set */
>                         while (reg =3D readl(device_base + ISL38XX_CTRL_S=
TAT_REG),
> @@ -150,7 +150,7 @@ isl38xx_trigger_device(int asleep, void
>=20
>                         DEBUG(SHOW_TRACING,
>                               "%08li.%08li Device register read %08x\n",
> -                             current_time.tv_sec, current_time.tv_usec,
> +                             current_time.tv_sec, (long)current_time.tv_=
usec,
>                               readl(device_base + ISL38XX_CTRL_STAT_REG))=
;
>                         udelay(ISL38XX_WRITEIO_DELAY);
>=20
> @@ -158,7 +158,7 @@ isl38xx_trigger_device(int asleep, void
>                         do_gettimeofday(&current_time);
>                         DEBUG(SHOW_TRACING,
>                               "%08li.%08li Device asleep counter %i\n",
> -                             current_time.tv_sec, current_time.tv_usec,
> +                             current_time.tv_sec, (long)current_time.tv_=
usec,
>                               counter);
>  #endif
>                 }
> @@ -174,7 +174,7 @@ isl38xx_trigger_device(int asleep, void
>  #if VERBOSE > SHOW_ERROR_MESSAGES
>                 do_gettimeofday(&current_time);
>                 DEBUG(SHOW_TRACING, "%08li.%08li Device register read %08=
x\n",
> -                     current_time.tv_sec, current_time.tv_usec, reg);
> +                     current_time.tv_sec, (long)current_time.tv_usec, re=
g);
>  #endif
>         } else {
>                 /* device is (still) awake  */
>=20
> ---
>
