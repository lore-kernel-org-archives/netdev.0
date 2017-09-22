From: Igor Russkikh <igor.russkikh@aquantia.com>
Subject: Re: [PATCH net 1/4] net:ethernet:aquantia: Setup max_mtu in ndev to
 enable jumbo frames
Date: Fri, 22 Sep 2017 10:24:30 +0300
Message-ID: <bff2d1ee-6bd6-1682-be49-f10ee3b20f9f@aquantia.com>
References: <cover.1505915085.git.igor.russkikh@aquantia.com>
 <1b556b3a2fd12c566912541f3c969d4bdc5dde9c.1505915085.git.igor.russkikh@aquantia.com>
 <20170921153619.GG27589@lunn.ch>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 8bit
Cc: "David S . Miller" <davem@davemloft.net>, netdev@vger.kernel.org,
        David Arcari <darcari@redhat.com>,
        Pavel Belous <Pavel.Belous@aquantia.com>,
        Nadezhda Krupnina <Nadezhda.Krupnina@aquantia.com>,
        Simon Edelhaus <simon.edelhaus@aquantia.com>
To: Andrew Lunn <andrew@lunn.ch>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-by2nam01on0057.outbound.protection.outlook.com ([104.47.34.57]:40304
        "EHLO NAM01-BY2-obe.outbound.protection.outlook.com"
        rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
        id S1751795AbdIVHYq (ORCPT <rfc822;netdev@vger.kernel.org>);
        Fri, 22 Sep 2017 03:24:46 -0400
In-Reply-To: <20170921153619.GG27589@lunn.ch>
Content-Language: en-US
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


>>  	self->ndev->mtu = aq_nic_cfg->mtu - ETH_HLEN;
>> +	self->ndev->min_mtu = ETH_MIN_MTU;
> This is not required. It will default to ETH_MIN_MTU.

Thanks Andrew, true.

>> +	self->ndev->max_mtu = self->aq_hw_caps.mtu - ETH_FCS_LEN - ETH_HLEN;
>>  
>>  	return 0;
>>  }
>> @@ -695,7 +696,7 @@ int aq_nic_set_mtu(struct aq_nic_s *self, int new_mtu)
>>  {
>>  	int err = 0;
>>  
>> -	if (new_mtu > self->aq_hw_caps.mtu) {
>> +	if (new_mtu + ETH_FCS_LEN > self->aq_hw_caps.mtu) {
> If you have set max_mtu correctly, this cannot happen.  But it seems
> odd you don't have ETH_HLEN here, where as when setting max_mtu you
> do.

I agree, thats an extra check. Will remove that.
Regarding ETH_HLEN - the baseline code invokes this function with (new_mtu + ETH_HLEN)  - thats why this check does not add it. In general, that extra level of storage (aq_nic_cfg.mtu field) is almost useless, I'll cleanup this under a separate patchset.

-- 
BR,
  Igor
