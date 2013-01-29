From: Mugunthan V N <mugunthanvnm@ti.com>
Subject: Re: [PATCH 2/2] drivers: net:ethernet: cpsw: add support for VLAN
Date: Tue, 29 Jan 2013 10:35:05 +0530
Message-ID: <51075881.4050200@ti.com>
References: <1359403945-28585-1-git-send-email-mugunthanvnm@ti.com> <1359403945-28585-3-git-send-email-mugunthanvnm@ti.com> <20130128204446.GB5509@arwen.pp.htv.fi>
Mime-Version: 1.0
Content-Type: text/plain; charset="ISO-8859-1"; format=flowed
Content-Transfer-Encoding: 7bit
Cc: <netdev@vger.kernel.org>, <davem@davemloft.net>,
	<linux-arm-kernel@lists.infradead.org>,
	<linux-omap@vger.kernel.org>
To: <balbi@ti.com>
Return-path: <linux-omap-owner@vger.kernel.org>
In-Reply-To: <20130128204446.GB5509@arwen.pp.htv.fi>
Sender: linux-omap-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On 1/29/2013 2:14 AM, Felipe Balbi wrote:
> On Tue, Jan 29, 2013 at 01:42:25AM +0530, Mugunthan V N wrote:
>> adding support for VLAN interface for cpsw.
>>
>> CPSW VLAN Capability
>> * Can filter VLAN packets in Hardware
>>
>> Signed-off-by: Mugunthan V N <mugunthanvnm@ti.com>
>> ---
>>   Documentation/devicetree/bindings/net/cpsw.txt |    2 +
>>   drivers/net/ethernet/ti/cpsw.c                 |  108 +++++++++++++++++++++++-
>>   include/linux/platform_data/cpsw.h             |    1 +
>>   3 files changed, 110 insertions(+), 1 deletion(-)
>>
>> diff --git a/Documentation/devicetree/bindings/net/cpsw.txt b/Documentation/devicetree/bindings/net/cpsw.txt
>> index 6ddd028..99696bf 100644
>> --- a/Documentation/devicetree/bindings/net/cpsw.txt
>> +++ b/Documentation/devicetree/bindings/net/cpsw.txt
>> @@ -24,6 +24,8 @@ Required properties:
>>   Optional properties:
>>   - ti,hwmods		: Must be "cpgmac0"
>>   - no_bd_ram		: Must be 0 or 1
>> +- default_vlan		: Specifies Default VLAN for non tagged packets
>> +			  ALE processing
>>   
>>   Note: "ti,hwmods" field is used to fetch the base address and irq
>>   resources from TI, omap hwmod data base during device registration.
>> diff --git a/drivers/net/ethernet/ti/cpsw.c b/drivers/net/ethernet/ti/cpsw.c
>> index b35e6a7..dee6951 100644
>> --- a/drivers/net/ethernet/ti/cpsw.c
>> +++ b/drivers/net/ethernet/ti/cpsw.c
>> @@ -32,6 +32,7 @@
>>   #include <linux/of.h>
>>   #include <linux/of_net.h>
>>   #include <linux/of_device.h>
>> +#include <linux/if_vlan.h>
>>   
>>   #include <linux/platform_data/cpsw.h>
>>   
>> @@ -72,6 +73,11 @@ do {								\
>>   		dev_notice(priv->dev, format, ## __VA_ARGS__);	\
>>   } while (0)
>>   
>> +#if defined(CONFIG_VLAN_8021Q) || defined(CONFIG_VLAN_8021Q_MODULE)
> use IS_ENABLED() instead.
Will change this in next patch version.
>
>> +#define VLAN_SUPPORT
>> +#define CPSW_VLAN_AWARE_MODE
>> +#endif
>> +
>>   #define ALE_ALL_PORTS		0x7
>>   
>>   #define CPSW_MAJOR_VERSION(reg)		(reg >> 8 & 0x7)
>> @@ -118,6 +124,14 @@ do {								\
>>   #define TX_PRIORITY_MAPPING	0x33221100
>>   #define CPDMA_TX_PRIORITY_MAP	0x76543210
>>   
>> +#ifdef CPSW_VLAN_AWARE_MODE
>> +#define CPSW_VLAN_AWARE		BIT(1)
>> +#define CPSW_ALE_VLAN_AWARE	1
>> +#else
>> +#define CPSW_VLAN_AWARE		0x0
>> +#define CPSW_ALE_VLAN_AWARE	0
>> +#endif
> you should really figure out a way of doing runtime detection for this.
> Depending on driver recompilation just to enable/disable VLAN support
> will be quite boring.
I am not able to find a way to know whether stack is compiled with VLAN 
support or not
without using VLAN_SUPPORT compiler option. Only way is to hack 
cpsw_ndo_vlan_rx_add_vid
and know whether stack has VLAN capability or not which is not advisable.

Regards
Mugunthan V N
