From: Ivan Vecera <ivecera@redhat.com>
Subject: Re: [PATCH net-next v2 05/19] bna: use BIT(x) instead of (1 << x)
Date: Tue, 16 Jun 2015 10:43:46 +0200
Message-ID: <557FE1C2.3000408@redhat.com>
References: <1434030751-28835-1-git-send-email-ivecera@redhat.com> <1434030751-28835-6-git-send-email-ivecera@redhat.com> <063D6719AE5E284EB5DD2968C1650D6D1CB4D859@AcuExch.aculab.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252; format=flowed
Content-Transfer-Encoding: 7bit
Cc: "joe@perches.com" <joe@perches.com>
To: "netdev@vger.kernel.org" <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:41047 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S932527AbbFPInQ (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 16 Jun 2015 04:43:16 -0400
In-Reply-To: <063D6719AE5E284EB5DD2968C1650D6D1CB4D859@AcuExch.aculab.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 06/12/2015 03:30 PM, David Laight wrote:
> From: Ivan Vecera
> ...
>> diff --git a/drivers/net/ethernet/brocade/bna/bfa_defs_mfg_comm.h
>> b/drivers/net/ethernet/brocade/bna/bfa_defs_mfg_comm.h
>> index 679a503..16090fd 100644
>> --- a/drivers/net/ethernet/brocade/bna/bfa_defs_mfg_comm.h
>> +++ b/drivers/net/ethernet/brocade/bna/bfa_defs_mfg_comm.h
>> @@ -75,7 +75,7 @@ enum {
>>   	CB_GPIO_FC4P2   = (4),		/*!< 4G 2port FC card		*/
>>   	CB_GPIO_FC4P1   = (5),		/*!< 4G 1port FC card		*/
>>   	CB_GPIO_DFLY    = (6),		/*!< 8G 2port FC mezzanine card	*/
>> -	CB_GPIO_PROTO   = (1 << 7)	/*!< 8G 2port FC prototypes	*/
>> +	CB_GPIO_PROTO   = BIT(7)	/*!< 8G 2port FC prototypes	*/
>
> That doesn't look like a BIT() value to me, just a large number.
> Should the release driver even have support for the prototype hardware?
Why not? Does prototype HW need special driver?
The CB_GPIO_PROTO is an indication and you can have e.g. (CB_GPIO_FC4P1 
| CB_GPIO_PROTO) as 4G 1 port FC prototype card.

>
> ...
>> -		if (rx_enet_mask & ((u32)(1 << i))) {
>> +		if (rx_enet_mask & ((u32)BIT(i))) {
>
> The (u32) cast looks superfluous.
> There are also too many ().
Will fix.

>
> ...
>> -	int bit = (1 << (vlan_id & BFI_VLAN_WORD_MASK));
>> +	int bit = BIT((vlan_id & BFI_VLAN_WORD_MASK));
>
> Too many ()
The same...

>
> 	David
>
> --
> To unsubscribe from this list: send the line "unsubscribe netdev" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
>
