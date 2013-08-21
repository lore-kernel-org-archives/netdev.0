From: Sergei Shtylyov <sergei.shtylyov@cogentembedded.com>
Subject: Re: [PATCH 2/2] sh_eth: remove 'register_type' field from 'struct
 sh_eth_plat_data'
Date: Wed, 21 Aug 2013 16:49:52 +0400
Message-ID: <5214B770.5000807@cogentembedded.com>
References: <201308180308.39941.sergei.shtylyov@cogentembedded.com> <2784326.CAqkc6T846@avalon> <5213F548.5040103@cogentembedded.com> <20555348.Y63SQY2deS@avalon>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, davem@davemloft.net, lethal@linux-sh.org,
	linux-sh@vger.kernel.org
To: Laurent Pinchart <laurent.pinchart@ideasonboard.com>
Return-path: <linux-sh-owner@vger.kernel.org>
In-Reply-To: <20555348.Y63SQY2deS@avalon>
Sender: linux-sh-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hello.

On 21-08-2013 4:39, Laurent Pinchart wrote:

>>>>>>> Now that the 'register_type' field of the 'sh_eth' driver's platform
>>>>>>> data is not used by the driver anymore, it's time to remove it and
>>>>>>> its initializers from the SH platform code. Also  move *enum*
>>>>>>> declaring values for this  field from <linux/sh_eth.h>  to  the  local
>>>>>>> driver's header file as they're only needed by the driver itself
>>>>>>> now...

>>>>>>> Signed-off-by: Sergei Shtylyov <sergei.shtylyov@cogentembedded.com>

>>>> [...]

>>>>>>>     /* Driver's parameters */
>>>>>>>     #if defined(CONFIG_CPU_SH4) || defined(CONFIG_ARCH_SHMOBILE)
>>>>>>>     #define SH4_SKB_RX_ALIGN    32
>>>>>>>
>>>>>>> Index: net-next/include/linux/sh_eth.h
>>>>>>> ===================================================================
>>>>>>> --- net-next.orig/include/linux/sh_eth.h
>>>>>>> +++ net-next/include/linux/sh_eth.h
>>>>>>> @@ -5,17 +5,10 @@
>>>>>>>
>>>>>>>     #include <linux/if_ether.h>
>>>>>>>
>>>>>>>     enum {EDMAC_LITTLE_ENDIAN, EDMAC_BIG_ENDIAN};
>>>>>>>
>>>>>>> -enum {
>>>>>>> -    SH_ETH_REG_GIGABIT,
>>>>>>> -    SH_ETH_REG_FAST_RCAR,
>>>>>>> -    SH_ETH_REG_FAST_SH4,
>>>>>>> -    SH_ETH_REG_FAST_SH3_SH2
>>>>>>> -};
>>>>>>>
>>>>>>>     struct sh_eth_plat_data {
>>>>>>>
>>>>>>>         int phy;
>>>>>>>         int edmac_endian;

>>>>>> Wouldn't it make sense to move the edmac_endian field to
>>>>>> sh_eth_cpu_data as well ?

>>>>> No, it depends on the SoC endianness which is determined by power-on pin
>>>>> strapping -- which is board specific.

>>> Does SoC endianness affect the ARM core endianness, the ethernet registers
>>> endianness, or both ?

>> Both, AFAIK.

>>> If it affects the ARM core endianness only, the kernel needs to be
>>> compiled in little-endian or big-endian mode anyway, and the sh_eth driver
>>> should use cpu_to_le32() unconditionally. If it affects both the ARM core
>>> and the ethernet controller there's not need to care about the endianness,
>>> as it will always be good.

>> No, it won't unless you're using __raw_{readl|writel}() accessors. The
>> driver doesn't do it. {readl|writel}() and io{read|write}32() that use them
>> always assume LE ordering of memory.

>>> We only need to care about it if it affects the ethernet controller
>>> registers only, which would seem weird to me.

>> Unfortunately, you are wrong.

> Care to explain *why* ? There might be bugs in the driver (such as using the
> wrong I/O accessors), but I don't see why we need to configure the endianness
> through platform data.

    Re-read my reply about the power-on pin strapping please. The SoC 
endianness setting gets read from the external source to the SoC, i.e. it's 
determined by the board.

WBR, Sergei

