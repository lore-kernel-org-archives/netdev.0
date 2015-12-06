From: Yuval Mintz <Yuval.Mintz@qlogic.com>
Subject: RE: [PATCH V4 net-next 4/5] net:hns: Add support of ethtool TSO set
 option for Hip06 in HNS
Date: Sun, 6 Dec 2015 06:43:12 +0000
Message-ID: <CO2PR11MB008864AFF3D819EFE7A7622B970A0__17741.1057790325$1449384266$gmane$org@CO2PR11MB0088.namprd11.prod.outlook.com>
References: <1448048952-146714-1-git-send-email-salil.mehta@huawei.com>
 <1448048952-146714-5-git-send-email-salil.mehta@huawei.com>
 <CO2PR11MB00885531F54375191E6F015597180@CO2PR11MB0088.namprd11.prod.outlook.com>
 <565DA6F5.7040804@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 8BIT
To: Salil Mehta <mehta.salil.lnk@gmail.com>,
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
	"kenneth-lee-2012@foxmail.com" <kenneth-lee-2012@foxmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-by2on0105.outbound.protection.outlook.com ([207.46.100.105]:44160
	"EHLO na01-by2-obe.outbound.protection.outlook.com"
	rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
	id S1751023AbbLFGnR convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 6 Dec 2015 01:43:17 -0500
In-Reply-To: <565DA6F5.7040804@gmail.com>
Content-Language: en-US
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

> > Isn't AE_VERSION_1 something fixed once you publish your features?
> > If it can't be changed, why not simply remove the features from
> > `hw_features' instead of having to implement this ndo?
> There could be a case where the feature is supported by the SoC
> and therefore it is already part of the 'hw_features' but it has been
> say DISABLED or ENABLED by ethtool. In such a case, we need to
> make sure we strike off that feature from the 'features' flag.
> 
> Therefore, we need this leg I suppose. Let me know If I am missing
> something here or there is a gap in my understanding.

Look at ethtool_set_features() - if something isn't listed in hw_features,
you're not support to be able to change it.

If you can make a one-time decision when registering the netdevice
whether this feature is supported by HW or not [assuming AE_VERSION_1
is available at that point and can't later change] than it's the better alternative.

Cheers,
Yuval 
