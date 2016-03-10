From: "Yankejian (Hackim Yim)" <yankejian@huawei.com>
Subject: Re: [patch net 2/2] net: hns: fixes a bug of RSS
Date: Thu, 10 Mar 2016 21:03:49 +0800
Message-ID: <56E170B5.90109@huawei.com>
References: <1457576189-22924-1-git-send-email-yankejian@huawei.com>
 <1457576189-22924-3-git-send-email-yankejian@huawei.com>
 <1457598253.1347.52.camel@linux.intel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: <yisen.zhuang@huawei.com>, <salil.mehta@huawei.com>,
	<liguozhu@huawei.com>, <huangdaode@hisilicon.com>, <arnd@arndb.de>,
	<andrew@lunn.ch>, <chenny.xu@huawei.com>, <ivecera@redhat.com>,
	<lisheng011@huawei.com>, <fengguang.wu@intel.com>,
	<haifeng.wei@huawei.com>, <netdev@vger.kernel.org>,
	<linux-kernel@vger.kernel.org>,
	<linux-arm-kernel@lists.infradead.org>, <linuxarm@huawei.com>
To: Andy Shevchenko <andriy.shevchenko@linux.intel.com>,
	<davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from szxga02-in.huawei.com ([119.145.14.65]:3247 "EHLO
	szxga02-in.huawei.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750773AbcCJNFe (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 10 Mar 2016 08:05:34 -0500
In-Reply-To: <1457598253.1347.52.camel@linux.intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>



On 2016/3/10 16:24, Andy Shevchenko wrote:
> On Thu, 2016-03-10 at 10:16 +0800, Kejian Yan wrote:
>> If trying to get receive flow hash indirection table by ethtool, it
>> needs
>> to call .get_rxnfc to get ring number first. So this patch implements
>> the
>> .get_rxnfc of ethtool. And the data type of rss_indir_table is u32,
>> it has
>> to be multiply by the width of data type when using memcpy.
> +static int hns_get_rxnfc(struct net_device *netdev,
>> +			 struct ethtool_rxnfc *cmd,
>> +			 u32 *rule_locs)
>> +{
>> +	struct hns_nic_priv *priv = netdev_priv(netdev);
>> +	int ret = 0;
>> +
>> +	switch (cmd->cmd) {
>> +	case ETHTOOL_GRXRINGS:
>> +		cmd->data = priv->ae_handle->q_num;
>> +		break;
>> +	default:
>> +		ret = -EOPNOTSUPP;
>> +		break;
>> +	}
>> +
>> +	return ret;
> Redundant ret variable.
>
> switch (value) {
> case X:
>  break;
> default:
>  return -ERRNO;
> }
>
> return 0;

ok, thanks. i will fix it in next submit.

>> +}
