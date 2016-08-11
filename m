From: Grygorii Strashko <grygorii.strashko@ti.com>
Subject: Re: [PATCH v2] drivers: net: cpsw: fix kmemleak false-positive
 reports for sk buffers
Date: Thu, 11 Aug 2016 15:39:17 +0300
Message-ID: <4655373e-cafc-70ad-443e-9668a81a1d08@ti.com>
References: <20160810170253.31825-1-grygorii.strashko@ti.com>
 <20160810.180020.2223832285502216272.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="windows-1252"; format=flowed
Content-Transfer-Encoding: 7bit
Cc: <netdev@vger.kernel.org>, <mugunthanvnm@ti.com>, <nsekhar@ti.com>,
	<linux-kernel@vger.kernel.org>, <linux-omap@vger.kernel.org>,
	<catalin.marinas@arm.com>
To: David Miller <davem@davemloft.net>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20160810.180020.2223832285502216272.davem@davemloft.net>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On 08/11/2016 04:00 AM, David Miller wrote:
> From: Grygorii Strashko <grygorii.strashko@ti.com>
> Date: Wed, 10 Aug 2016 20:02:53 +0300
>
>> diff --git a/drivers/net/ethernet/ti/cpsw.c b/drivers/net/ethernet/ti/cpsw.c
>> index 0805855..5caef77 100644
>> --- a/drivers/net/ethernet/ti/cpsw.c
>> +++ b/drivers/net/ethernet/ti/cpsw.c
>> @@ -732,6 +732,11 @@ static void cpsw_rx_handler(void *token, int len, int status)
>>  		netif_receive_skb(skb);
>>  		ndev->stats.rx_bytes += len;
>>  		ndev->stats.rx_packets++;
>> +		/* SKB pointer will be stored in CPPI RAM (SRAM) which belongs
>> +		 * to MMIO space, as result false positive memory leak report
>> +		 * will be generated.
>> +		 */
>> +		kmemleak_not_leak(new_skb);
>>  	} else {
>>  		ndev->stats.rx_dropped++;
>>  		new_skb = skb;
>
> There is already a kmemleak_not_leak() statement here in the current
> driver.
>
> Please always develop and generate patches against current sources.
>

Oh. Sorry, I've expected to receive merge notification (as you do 
usually),  but I didn't see it. I'll be more careful in the future.

Sorry again.

-- 
regards,
-grygorii
