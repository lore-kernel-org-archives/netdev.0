From: Scott Wood <scott.wood@nxp.com>
Subject: Re: [upstream-release] [PATCH net 2/4] fsl/fman: arm: call
        of_platform_populate() for arm64 platfrom
Date: Thu, 15 Dec 2016 18:41:40 +0000
Message-ID: <DB5PR0401MB1928F163614C64900D1458ED919D0@DB5PR0401MB1928.eurprd04.prod.outlook.com>
References: <1481807497-4724-1-git-send-email-madalin.bucur@nxp.com>
 <1481807497-4724-3-git-send-email-madalin.bucur@nxp.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: quoted-printable
Cc: "linuxppc-dev@lists.ozlabs.org" <linuxppc-dev@lists.ozlabs.org>,
        "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>,
        "davem@davemloft.net" <davem@davemloft.net>
To: Madalin-Cristian Bucur <madalin.bucur@nxp.com>,
        "netdev@vger.kernel.org" <netdev@vger.kernel.org>
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Language: en-US
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On 12/15/2016 07:11 AM, Madalin Bucur wrote:=0A=
> From: Igal Liberman <igal.liberman@freescale.com>=0A=
> =0A=
> Signed-off-by: Igal Liberman <igal.liberman@freescale.com>=0A=
> ---=0A=
>  drivers/net/ethernet/freescale/fman/fman.c | 10 ++++++++++=0A=
>  1 file changed, 10 insertions(+)=0A=
> =0A=
> diff --git a/drivers/net/ethernet/freescale/fman/fman.c b/drivers/net/eth=
ernet/freescale/fman/fman.c=0A=
> index dafd9e1..f36b4eb 100644=0A=
> --- a/drivers/net/ethernet/freescale/fman/fman.c=0A=
> +++ b/drivers/net/ethernet/freescale/fman/fman.c=0A=
> @@ -2868,6 +2868,16 @@ static struct fman *read_dts_node(struct platform_=
device *of_dev)=0A=
>  =0A=
>  	fman->dev =3D &of_dev->dev;=0A=
>  =0A=
> +#ifdef CONFIG_ARM64=0A=
> +	/* call of_platform_populate in order to probe sub-nodes on arm64 */=0A=
> +	err =3D of_platform_populate(fm_node, NULL, NULL, &of_dev->dev);=0A=
> +	if (err) {=0A=
> +		dev_err(&of_dev->dev, "%s: of_platform_populate() failed\n",=0A=
> +			__func__);=0A=
> +		goto fman_free;=0A=
> +	}=0A=
> +#endif=0A=
=0A=
Should we remove fsl,fman from the PPC of_device_ids[], so this doesn't=0A=
need an ifdef?=0A=
=0A=
Why is it #ifdef CONFIG_ARM64 rather than #ifndef CONFIG_PPC?=0A=
=0A=
-Scott=0A=
=0A=
