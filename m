From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next v4 2/8] 6lowpan: add uncompress header size
 function
Date: Wed, 26 Feb 2014 13:56:26 -0500 (EST)
Message-ID: <20140226.135626.324803150478038779.davem@davemloft.net>
References: <1393430712-11298-1-git-send-email-alex.aring@gmail.com>
	<1393430712-11298-3-git-send-email-alex.aring@gmail.com>
	<063D6719AE5E284EB5DD2968C1650D6D0F6CBBCA@AcuExch.aculab.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: alex.aring@gmail.com, alex.bluesman.smirnov@gmail.com,
	dbaryshkov@gmail.com, linux-zigbee-devel@lists.sourceforge.net,
	netdev@vger.kernel.org, martin.townsend@xsilon.com
To: David.Laight@ACULAB.COM
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:40087 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752720AbaBZS43 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 26 Feb 2014 13:56:29 -0500
In-Reply-To: <063D6719AE5E284EB5DD2968C1650D6D0F6CBBCA@AcuExch.aculab.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: David Laight <David.Laight@ACULAB.COM>
Date: Wed, 26 Feb 2014 16:10:05 +0000

> From: Alexander Aring
>> Signed-off-by: Alexander Aring <alex.aring@gmail.com>
>> ---
>>  net/ieee802154/6lowpan.h | 116 +++++++++++++++++++++++++++++++++++++++++++++++
>>  1 file changed, 116 insertions(+)
>> 
>> diff --git a/net/ieee802154/6lowpan.h b/net/ieee802154/6lowpan.h
>> index 2b835db..b6ae0bc 100644
>> --- a/net/ieee802154/6lowpan.h
>> +++ b/net/ieee802154/6lowpan.h
>> @@ -306,6 +306,122 @@ static inline void lowpan_push_hc_data(u8 **hc_ptr, const void *data,
>>  	*hc_ptr += len;
>>  }
>> 
>> +static inline u8 lowpan_addr_mode_size(const u8 addr_mode)
>> +{
>> +	switch (addr_mode) {
>> +	case LOWPAN_IPHC_ADDR_00:
>> +		return 16;
>> +	case LOWPAN_IPHC_ADDR_01:
>> +		return 8;
>> +	case LOWPAN_IPHC_ADDR_02:
>> +		return 2;
>> +	default:
>> +		return 0;
>> +	}
>> +}
> 
> The compiler will generate much better code if you index an array instead
> of using a switch statement.

And please mark the array const :-)
