From: David Laight <David.Laight@ACULAB.COM>
Subject: RE: [PATCH 1/1] net: hns: avoid null pointer dereference
Date: Thu, 19 May 2016 11:14:58 +0000
Message-ID: <063D6719AE5E284EB5DD2968C1650D6D5F4C22D9@AcuExch.aculab.com>
References: <1463515275-9836-1-git-send-email-xypron.glpk@gmx.de>
Mime-Version: 1.0
Content-Type: text/plain; charset="Windows-1252"
Content-Transfer-Encoding: 8BIT
Cc: Yisen Zhuang <Yisen.Zhuang@huawei.com>,
	Kejian Yan <yankejian@huawei.com>,
	Lisheng <lisheng011@huawei.com>,
	Kenneth Lee <liguozhu@huawei.com>,
	"Andrew Lunn" <andrew@lunn.ch>, Salil <salil.mehta@huawei.com>,
	Qianqian Xie <xieqianqian@huawei.com>,
	huangdaode <huangdaode@hisilicon.com>,
	Chenny Xu <chenny.xu@huawei.com>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>
To: 'Heinrich Schuchardt' <xypron.glpk@gmx.de>,
	"David S. Miller" <davem@davemloft.net>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1463515275-9836-1-git-send-email-xypron.glpk@gmx.de>
Content-Language: en-US
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Heinrich Schuchardt
> Sent: 17 May 2016 21:01
> In the statement
>   assert(priv || priv->ae_handle);
> the right side of || is only evaluated if priv is null.
> 
> Signed-off-by: Heinrich Schuchardt <xypron.glpk@gmx.de>
> ---
>  drivers/net/ethernet/hisilicon/hns/hns_ethtool.c | 8 ++++----
>  1 file changed, 4 insertions(+), 4 deletions(-)
> 
> diff --git a/drivers/net/ethernet/hisilicon/hns/hns_ethtool.c
> b/drivers/net/ethernet/hisilicon/hns/hns_ethtool.c
> index 3d746c8..834a50a 100644
> --- a/drivers/net/ethernet/hisilicon/hns/hns_ethtool.c
> +++ b/drivers/net/ethernet/hisilicon/hns/hns_ethtool.c
> @@ -720,7 +720,7 @@ static int hns_set_pauseparam(struct net_device *net_dev,
>  	struct hnae_handle *h;
>  	struct hnae_ae_ops *ops;
> 
> -	assert(priv || priv->ae_handle);
> +	assert(priv && priv->ae_handle);
> 
>  	h = priv->ae_handle;
>  	ops = h->dev->ops;
...

Personally I'd just delete the assert().
It is probably easier to debug the 'oops' from the NULL pointer dereference
that that of the assert().
If either value can be NULL (without a coding error) then you'd want to
return an error.

	David
