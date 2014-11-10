From: Saeed Mahameed <saeedm@dev.mellanox.co.il>
Subject: Re: [PATCH net-next 05/13] ethtool,net/mlx4_en: Add 100M, 20G, 56G
 speeds ethtool reporting support
Date: Mon, 10 Nov 2014 12:30:02 +0200
Message-ID: <546093AA.8050005@dev.mellanox.co.il>
References: <1414402667-8841-1-git-send-email-amirv@mellanox.com>	 <1414402667-8841-6-git-send-email-amirv@mellanox.com> <1415227117.3398.31.camel@decadent.org.uk>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8; format=flowed
Content-Transfer-Encoding: 7bit
Cc: "David S. Miller" <davem@davemloft.net>, netdev@vger.kernel.org,
	Yevgeny Petrilin <yevgenyp@mellanox.com>,
	Or Gerlitz <ogerlitz@mellanox.com>,
	Saeed Mahameed <saeedm@mellanox.com>
To: Ben Hutchings <ben@decadent.org.uk>,
	Amir Vadai <amirv@mellanox.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wi0-f180.google.com ([209.85.212.180]:65393 "EHLO
	mail-wi0-f180.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751913AbaKJKaQ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 10 Nov 2014 05:30:16 -0500
Received: by mail-wi0-f180.google.com with SMTP id hi2so9832115wib.7
        for <netdev@vger.kernel.org>; Mon, 10 Nov 2014 02:30:07 -0800 (PST)
In-Reply-To: <1415227117.3398.31.camel@decadent.org.uk>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


On 11/6/2014 12:38 AM, Ben Hutchings wrote:
> On Mon, 2014-10-27 at 11:37 +0200, Amir Vadai wrote:
>> From: Saeed Mahameed <saeedm@mellanox.com>
>>
>> Added 100M, 20G and 56G ethtool speed reporting support.
>> Update mlx4_en_test_speed self test with the new speeds.
>>
>> Defined new link speeds in include/uapi/linux/ethtool.h:
>> +#define SPEED_20000	20000
>> +#define SPEED_40000	40000
>> +#define SPEED_56000	56000
>>
>> Signed-off-by: Saeed Mahameed <saeedm@mellanox.com>
>> Signed-off-by: Amir Vadai <amirv@mellanox.com>
> [...]
>> --- a/include/uapi/linux/ethtool.h
>> +++ b/include/uapi/linux/ethtool.h
>> @@ -1213,6 +1213,10 @@ enum ethtool_sfeatures_retval_bits {
>>   #define SUPPORTED_40000baseCR4_Full	(1 << 24)
>>   #define SUPPORTED_40000baseSR4_Full	(1 << 25)
>>   #define SUPPORTED_40000baseLR4_Full	(1 << 26)
>> +#define SUPPORTED_56000baseKR4_Full	(1 << 27)
>> +#define SUPPORTED_56000baseCR4_Full	(1 << 28)
>> +#define SUPPORTED_56000baseSR4_Full	(1 << 29)
>> +#define SUPPORTED_56000baseLR4_Full	(1 << 30)
>>   
>>   #define ADVERTISED_10baseT_Half		(1 << 0)
>>   #define ADVERTISED_10baseT_Full		(1 << 1)
>> @@ -1241,6 +1245,10 @@ enum ethtool_sfeatures_retval_bits {
>>   #define ADVERTISED_40000baseCR4_Full	(1 << 24)
>>   #define ADVERTISED_40000baseSR4_Full	(1 << 25)
>>   #define ADVERTISED_40000baseLR4_Full	(1 << 26)
>> +#define ADVERTISED_56000baseKR4_Full	(1 << 27)
>> +#define ADVERTISED_56000baseCR4_Full	(1 << 28)
>> +#define ADVERTISED_56000baseSR4_Full	(1 << 29)
>> +#define ADVERTISED_56000baseLR4_Full	(1 << 30)
> Can these modes be auto-negotiated?  If not then they don't need
> advertised/supported bits.
Hi Ben,
At least 56000baseKR4_Full and 56000baseCR4_Full can be negotiated for sure,
regarding SR and LR i will check with arch team.
>>   /* The following are all involved in forcing a particular link
>>    * mode for the device for setting things.  When getting the
>> @@ -1248,12 +1256,16 @@ enum ethtool_sfeatures_retval_bits {
>>    * it was forced up into this mode or autonegotiated.
>>    */
>>   
>> -/* The forced speed, 10Mb, 100Mb, gigabit, 2.5Gb, 10GbE. */
>> +/* The forced speed, 10Mb, 100Mb, gigabit, [2.5|10|20|40|56]GbE. */
>>   #define SPEED_10		10
>>   #define SPEED_100		100
>>   #define SPEED_1000		1000
>>   #define SPEED_2500		2500
>>   #define SPEED_10000		10000
>> +#define SPEED_20000		20000
>> +#define SPEED_40000		40000
>> +#define SPEED_56000		56000
> We shouldn't add new SPEED macros.  The speed is just a number of Mbit/s
> and we don't need to enumerate the possible values.
It is a little bit confusing that some speeds still use the defines 
above, and new speeds should be hardcoded.
Why those speeds still there? is it some kind of work that need to be 
done (i.e remove all of those defines) or are they needed in other 
situations.
I thought it is nice that well-known speeds are organized in such MACROs 
and this will prevent drivers from using magic numbers in their code.

Thanks for your time,
-Saeed.

>
> Ben.
>
>>   #define SPEED_UNKNOWN		-1
>>   
>>   /* Duplex, half or full. */
