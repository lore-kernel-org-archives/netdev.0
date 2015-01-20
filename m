From: Murali Karicheri <m-karicheri2-l0cyMroinI0@public.gmane.org>
Subject: Re: [PATCH net-next v8 2/4] net: netcp: Add Keystone NetCP core ethernet
 driver
Date: Tue, 20 Jan 2015 10:55:41 -0500
Message-ID: <54BE7A7D.8090804@ti.com>
References: <1421367172-19793-1-git-send-email-m-karicheri2@ti.com>  <1421367172-19793-2-git-send-email-m-karicheri2@ti.com> <1421741935.9655.73.camel@x220>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Wingman Kwok <w-kwok2-l0cyMroinI0@public.gmane.org>,
	Valentin Rothberg <valentinrothberg-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>,
	<davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>, <devicetree-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
	<linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>, <netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
To: Paul Bolle <pebolle-IWqWACnzNjzz+pZb47iToQ@public.gmane.org>
Return-path: <devicetree-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <1421741935.9655.73.camel@x220>
Sender: devicetree-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

On 01/20/2015 03:18 AM, Paul Bolle wrote:
> Murali, Wingman,
>
> On Thu, 2015-01-15 at 19:12 -0500, Murali Karicheri wrote:
>> The network coprocessor (NetCP) is a hardware accelerator available in
>> Keystone SoCs that processes Ethernet packets. NetCP consists of following
>> hardware components
>>
>>   1 Gigabit Ethernet (GbE) subsystem with a Ethernet switch sub-module to
>>     send and receive packets.
>>   2 Packet Accelerator (PA) module to perform packet classification
>>     operations such as header matching, and packet modification operations
>>     such as checksum generation.
>>   3 Security Accelerator(SA) capable of performing IPSec operations on
>>     ingress/egress packets.
>>   4 An optional 10 Gigabit Ethernet Subsystem (XGbE) which includes a
>>     3-port Ethernet switch sub-module capable of 10Gb/s and 1Gb/s rates
>>     per Ethernet port.
>>   5 Packet DMA and Queue Management Subsystem (QMSS) to enqueue and dequeue
>>     packets and DMA the packets between memory and NetCP hardware components
>>     described above.
>>
>> NetCP core driver make use of the Keystone Navigator driver API to allocate
>> DMA channel for the Ethenet device and to handle packet queue/de-queue,
>> Please refer API's in include/linux/soc/ti/knav_dma.h and
>> drivers/soc/ti/knav_qmss.h for details.
>>
>> NetCP driver consists of NetCP core driver and at a minimum Gigabit
>> Ethernet (GBE) module (1) driver to implement the Network device function.
>> Other modules (2,3) can be optionally added to achieve supported hardware
>> acceleration function. The initial version of the driver include NetCP
>> core driver and GBE driver modules.
>>
>> Please refer Documentation/devicetree/bindings/net/keystone-netcp.txt
>> for design of the driver.
>>
>>   Cc: David Miller<davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>
>>   Cc: Rob Herring<robh+dt-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org>
>>   Cc: Grant Likely<grant.likely-QSEj5FYQhm4dnm+yROfE0A@public.gmane.org>
>>   Cc: Santosh Shilimkar<santosh.shilimkar-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org>
>>   Cc: Pawel Moll<pawel.moll-5wv7dgnIgG8@public.gmane.org>
>>   Cc: Mark Rutland<mark.rutland-5wv7dgnIgG8@public.gmane.org>
>>   Cc: Ian Campbell<ijc+devicetree-KcIKpvwj1kUDXYZnReoRVg@public.gmane.org>
>>   Cc: Kumar Gala<galak-sgV2jX0FEOL9JmXXK+q4OQ@public.gmane.org>
>>
>> Signed-off-by: Murali Karicheri<m-karicheri2-l0cyMroinI0@public.gmane.org>
>> Signed-off-by: Wingman Kwok<w-kwok2-l0cyMroinI0@public.gmane.org>
>
> This patch is included as commit 84640e27f230 ("net: netcp: Add Keystone
> NetCP core ethernet driver") in today's linux-next. I noticed because a
> script I run on linux-next spotted a problem in it.
>
>> ---
>>   MAINTAINERS                          |    7 +
>>   drivers/net/ethernet/ti/Kconfig      |   11 +
>>   drivers/net/ethernet/ti/Makefile     |    3 +
>>   drivers/net/ethernet/ti/netcp.h      |  229 ++++
>>   drivers/net/ethernet/ti/netcp_core.c | 2141 ++++++++++++++++++++++++++++++++++
>>   5 files changed, 2391 insertions(+)
>>   create mode 100644 drivers/net/ethernet/ti/netcp.h
>>   create mode 100644 drivers/net/ethernet/ti/netcp_core.c
>>
>> [...]
>> diff --git a/drivers/net/ethernet/ti/Kconfig b/drivers/net/ethernet/ti/Kconfig
>> index 605dd90..e11bcfa 100644
>> --- a/drivers/net/ethernet/ti/Kconfig
>> +++ b/drivers/net/ethernet/ti/Kconfig
>> @@ -73,12 +73,23 @@ config TI_CPSW
>>   config TI_CPTS
>>   	boolean "TI Common Platform Time Sync (CPTS) Support"
>>   	depends on TI_CPSW
>> +	depends on TI_CPSW || TI_KEYSTONE_NET
>
> You probably meant to add
>      || TI_KEYSTONE_NETCP
>
> here. Ie, add CP. But as this slipped through testing it _might_ not be
> needed at all.
Paul,

I will get back to you on this today.

Thanks

Murali
>
>>   	select PTP_1588_CLOCK
>>   	---help---
>>   	  This driver supports the Common Platform Time Sync unit of
>>   	  the CPSW Ethernet Switch. The unit can time stamp PTP UDP/IPv4
>>   	  and Layer 2 packets, and the driver offers a PTP Hardware Clock.
>>
>> +config TI_KEYSTONE_NETCP
>> +	tristate "TI Keystone NETCP Ethernet subsystem Support"
>> +	depends on OF
>> +	depends on KEYSTONE_NAVIGATOR_DMA&&  KEYSTONE_NAVIGATOR_QMSS
>> +	---help---
>> +	  This driver supports TI's Keystone NETCP Ethernet subsystem.
>> +
>> +	  To compile this driver as a module, choose M here: the module
>> +	  will be called keystone_netcp.
>> +
>>   config TLAN
>>   	tristate "TI ThunderLAN support"
>>   	depends on (PCI || EISA)
>
> Thanks,
>
>
> Paul Bolle
>


-- 
Murali Karicheri
Linux Kernel, Texas Instruments
--
To unsubscribe from this list: send the line "unsubscribe devicetree" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
