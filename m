From: Igor Russkikh <igor.russkikh@aquantia.com>
Subject: Re: [PATCH net 2/4] net:ethernet:aquantia: Fix Tx queue hangups
Date: Thu, 21 Sep 2017 17:31:47 +0300
Message-ID: <74f2e3bc-e1ef-92cf-d665-5e7abb68ae94@aquantia.com>
References: <cover.1505915085.git.igor.russkikh@aquantia.com>
 <cef3863edd8d504d7406f781c97260c52f21e156.1505915085.git.igor.russkikh@aquantia.com>
 <024e7fb3-9b53-f4f2-3901-38a63c47d76c@huawei.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, David Arcari <darcari@redhat.com>,
        Pavel Belous <Pavel.Belous@aquantia.com>,
        Nadezhda Krupnina <Nadezhda.Krupnina@aquantia.com>,
        Simon Edelhaus <simon.edelhaus@aquantia.com>
To: Yunsheng Lin <linyunsheng@huawei.com>,
        "David S . Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-by2nam01on0050.outbound.protection.outlook.com ([104.47.34.50]:30590
        "EHLO NAM01-BY2-obe.outbound.protection.outlook.com"
        rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
        id S1751726AbdIUOcE (ORCPT <rfc822;netdev@vger.kernel.org>);
        Thu, 21 Sep 2017 10:32:04 -0400
In-Reply-To: <024e7fb3-9b53-f4f2-3901-38a63c47d76c@huawei.com>
Content-Language: en-US
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Thanks for the comments, Yunsheng,

>>  
>> +static int aq_nic_update_link_status(struct aq_nic_s *self)
>> +{
>> +	int err = self->aq_hw_ops.hw_get_link_status(self->aq_hw);
>> +
>> +	if (err < 0)
>> +		return -1;
> why not just return err?

Agreed, that could be improved.

>> +	if (self->link_status.mbps != self->aq_hw->aq_link_status.mbps)
>> +		pr_info("%s: link change old %d new %d\n",
>> +			AQ_CFG_DRV_NAME, self->link_status.mbps,
>> +			self->aq_hw->aq_link_status.mbps);
> You has ndev in struct aq_nic_s *self, why not use netdev_*?

We are planning to introduce a generic rework commit separately and use netif_* set of macro's through all the driver's code.

-- 
BR, Igor
