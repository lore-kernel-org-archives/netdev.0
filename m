From: Andy Shevchenko <andriy.shevchenko@linux.intel.com>
Subject: Re: [patch net 2/2] net: hns: fixes a bug of RSS
Date: Thu, 10 Mar 2016 10:24:13 +0200
Message-ID: <1457598253.1347.52.camel@linux.intel.com>
References: <1457576189-22924-1-git-send-email-yankejian@huawei.com>
	 <1457576189-22924-3-git-send-email-yankejian@huawei.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: yisen.zhuang@huawei.com, salil.mehta@huawei.com,
	liguozhu@huawei.com, huangdaode@hisilicon.com, arnd@arndb.de,
	andrew@lunn.ch, chenny.xu@huawei.com, ivecera@redhat.com,
	lisheng011@huawei.com, fengguang.wu@intel.com,
	haifeng.wei@huawei.com, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org, linux-arm-kernel@lists.infradead.org,
	linuxarm@huawei.com
To: Kejian Yan <yankejian@huawei.com>, davem@davemloft.net
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1457576189-22924-3-git-send-email-yankejian@huawei.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Thu, 2016-03-10 at 10:16 +0800, Kejian Yan wrote:
> If trying to get receive flow hash indirection table by ethtool, it
> needs
> to call .get_rxnfc to get ring number first. So this patch implements
> the
> .get_rxnfc of ethtool. And the data type of rss_indir_table is u32,
> it has
> to be multiply by the width of data type when using memcpy.

+static int hns_get_rxnfc(struct net_device *netdev,
> +			=C2=A0struct ethtool_rxnfc *cmd,
> +			=C2=A0u32 *rule_locs)
> +{
> +	struct hns_nic_priv *priv =3D netdev_priv(netdev);
> +	int ret =3D 0;
> +
> +	switch (cmd->cmd) {
> +	case ETHTOOL_GRXRINGS:
> +		cmd->data =3D priv->ae_handle->q_num;
> +		break;
> +	default:
> +		ret =3D -EOPNOTSUPP;
> +		break;
> +	}
> +
> +	return ret;

Redundant ret variable.

switch (value) {
case X:
=C2=A0break;
default:
=C2=A0return -ERRNO;
}

return 0;

> +}

--=20
Andy Shevchenko <andriy.shevchenko@linux.intel.com>
Intel Finland Oy
