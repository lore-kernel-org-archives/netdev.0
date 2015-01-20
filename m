From: Murali Karicheri <m-karicheri2@ti.com>
Subject: Re: [PATCH net-next v8 2/4] net: netcp: Add Keystone NetCP core ethernet
 driver
Date: Tue, 20 Jan 2015 12:10:02 -0500
Message-ID: <54BE8BEA.3000100@ti.com>
References: <1421367172-19793-1-git-send-email-m-karicheri2@ti.com>  <1421367172-19793-2-git-send-email-m-karicheri2@ti.com> <1421741935.9655.73.camel@x220>
Mime-Version: 1.0
Content-Type: multipart/mixed;
	boundary="------------090704000805040104060407"
Cc: Wingman Kwok <w-kwok2@ti.com>,
	Valentin Rothberg <valentinrothberg@gmail.com>,
	<davem@davemloft.net>, <devicetree@vger.kernel.org>,
	<linux-kernel@vger.kernel.org>, <netdev@vger.kernel.org>
To: Paul Bolle <pebolle@tiscali.nl>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1421741935.9655.73.camel@x220>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

--------------090704000805040104060407
Content-Type: text/plain; charset="UTF-8"; format=flowed
Content-Transfer-Encoding: 7bit

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
>>   Cc: David Miller<davem@davemloft.net>
>>   Cc: Rob Herring<robh+dt@kernel.org>
>>   Cc: Grant Likely<grant.likely@linaro.org>
>>   Cc: Santosh Shilimkar<santosh.shilimkar@kernel.org>
>>   Cc: Pawel Moll<pawel.moll@arm.com>
>>   Cc: Mark Rutland<mark.rutland@arm.com>
>>   Cc: Ian Campbell<ijc+devicetree@hellion.org.uk>
>>   Cc: Kumar Gala<galak@codeaurora.org>
>>
>> Signed-off-by: Murali Karicheri<m-karicheri2@ti.com>
>> Signed-off-by: Wingman Kwok<w-kwok2@ti.com>
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

Currently CPTS driver is not used for NetCP. So I want to remove the 
above Kconfig dependency from Kconfig and cpts.o from the Makefile. Do 
you expect me to send an incremental patch for this to the netdev list? 
or can pick the attached patch that addresses this issue. Let me know.

Thanks.

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

--------------090704000805040104060407
Content-Type: text/x-diff;
	name="0001-net-netcp-remove-unused-kconfig-option-and-code.patch"
Content-Transfer-Encoding: 7bit
Content-Disposition: attachment;
	filename="0001-net-netcp-remove-unused-kconfig-option-and-code.patch"

>From 44838a357c691c70762be2978619c6967f0dd220 Mon Sep 17 00:00:00 2001
From: Murali Karicheri <m-karicheri2@ti.com>
Date: Tue, 20 Jan 2015 12:08:43 -0500
Subject: [PATCH] net: netcp: remove unused kconfig option and code

Currently CPTS is built into the netcp driver even though there is no
call out to the CPTS driver. This patch removes the dependency in Kconfig
and remove cpts.o from the Makefile for NetCP.

Signed-off-by: Murali Karicheri <m-karicheri2@ti.com>
---
 drivers/net/ethernet/ti/Kconfig  |    2 +-
 drivers/net/ethernet/ti/Makefile |    2 +-
 2 files changed, 2 insertions(+), 2 deletions(-)

diff --git a/drivers/net/ethernet/ti/Kconfig b/drivers/net/ethernet/ti/Kconfig
index e11bcfa..824e376 100644
--- a/drivers/net/ethernet/ti/Kconfig
+++ b/drivers/net/ethernet/ti/Kconfig
@@ -73,7 +73,7 @@ config TI_CPSW
 config TI_CPTS
 	boolean "TI Common Platform Time Sync (CPTS) Support"
 	depends on TI_CPSW
-	depends on TI_CPSW || TI_KEYSTONE_NET
+	depends on TI_CPSW
 	select PTP_1588_CLOCK
 	---help---
 	  This driver supports the Common Platform Time Sync unit of
diff --git a/drivers/net/ethernet/ti/Makefile b/drivers/net/ethernet/ti/Makefile
index 465d03d..0a9813b 100644
--- a/drivers/net/ethernet/ti/Makefile
+++ b/drivers/net/ethernet/ti/Makefile
@@ -13,4 +13,4 @@ ti_cpsw-y := cpsw_ale.o cpsw.o cpts.o
 
 obj-$(CONFIG_TI_KEYSTONE_NETCP) += keystone_netcp.o
 keystone_netcp-y := netcp_core.o netcp_ethss.o	netcp_sgmii.o \
-			netcp_xgbepcsr.o cpsw_ale.o cpts.o
+			netcp_xgbepcsr.o cpsw_ale.o
-- 
1.7.9.5


--------------090704000805040104060407--
