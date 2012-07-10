From: =?utf-8?Q?Bj=C3=B8rn_Mork?= <bjorn@mork.no>
Subject: Re: linux-next: build failure after merge of the net-next tree
Date: Tue, 10 Jul 2012 09:25:25 +0200
Message-ID: <87y5msgjru.fsf@nemi.mork.no>
References: <20120710130848.1014fbe05e5146a33a3c7d39@canb.auug.org.au>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: David Miller <davem@davemloft.net>, <netdev@vger.kernel.org>,
	linux-next@vger.kernel.org, linux-kernel@vger.kernel.org
To: Stephen Rothwell <sfr@canb.auug.org.au>
Return-path: <linux-next-owner@vger.kernel.org>
In-Reply-To: <20120710130848.1014fbe05e5146a33a3c7d39@canb.auug.org.au>
	(Stephen Rothwell's message of "Tue, 10 Jul 2012 13:08:48 +1000")
Sender: linux-next-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Stephen Rothwell <sfr@canb.auug.org.au> writes:

> Hi all,
>
> After merging the net-next tree, today's linux-next build (x86_64
> allmodconfig) failed like this:
>
> drivers/net/usb/qmi_wwan.c:381:13: error: 'qmi_wwan_unbind_shared' un=
declared here (not in a function)
>
> Caused by a bad automatic merge between commit 6fecd35d4cd7 ("net:
> qmi_wwan: add ZTE MF60") from the net tree and commit 230718bda1be ("=
net:
> qmi_wwan: bind to both control and data interface") from the net-next
> tree.
>
> I added the following merge fix patch:
>
> From: Stephen Rothwell <sfr@canb.auug.org.au>
> Date: Tue, 10 Jul 2012 13:06:01 +1000
> Subject: [PATCH] net: fix for qmi_wwan_unbind_shared changes
>
> Signed-off-by: Stephen Rothwell <sfr@canb.auug.org.au>
> ---
>  drivers/net/usb/qmi_wwan.c |    2 +-
>  1 file changed, 1 insertion(+), 1 deletion(-)
>
> diff --git a/drivers/net/usb/qmi_wwan.c b/drivers/net/usb/qmi_wwan.c
> index 06cfcc7..85c983d 100644
> --- a/drivers/net/usb/qmi_wwan.c
> +++ b/drivers/net/usb/qmi_wwan.c
> @@ -378,7 +378,7 @@ static const struct driver_info qmi_wwan_force_in=
t2 =3D {
>  	.description	=3D "Qualcomm WWAN/QMI device",
>  	.flags		=3D FLAG_WWAN,
>  	.bind		=3D qmi_wwan_bind_shared,
> -	.unbind		=3D qmi_wwan_unbind_shared,
> +	.unbind		=3D qmi_wwan_unbind,
>  	.manage_power	=3D qmi_wwan_manage_power,
>  	.data		=3D BIT(2), /* interface whitelist bitmap */
>  };


Looks good.  Thanks.


Bj=C3=B8rn
