From: Divy Le Ray <divy@chelsio.com>
Subject: Re: [RFC] split NAPI from network device.
Date: Tue, 20 Feb 2007 23:39:55 -0800
Message-ID: <45DBF74B.7070801@chelsio.com>
References: <20061213113537.6baf410f@dxpl.pdx.osdl.net>	<1166042552.11914.188.camel@localhost.localdomain>	<20061213154635.1f284bf6@dxpl.pdx.osdl.net> <20070220.213125.74747066.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: shemminger@osdl.org, benh@kernel.crashing.org,
	netdev@vger.kernel.org, ebs@ebshome.net,
	linux-kernel@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from stargate.chelsio.com ([12.22.49.110]:7832 "EHLO
	stargate.chelsio.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1161113AbXBUHkm (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 21 Feb 2007 02:40:42 -0500
In-Reply-To: <20070220.213125.74747066.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

David Miller wrote:
> From: Stephen Hemminger <shemminger@osdl.org>
> Date: Wed, 13 Dec 2006 15:46:35 -0800
>
>   
>> Split off NAPI part from network device, this patch is build tested
>> only! It breaks kernel API for network devices, and only three examples
>> are fixed (skge, sky2, and tg3).
>>
>> 1. Decomposition allows different NAPI <-> network device
>>    Some hardware has N devices for one IRQ, others like MSI-X
>>    want multiple receive's for one device.
>>
>> 2. Cleanup locking with netpoll
>>
>> 3. Change poll callback arguements and semantics
>>
>> 4. Make softnet_data static (only in dev.c)
>>
>> Old:
>> 	dev->poll(dev, &budget)
>> 	returns 1 or 0
>> 	requeu if returns 1
>>
>> New:
>> 	napi->poll(napi, quota)
>> 	returns # of elements processed
>> 	requeue based on status
>>
>> Signed-off-by: Stephen Hemminger <shemminger@osdl.org>
>>     
>
> I rebuffed this patch against current 2.6.x GIT and fixed all of
> the drivers.
>
>   
Hi Dave,

I applied the patch to test the chelsio drivers.
The compilation of the forcedeth driver fails if CONFIG_FORCEDETH_NAPI 
is not set.
/opt/sources/linux-2.6/drivers/net/forcedeth.c: In function `nv_nic_irq':
/opt/sources/linux-2.6/drivers/net/forcedeth.c:2866: error: structure 
has no member named `weight'
/opt/sources/linux-2.6/drivers/net/forcedeth.c: In function 
`nv_nic_irq_optimized':
/opt/sources/linux-2.6/drivers/net/forcedeth.c:2983: error: structure 
has no member named `weight'
/opt/sources/linux-2.6/drivers/net/forcedeth.c: In function `nv_nic_irq_rx':
/opt/sources/linux-2.6/drivers/net/forcedeth.c:3177: error: structure 
has no member named `weight'

The compilation of the cxgb driver also fails if CONFIG_CHELSIO_T1_NAPI 
is not set, but it has nothing to do with your patch.
I'm looking into it.

Cheers,
Divy
