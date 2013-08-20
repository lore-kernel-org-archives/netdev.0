From: Sergei Shtylyov <sergei.shtylyov@cogentembedded.com>
Subject: Re: [PATCH 2/2] sh_eth: remove 'register_type' field from 'struct
 sh_eth_plat_data'
Date: Wed, 21 Aug 2013 03:01:28 +0400
Message-ID: <5213F548.5040103@cogentembedded.com>
References: <201308180308.39941.sergei.shtylyov@cogentembedded.com> <52137CD5.1040902@cogentembedded.com> <5213E92D.7070004@cogentembedded.com> <2784326.CAqkc6T846@avalon>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, davem@davemloft.net, lethal@linux-sh.org,
	linux-sh@vger.kernel.org
To: Laurent Pinchart <laurent.pinchart@ideasonboard.com>
Return-path: <linux-sh-owner@vger.kernel.org>
In-Reply-To: <2784326.CAqkc6T846@avalon>
Sender: linux-sh-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On 08/21/2013 02:50 AM, Laurent Pinchart wrote:

>>>>> Now that the 'register_type' field of the 'sh_eth' driver's platform
>>>>> data is not used by the driver anymore, it's time to remove it and  its
>>>>> initializers from the SH platform code. Also  move *enum* declaring
>>>>> values for this  field from <linux/sh_eth.h>  to  the  local driver's
>>>>> header file as they're only needed by the driver itself  now...

>>>>> Signed-off-by: Sergei Shtylyov <sergei.shtylyov@cogentembedded.com>
>> [...]

>>>>>    /* Driver's parameters */
>>>>>    #if defined(CONFIG_CPU_SH4) || defined(CONFIG_ARCH_SHMOBILE)
>>>>>    #define SH4_SKB_RX_ALIGN    32
>>>>>
>>>>> Index: net-next/include/linux/sh_eth.h
>>>>> ===================================================================
>>>>> --- net-next.orig/include/linux/sh_eth.h
>>>>> +++ net-next/include/linux/sh_eth.h
>>>>> @@ -5,17 +5,10 @@
>>>>>
>>>>>    #include <linux/if_ether.h>
>>>>>
>>>>>    enum {EDMAC_LITTLE_ENDIAN, EDMAC_BIG_ENDIAN};
>>>>>
>>>>> -enum {
>>>>> -    SH_ETH_REG_GIGABIT,
>>>>> -    SH_ETH_REG_FAST_RCAR,
>>>>> -    SH_ETH_REG_FAST_SH4,
>>>>> -    SH_ETH_REG_FAST_SH3_SH2
>>>>> -};
>>>>>
>>>>>    struct sh_eth_plat_data {
>>>>>
>>>>>        int phy;
>>>>>        int edmac_endian;

>>>> Wouldn't it make sense to move the edmac_endian field to sh_eth_cpu_data
>>>> as well ?

>>> No, it depends on the SoC endianness which is determined by power-on pin
>>> strapping -- which is board specific.

> Does SoC endianness affect the ARM core endianness, the ethernet registers
> endianness, or both ?

    Both, AFAIK.

> If it affects the ARM core endianness only, the kernel
> needs to be compiled in little-endian or big-endian mode anyway, and the
> sh_eth driver should use cpu_to_le32() unconditionally. If it affects both the
> ARM core and the ethernet controller there's not need to care about the
> endianness, as it will always be good.

    No, it won't unless you're using __raw_{readl|writel}() accessors. The 
driver doesn't do it. {readl|writel}() and io{read|write}32() that use them 
always assume LE ordering of memory.

> We only need to care about it if it
> affects the ethernet controller registers only, which would seem weird to me.

    Unfortunately, you are wrong.

>> BTW, I don't think the driver works correctly in the BE case since it uses
>> io{read|write}32() to access the registers and those functions assume LE
>> ordering on MMIO.

WBR, Sergei

