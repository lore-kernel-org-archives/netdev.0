From: Edward Cree <ecree@solarflare.com>
Subject: Re: [PATCH net-next 2/3] sfc: refactor debug-or-warnings printks
Date: Fri, 27 Jan 2017 11:34:00 +0000
Message-ID: <9ab7fb24-f756-81d4-bdc6-44d9b1755352@solarflare.com>
References: <39d8923f-4400-506c-dd50-250636ff83fa@solarflare.com>
 <15f3ecb9-1785-8688-93b9-51d400ee12bc@solarflare.com>
 <20170126.143629.337763461510725581.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: <linux-net-drivers@solarflare.com>, <netdev@vger.kernel.org>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from nbfkord-smmo01.seg.att.com ([209.65.160.76]:61562 "EHLO
        nbfkord-smmo01.seg.att.com" rhost-flags-OK-OK-OK-OK)
        by vger.kernel.org with ESMTP id S934061AbdA0LeZ (ORCPT
        <rfc822;netdev@vger.kernel.org>); Fri, 27 Jan 2017 06:34:25 -0500
In-Reply-To: <20170126.143629.337763461510725581.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 26/01/17 19:36, David Miller wrote:
> From: Edward Cree <ecree@solarflare.com>
> Date: Thu, 26 Jan 2017 17:53:48 +0000
>
>> diff --git a/drivers/net/ethernet/sfc/net_driver.h b/drivers/net/ethernet/sfc/net_driver.h
>> index 5927c20..c640955 100644
>> --- a/drivers/net/ethernet/sfc/net_driver.h
>> +++ b/drivers/net/ethernet/sfc/net_driver.h
>> @@ -51,6 +51,15 @@
>>  #define EFX_WARN_ON_PARANOID(x) do {} while (0)
>>  #endif
>>  
>> +/* if @cond then downgrade to debug, else print at @level */
>> +#define netif_cond_dbg(priv, type, netdev, cond, level, fmt, args...)     \
>> +	do {                                                              \
>> +		if (cond)                                                 \
>> +			netif_dbg(priv, type, netdev, fmt, ##args);       \
>> +		else                                                      \
>> +			netif_ ## level(priv, type, netdev, fmt, ##args); \
>> +	} while (0)
>> +
>>  /**************************************************************************
>>   *
>>   * Efx data structures
>>
> Please do not define locally in a driver an interface that looks like a generic
> one and might be useful to code outside of your driver.
>
> Thanks.

Sure.  I'll put this in netdevice.h and respin.

-Ed
