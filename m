From: Yisen Zhuang <Yisen.zhuang@huawei.com>
Subject: Re: [PATCH 1/1] net: hns: avoid null pointer dereference
Date: Wed, 18 May 2016 09:04:07 +0800
Message-ID: <573BBF87.4010101@huawei.com>
References: <1463515275-9836-1-git-send-email-xypron.glpk@gmx.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Kejian Yan <yankejian@huawei.com>, Lisheng <lisheng011@huawei.com>,
	Kenneth Lee <liguozhu@huawei.com>,
	Andrew Lunn <andrew@lunn.ch>, Salil <salil.mehta@huawei.com>,
	Qianqian Xie <xieqianqian@huawei.com>,
	huangdaode <huangdaode@hisilicon.com>,
	Chenny Xu <chenny.xu@huawei.com>, <netdev@vger.kernel.org>,
	<linux-kernel@vger.kernel.org>
To: Heinrich Schuchardt <xypron.glpk@gmx.de>,
	"David S. Miller" <davem@davemloft.net>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1463515275-9836-1-git-send-email-xypron.glpk@gmx.de>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hi Heinrich,

This patch is fine to me.

Thanks,

Yisen

=E5=9C=A8 2016/5/18 4:01, Heinrich Schuchardt =E5=86=99=E9=81=93:
> In the statement
>   assert(priv || priv->ae_handle);
> the right side of || is only evaluated if priv is null.
>=20
> Signed-off-by: Heinrich Schuchardt <xypron.glpk@gmx.de>
> ---
>  drivers/net/ethernet/hisilicon/hns/hns_ethtool.c | 8 ++++----
>  1 file changed, 4 insertions(+), 4 deletions(-)
>=20
> diff --git a/drivers/net/ethernet/hisilicon/hns/hns_ethtool.c b/drive=
rs/net/ethernet/hisilicon/hns/hns_ethtool.c
> index 3d746c8..834a50a 100644
> --- a/drivers/net/ethernet/hisilicon/hns/hns_ethtool.c
> +++ b/drivers/net/ethernet/hisilicon/hns/hns_ethtool.c
> @@ -720,7 +720,7 @@ static int hns_set_pauseparam(struct net_device *=
net_dev,
>  	struct hnae_handle *h;
>  	struct hnae_ae_ops *ops;
> =20
> -	assert(priv || priv->ae_handle);
> +	assert(priv && priv->ae_handle);
> =20
>  	h =3D priv->ae_handle;
>  	ops =3D h->dev->ops;
> @@ -780,7 +780,7 @@ static int hns_set_coalesce(struct net_device *ne=
t_dev,
>  	struct hnae_ae_ops *ops;
>  	int ret;
> =20
> -	assert(priv || priv->ae_handle);
> +	assert(priv && priv->ae_handle);
> =20
>  	ops =3D priv->ae_handle->dev->ops;
> =20
> @@ -1111,7 +1111,7 @@ void hns_get_regs(struct net_device *net_dev, s=
truct ethtool_regs *cmd,
>  	struct hns_nic_priv *priv =3D netdev_priv(net_dev);
>  	struct hnae_ae_ops *ops;
> =20
> -	assert(priv || priv->ae_handle);
> +	assert(priv && priv->ae_handle);
> =20
>  	ops =3D priv->ae_handle->dev->ops;
> =20
> @@ -1135,7 +1135,7 @@ static int hns_get_regs_len(struct net_device *=
net_dev)
>  	struct hns_nic_priv *priv =3D netdev_priv(net_dev);
>  	struct hnae_ae_ops *ops;
> =20
> -	assert(priv || priv->ae_handle);
> +	assert(priv && priv->ae_handle);
> =20
>  	ops =3D priv->ae_handle->dev->ops;
>  	if (!ops->get_regs_len) {
>=20
