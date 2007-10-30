From: Roel Kluin <12o3l@tiscali.nl>
Subject: Re: [2.6 patch] fix drivers/net/wan/lmc/ compilation
Date: Tue, 30 Oct 2007 21:45:47 +0100
Message-ID: <472797FB.3050509@tiscali.nl>
References: <20071030203136.GQ7227@stusta.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Andrew Morton <akpm@linux-foundation.org>,
	"David S. Miller" <davem@davemloft.net>, netdev@vger.kernel.org,
	jgarzik@pobox.com, linux-kernel@vger.kernel.org
To: Adrian Bunk <bunk@kernel.org>
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S1759198AbXJ3Uqi@vger.kernel.org>
In-Reply-To: <20071030203136.GQ7227@stusta.de>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Adrian Bunk wrote:
> Documentation/SubmitChecklist, point 1:
>=20
> <--  snip  -->
>=20
> ...
>   CC      drivers/net/wan/lmc/lmc_main.o
> /home/bunk/linux/kernel-2.6/git/linux-2.6/drivers/net/wan/lmc/lmc_mai=
n.c: In function =E2=80=98lmc_ioctl=E2=80=99:
> /home/bunk/linux/kernel-2.6/git/linux-2.6/drivers/net/wan/lmc/lmc_mai=
n.c:239: error: expected expression before =E2=80=98else=E2=80=99
> ...
> make[5]: *** [drivers/net/wan/lmc/lmc_main.o] Error 1
>=20
> <--  snip  -->
>=20
> Signed-off-by: Adrian Bunk <bunk@kernel.org>
>=20
> ---
> d5e92a30491abf073e0a7f4d46b466c7c97f0f61=20
> diff --git a/drivers/net/wan/lmc/lmc_main.c b/drivers/net/wan/lmc/lmc=
_main.c
> index 64eb578..37c52e1 100644
> --- a/drivers/net/wan/lmc/lmc_main.c
> +++ b/drivers/net/wan/lmc/lmc_main.c
> @@ -234,7 +234,7 @@ int lmc_ioctl (struct net_device *dev, struct ifr=
eq *ifr, int cmd) /*fold00*/
>          sc->lmc_xinfo.Magic1 =3D 0xDEADBEEF;
> =20
>          if (copy_to_user(ifr->ifr_data, &sc->lmc_xinfo,
> -					sizeof(struct lmc_xinfo))) {
> +			 sizeof(struct lmc_xinfo)))
>  		ret =3D -EFAULT;
>  	else
>  		ret =3D 0;
>=20

I am sorry, my patch broke this and Kristov Provost also noticed this.
See http://lkml.org/lkml/2007/10/30/355
