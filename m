From: wangyufen <wangyufen@huawei.com>
Subject: Re: [PATCH] bonding:fix speed unknown,lacp bonding failed
Date: Fri, 5 Jul 2013 18:10:30 +0800
Message-ID: <51D69B96.60002@huawei.com>
References: <1373005979-10196-1-git-send-email-wangyufen@huawei.com> <20130705.014042.1794673817887092292.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="ISO-8859-1"
Content-Transfer-Encoding: 7bit
Cc: <netdev@vger.kernel.org>, <lizefan@huawei.com>,
	<zhangdianfang@huawei.com>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from szxga02-in.huawei.com ([119.145.14.65]:40731 "EHLO
	szxga02-in.huawei.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756058Ab3GEKLH (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 5 Jul 2013 06:11:07 -0400
In-Reply-To: <20130705.014042.1794673817887092292.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 2013/7/5 16:40, David Miller wrote:
> From: Wangyufen <wangyufen@huawei.com>
> Date: Fri, 5 Jul 2013 14:32:59 +0800
> 
>> @@ -2301,8 +2301,11 @@ static int bond_miimon_inspect(struct bonding *bond)
> 
>>  		switch (slave->link) {
>>  		case BOND_LINK_UP:
>> -			if (link_state)
>> +			if (link_state) {
>> +				if (slave->speed == SPEED_UNKNOWN)
>> +					bond_update_speed_duplex(slave);
>>  				continue;
> 
> bond_miimon_inspect() does not hold the RTNL mutex, and it is required
> that the RTNL mutex is held when bond_update_speed_duplex() is called.
> 
> If you ran this new code, you should be hitting the assertion at the
> beginning of __ethtool_get_settings() which reads:
> 
> 	ASSERT_RTNL();
> 
> In fact, if you look at bond_miimon_inspect()'s caller it goes:
> 
> 		if (!rtnl_trylock()) {
> 
> right after calling bond_miimon_inspect().
OK,thanks.
> --
> To unsubscribe from this list: send the line "unsubscribe netdev" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
> 
> 
