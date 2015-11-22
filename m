From: Yuval Mintz <Yuval.Mintz@qlogic.com>
Subject: RE: [PATCH V4 net-next 4/5] net:hns: Add support of ethtool TSO set
 option for Hip06 in HNS
Date: Sun, 22 Nov 2015 11:17:13 +0000
Message-ID: <CO2PR11MB00885531F54375191E6F015597180__26970.5288847492$1448191108$gmane$org@CO2PR11MB0088.namprd11.prod.outlook.com>
References: <1448048952-146714-1-git-send-email-salil.mehta@huawei.com>
 <1448048952-146714-5-git-send-email-salil.mehta@huawei.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 8BIT
To: Salil Mehta <salil.mehta@huawei.com>,
	David Miller <davem@davemloft.net>,
	"robh+dt@kernel.org" <robh+dt@kernel.org>,
	"pawel.moll@arm.com" <pawel.moll@arm.com>,
	"mark.rutland@arm.com" <mark.rutland@arm.com>,
	"paul.gortmaker@windriver.com" <paul.gortmaker@windriver.com>,
	"ijc+devicetree@hellion.org.uk" <ijc+devicetree@hellion.org.uk>,
	"galak@codeaurora.org" <galak@codeaurora.org>,
	"catalin.marinas@arm.com" <catalin.marinas@arm.com>,
	"will.deacon@arm.com" <will.deacon@arm.com>,
	"arnd@arndb.de" <arnd@arndb.de>,
	"liguozhu@hisilicon.com" <liguozhu@hisilicon.com>,
	"yisen.zhuang@huawei.com" <yisen.zhuang@huawei.com>,
	"dingtianhong@huawei.com" <dingtianhong@huawei.com>,
	"zhangfei.gao@linaro.org" <zhangfei.gao@linaro.org>,
	"huangdaode@hisilicon.com" <huangdaode@hisilicon.com>,
	"kenneth-lee-2012@foxmail.com" <kenneth-lee-2012@foxmail.com>,
	"mehta.salil.lnk@gmail.com" <mehta.sal
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-bn1on0144.outbound.protection.outlook.com ([157.56.110.144]:16224
	"EHLO na01-bn1-obe.outbound.protection.outlook.com"
	rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
	id S1751229AbbKVLRT convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 22 Nov 2015 06:17:19 -0500
In-Reply-To: <1448048952-146714-5-git-send-email-salil.mehta@huawei.com>
Content-Language: en-US
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

> +static netdev_features_t hns_nic_fix_features(
> +		struct net_device *netdev, netdev_features_t features) {
> +	struct hns_nic_priv *priv = netdev_priv(netdev);
> +
> +	switch (priv->enet_ver) {
> +	case AE_VERSION_1:
> +		features &= ~(NETIF_F_TSO | NETIF_F_TSO6 |
> +				NETIF_F_HW_VLAN_CTAG_FILTER);
> +		break;
> +	default:
> +		break;
> +	}
> +	return features;
> +}
> +

Isn't AE_VERSION_1 something fixed once you publish your features?
If it can't be changed, why not simply remove the features from
`hw_features' instead of having to implement this ndo?
