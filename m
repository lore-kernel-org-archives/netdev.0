From: Michal Nazarewicz <mina86@mina86.com>
Subject: Re: [PATCH 25/31] ethernet: use parity8 in sun/niu.c
Date: Mon, 28 Mar 2016 10:33:48 -0400
Message-ID: <xa1t7fgmbrjn.fsf@mina86.com>
References: <1458788612-4367-1-git-send-email-zhaoxiu.zeng@gmail.com> <56F78D76.1060305@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: linux-kernel@vger.kernel.org, netdev@vger.kernel.org
To: "zhaoxiu.zeng" <zhaoxiu.zeng@gmail.com>,
	Jiri Pirko <jiri@resnulli.us>,
	Andrew Morton <akpm@linux-foundation.org>,
	"David S. Miller" <davem@davemloft.net>,
	Vlastimil Babka <vbabka@suse.cz>,
	Joonsoo Kim <iamjoonsoo.kim@lge.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <56F78D76.1060305@gmail.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Sun, Mar 27 2016, zhaoxiu zeng wrote:
> From: Zeng Zhaoxiu <zhaoxiu.zeng@gmail.com>
>
> Signed-off-by: Zeng Zhaoxiu <zhaoxiu.zeng@gmail.com>

No idea why I=E2=80=99ve been CC=E2=80=99d, but code looks good to me s=
o:

Acked-by: Michal Nazarewicz <mina86@mina86.com>

> ---
>  drivers/net/ethernet/sun/niu.c | 10 ++--------
>  1 file changed, 2 insertions(+), 8 deletions(-)
>
> diff --git a/drivers/net/ethernet/sun/niu.c b/drivers/net/ethernet/su=
n/niu.c
> index 9cc4564..8c344ef 100644
> --- a/drivers/net/ethernet/sun/niu.c
> +++ b/drivers/net/ethernet/sun/niu.c
> @@ -2742,18 +2742,12 @@ static int niu_set_alt_mac_rdc_table(struct n=
iu *np, int idx,
> =20
>  static u64 vlan_entry_set_parity(u64 reg_val)
>  {
> -	u64 port01_mask;
> -	u64 port23_mask;
> -
> -	port01_mask =3D 0x00ff;
> -	port23_mask =3D 0xff00;
> -
> -	if (hweight64(reg_val & port01_mask) & 1)
> +	if (parity8(reg_val))
>  		reg_val |=3D ENET_VLAN_TBL_PARITY0;
>  	else
>  		reg_val &=3D ~ENET_VLAN_TBL_PARITY0;
> =20
> -	if (hweight64(reg_val & port23_mask) & 1)
> +	if (parity8((unsigned int)reg_val >> 8))
>  		reg_val |=3D ENET_VLAN_TBL_PARITY1;
>  	else
>  		reg_val &=3D ~ENET_VLAN_TBL_PARITY1;
> --=20
> 2.5.5
>

--=20
Best regards
=E3=83=9F=E3=83=8F=E3=82=A6 =E2=80=9C=F0=9D=93=B6=F0=9D=93=B2=F0=9D=93=B7=
=F0=9D=93=AA86=E2=80=9D =E3=83=8A=E3=82=B6=E3=83=AC=E3=83=B4=E3=82=A4=E3=
=83=84
=C2=ABIf at first you don=E2=80=99t succeed, give up skydiving=C2=BB
