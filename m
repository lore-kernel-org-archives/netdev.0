From: Sergei Shtylyov <sergei.shtylyov@cogentembedded.com>
Subject: Re: [PATCH 2/2] sh_eth: remove 'register_type' field from 'struct
 sh_eth_plat_data'
Date: Wed, 21 Aug 2013 02:09:49 +0400
Message-ID: <5213E92D.7070004@cogentembedded.com>
References: <201308180308.39941.sergei.shtylyov@cogentembedded.com> <201308180313.26607.sergei.shtylyov@cogentembedded.com> <3069255.T0Cvttgz9W@avalon> <52137CD5.1040902@cogentembedded.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, davem@davemloft.net, lethal@linux-sh.org,
	linux-sh@vger.kernel.org
To: Laurent Pinchart <laurent.pinchart@ideasonboard.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-lb0-f181.google.com ([209.85.217.181]:44505 "EHLO
	mail-lb0-f181.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751175Ab3HTWJo (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 20 Aug 2013 18:09:44 -0400
Received: by mail-lb0-f181.google.com with SMTP id o10so8847lbi.26
        for <netdev@vger.kernel.org>; Tue, 20 Aug 2013 15:09:43 -0700 (PDT)
In-Reply-To: <52137CD5.1040902@cogentembedded.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hello.

On 08/20/2013 06:27 PM, Sergei Shtylyov wrote:

>>> Now that the 'register_type' field of the 'sh_eth' driver's platform data is
>>> not used by the driver anymore, it's time to remove it and  its
>>> initializers from the SH platform code. Also  move *enum* declaring values
>>> for this  field from <linux/sh_eth.h>  to  the  local driver's  header file
>>> as they're only needed by the driver itself  now...

>>> Signed-off-by: Sergei Shtylyov <sergei.shtylyov@cogentembedded.com>
[...]

>>>   /* Driver's parameters */
>>>   #if defined(CONFIG_CPU_SH4) || defined(CONFIG_ARCH_SHMOBILE)
>>>   #define SH4_SKB_RX_ALIGN    32
>>> Index: net-next/include/linux/sh_eth.h
>>> ===================================================================
>>> --- net-next.orig/include/linux/sh_eth.h
>>> +++ net-next/include/linux/sh_eth.h
>>> @@ -5,17 +5,10 @@
>>>   #include <linux/if_ether.h>
>>>
>>>   enum {EDMAC_LITTLE_ENDIAN, EDMAC_BIG_ENDIAN};
>>> -enum {
>>> -    SH_ETH_REG_GIGABIT,
>>> -    SH_ETH_REG_FAST_RCAR,
>>> -    SH_ETH_REG_FAST_SH4,
>>> -    SH_ETH_REG_FAST_SH3_SH2
>>> -};
>>>
>>>   struct sh_eth_plat_data {
>>>       int phy;
>>>       int edmac_endian;

>> Wouldn't it make sense to move the edmac_endian field to sh_eth_cpu_data as
>> well ?

>     No, it depends on the SoC endianness which is determined by power-on pin
> strapping -- which is board specific.

    BTW, I don't think the driver works correctly in the BE case since it uses 
io{read|write}32() to access the registers and those functions assume LE 
ordering on MMIO.

WBR, Sergei
