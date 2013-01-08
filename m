From: Oliver Hartkopp <oliver.hartkopp@volkswagen.de>
Subject: Re: [RFC PATCH net-next] can-gw: add a variable limit for CAN frame
 routings
Date: Tue, 08 Jan 2013 11:26:27 +0100
Message-ID: <50EBF453.7020408@volkswagen.de>
References: <50EB4377.6030306@hartkopp.net> <50EBDB94.3000705@pengutronix.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Linux Netdev List <netdev@vger.kernel.org>,
	Linux CAN List <linux-can@vger.kernel.org>
To: Marc Kleine-Budde <mkl@pengutronix.de>
Return-path: <linux-can-owner@vger.kernel.org>
In-Reply-To: <50EBDB94.3000705@pengutronix.de>
Sender: linux-can-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Am 08.01.2013 09:40, schrieb Marc Kleine-Budde:
> On 01/07/2013 10:51 PM, Oliver Hartkopp wrote:


>>
>>   static __init int cgw_module_init(void)
>>   {
>> -	printk(banner);
>> +	/* sanitize given module parameter */
>> +	if (max_hops < 1)
>> +		max_hops = 1;
>> +
>> +	if (max_hops > CAN_GW_MAX_HOPS)
>> +		max_hops = CAN_GW_MAX_HOPS;
>
> You can make use of clamp(val, min, max) here.
>

ok.

I added

	#include <linux/kernel.h>

where clamp is defined and reduced the code above to

clamp_t(unsigned int, max_hops, CAN_GW_MIN_HOPS, CAN_GW_MAX_HOPS);

Unfortunately clamp(max_hops, CAN_GW_MIN_HOPS, CAN_GW_MAX_HOPS) did not work.

=> (warning: comparison of distinct pointer types lacks a cast)

Will send the v2 when there're no other remarks tommorrow.

Tnx,
Oliver

