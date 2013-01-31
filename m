From: Mugunthan V N <mugunthanvnm@ti.com>
Subject: Re: [PATCH v2 1/2] drivers: net: cpsw: Add helper functions for VLAN
 ALE implementation
Date: Thu, 31 Jan 2013 16:39:18 +0530
Message-ID: <510A50DE.1010308@ti.com>
References: <1359572855-12344-1-git-send-email-mugunthanvnm@ti.com> <1359572855-12344-2-git-send-email-mugunthanvnm@ti.com> <20130130220208.GA22847@electric-eye.fr.zoreil.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="ISO-8859-1"; format=flowed
Content-Transfer-Encoding: 7bit
Cc: <netdev@vger.kernel.org>, <davem@davemloft.net>,
	<linux-arm-kernel@lists.infradead.org>,
	<linux-omap@vger.kernel.org>
To: Francois Romieu <romieu@fr.zoreil.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from bear.ext.ti.com ([192.94.94.41]:44561 "EHLO bear.ext.ti.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752023Ab3AaLKB (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 31 Jan 2013 06:10:01 -0500
In-Reply-To: <20130130220208.GA22847@electric-eye.fr.zoreil.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 1/31/2013 3:32 AM, Francois Romieu wrote:
> Mugunthan V N <mugunthanvnm@ti.com> :
> [...]
>> diff --git a/drivers/net/ethernet/ti/cpsw_ale.c b/drivers/net/ethernet/ti/cpsw_ale.c
>> index 0e9ccc2..18b88ce 100644
>> --- a/drivers/net/ethernet/ti/cpsw_ale.c
>> +++ b/drivers/net/ethernet/ti/cpsw_ale.c
> [...]
>> @@ -274,19 +292,26 @@ int cpsw_ale_flush(struct cpsw_ale *ale, int port_mask)
>>   	return 0;
>>   }
>>   
>> -int cpsw_ale_add_ucast(struct cpsw_ale *ale, u8 *addr, int port, int flags)
>> +int cpsw_ale_add_ucast(struct cpsw_ale *ale, u8 *addr, int port,
>> +		       int flags, u16 vid)
>>   {
>>   	u32 ale_entry[ALE_ENTRY_WORDS] = {0, 0, 0};
>>   	int idx;
>>   
>> -	cpsw_ale_set_entry_type(ale_entry, ALE_TYPE_ADDR);
>> +	if (flags & ALE_VLAN) {
>> +		cpsw_ale_set_entry_type(ale_entry, ALE_TYPE_VLAN_ADDR);
>> +		cpsw_ale_set_vlan_id(ale_entry, vid);
>> +	} else {
>> +		cpsw_ale_set_entry_type(ale_entry, ALE_TYPE_ADDR);
>> +	}
>> +
> [...]
>> +	if (flags & ALE_VLAN) {
>> +		cpsw_ale_set_entry_type(ale_entry, ALE_TYPE_VLAN_ADDR);
>> +		cpsw_ale_set_vlan_id(ale_entry, vid);
>> +	} else {
>> +		cpsw_ale_set_entry_type(ale_entry, ALE_TYPE_ADDR);
>> +	}
>> +
> It could be fctored out.
Are you mentioning to have static inline function for the above two 
statements above?
>
> [...]
>> @@ -362,6 +395,55 @@ int cpsw_ale_del_mcast(struct cpsw_ale *ale, u8 *addr, int port_mask)
>>   	return 0;
>>   }
>>   
>> +int cpsw_ale_add_vlan(struct cpsw_ale *ale, u16 vid, int port, int untag,
>> +		      int reg_mcast, int unreg_mcast)
>> +{
> [...]
>> +int cpsw_ale_del_vlan(struct cpsw_ale *ale, u16 vid, int port_mask)
> [...]
>
> Patch #2 doesn't use the returned status code.
Will modify the prototype to return void

Regards
Mugunthan V N
