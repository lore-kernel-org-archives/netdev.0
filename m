From: Netanel Belgazal <netanel@annapurnalabs.com>
Subject: Re: [PATCH V2 net 04/20] net/ena: fix ethtool RSS flow configuration
Date: Mon, 5 Dec 2016 20:26:40 +0200
Message-ID: <376d4953-277e-b10d-bf71-1c4e05954a7c@annapurnalabs.com>
References: <1480857578-5065-1-git-send-email-netanel@annapurnalabs.com>
 <1480857578-5065-5-git-send-email-netanel@annapurnalabs.com>
 <20161205041815.GE4310@u54ee753d2d1854bda401.ant.amazon.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8; format=flowed
Content-Transfer-Encoding: 7bit
Cc: linux-kernel@vger.kernel.org, davem@davemloft.net,
        netdev@vger.kernel.org, dwmw@amazon.com, zorik@annapurnalabs.com,
        alex@annapurnalabs.com, saeed@annapurnalabs.com, msw@amazon.com,
        aliguori@amazon.com, nafea@annapurnalabs.com
To: Matt Wilson <msw@amzn.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wm0-f41.google.com ([74.125.82.41]:35611 "EHLO
        mail-wm0-f41.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751686AbcLES0o (ORCPT
        <rfc822;netdev@vger.kernel.org>); Mon, 5 Dec 2016 13:26:44 -0500
Received: by mail-wm0-f41.google.com with SMTP id a197so106108199wmd.0
        for <netdev@vger.kernel.org>; Mon, 05 Dec 2016 10:26:44 -0800 (PST)
In-Reply-To: <20161205041815.GE4310@u54ee753d2d1854bda401.ant.amazon.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


On 12/05/2016 06:18 AM, Matt Wilson wrote:
> On Sun, Dec 04, 2016 at 03:19:22PM +0200, Netanel Belgazal wrote:
>> ena_flow_data_to_flow_hash and ena_flow_hash_to_flow_type
>> treat the ena_flow_hash_to_flow_type enum as power of two values.
>>
>> Change the values of ena_admin_flow_hash_fields to be power of two values.
> Then I generally prefer BIT(0), BIT(1), BIT(2), etc.

I'll use BIT(x)

>
> Also it would be helpful to include some comments about the
> consequences of the current state of the code.

I'll add explanation.

>
> --msw
>
>> Signed-off-by: Netanel Belgazal <netanel@annapurnalabs.com>
>> ---
>>   drivers/net/ethernet/amazon/ena/ena_admin_defs.h | 12 ++++++------
>>   1 file changed, 6 insertions(+), 6 deletions(-)
>>
>> diff --git a/drivers/net/ethernet/amazon/ena/ena_admin_defs.h b/drivers/net/ethernet/amazon/ena/ena_admin_defs.h
>> index a46e749..f48c886 100644
>> --- a/drivers/net/ethernet/amazon/ena/ena_admin_defs.h
>> +++ b/drivers/net/ethernet/amazon/ena/ena_admin_defs.h
>> @@ -631,22 +631,22 @@ enum ena_admin_flow_hash_proto {
>>   /* RSS flow hash fields */
>>   enum ena_admin_flow_hash_fields {
>>   	/* Ethernet Dest Addr */
>> -	ENA_ADMIN_RSS_L2_DA	= 0,
>> +	ENA_ADMIN_RSS_L2_DA	= 0x1,
>>   
>>   	/* Ethernet Src Addr */
>> -	ENA_ADMIN_RSS_L2_SA	= 1,
>> +	ENA_ADMIN_RSS_L2_SA	= 0x2,
>>   
>>   	/* ipv4/6 Dest Addr */
>> -	ENA_ADMIN_RSS_L3_DA	= 2,
>> +	ENA_ADMIN_RSS_L3_DA	= 0x4,
>>   
>>   	/* ipv4/6 Src Addr */
>> -	ENA_ADMIN_RSS_L3_SA	= 5,
>> +	ENA_ADMIN_RSS_L3_SA	= 0x8,
>>   
>>   	/* tcp/udp Dest Port */
>> -	ENA_ADMIN_RSS_L4_DP	= 6,
>> +	ENA_ADMIN_RSS_L4_DP	= 0x10,
>>   
>>   	/* tcp/udp Src Port */
>> -	ENA_ADMIN_RSS_L4_SP	= 7,
>> +	ENA_ADMIN_RSS_L4_SP	= 0x20,
>>   };
>>   
>>   struct ena_admin_proto_input {
