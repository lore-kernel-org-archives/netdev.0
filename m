From: Salil Mehta <mehta.salil.lnk@gmail.com>
Subject: Re: [PATCH V4 net-next 4/5] net:hns: Add support of ethtool TSO set
 option for Hip06 in HNS
Date: Tue, 1 Dec 2015 13:56:05 +0000
Message-ID: <565DA6F5.7040804__7518.04280230335$1448978347$gmane$org@gmail.com>
References: <1448048952-146714-1-git-send-email-salil.mehta@huawei.com>
 <1448048952-146714-5-git-send-email-salil.mehta@huawei.com>
 <CO2PR11MB00885531F54375191E6F015597180@CO2PR11MB0088.namprd11.prod.outlook.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252; format=flowed
Content-Transfer-Encoding: 7bit
To: Yuval Mintz <Yuval.Mintz@qlogic.com>,
	Salil Mehta <salil.mehta@huawei.com>,
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
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wm0-f65.google.com ([74.125.82.65]:35194 "EHLO
	mail-wm0-f65.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754336AbbLAN4J (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 1 Dec 2015 08:56:09 -0500
In-Reply-To: <CO2PR11MB00885531F54375191E6F015597180@CO2PR11MB0088.namprd11.prod.outlook.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>



On 22/11/15 11:17, Yuval Mintz wrote:
>> +static netdev_features_t hns_nic_fix_features(
>> +		struct net_device *netdev, netdev_features_t features) {
>> +	struct hns_nic_priv *priv = netdev_priv(netdev);
>> +
>> +	switch (priv->enet_ver) {
>> +	case AE_VERSION_1:
>> +		features &= ~(NETIF_F_TSO | NETIF_F_TSO6 |
>> +				NETIF_F_HW_VLAN_CTAG_FILTER);
>> +		break;
>> +	default:
>> +		break;
>> +	}
>> +	return features;
>> +}
>> +
> Isn't AE_VERSION_1 something fixed once you publish your features?
> If it can't be changed, why not simply remove the features from
> `hw_features' instead of having to implement this ndo?
Hi Yuval,
I some how missed to reply this, though I worked on your suggestions
in the already floated V5 patch earlier. Sorry for this!
There could be a case where the feature is supported by the SoC
and therefore it is already part of the 'hw_features' but it has been
say DISABLED or ENABLED by ethtool. In such a case, we need to
make sure we strike off that feature from the 'features' flag.

Therefore, we need this leg I suppose. Let me know If I am missing
something here or there is a gap in my understanding.

Thanks
Salil
