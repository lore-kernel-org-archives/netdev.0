From: Yuval Mintz <Yuval.Mintz@qlogic.com>
Subject: RE: [PATCH V3 net-next 2/5] net:hns: Add Hip06 "RSS(Receive Side
 Scaling)" support to HNS Driver
Date: Sun, 22 Nov 2015 09:30:30 +0000
Message-ID: <CO2PR11MB0088B852596B9F86F7BDCF6F97180__36342.1422466219$1448184685$gmane$org@CO2PR11MB0088.namprd11.prod.outlook.com>
References: <1447966706-16219-1-git-send-email-salil.mehta@huawei.com>
 <1447966706-16219-3-git-send-email-salil.mehta@huawei.com>
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
Received: from mail-bl2on0139.outbound.protection.outlook.com ([65.55.169.139]:65216
	"EHLO na01-bl2-obe.outbound.protection.outlook.com"
	rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
	id S1751223AbbKVJaf convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 22 Nov 2015 04:30:35 -0500
In-Reply-To: <1447966706-16219-3-git-send-email-salil.mehta@huawei.com>
Content-Language: en-US
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

>  static void hns_ppe_init_hw(struct hns_ppe_cb *ppe_cb)  {
...
> +	/* Set default RSS key and indrection table*/
> +	const u32 rss_key[HNS_PPEV2_RSS_KEY_NUM] = {
> +		0x6d5a56da, 0x255b0ec2,
> +		0x4167253d, 0x43a38fb0,
> +		0xd0ca2bcb, 0xae7b30b4,
> +		0x77cb2da3, 0x8030f20c,
> +		0x6a42b73b, 0xbeac01fa,
> +	};
> +
> +	/* set default RSS key and remember it */
> +	for (i = 0; i < HNS_PPEV2_RSS_KEY_NUM; i++)
> +		ppe_cb->rss_key[i]  = rss_key[i];
> 

Is there any reason for the special default key?
Why not use netdev_rss_key_fill()?
