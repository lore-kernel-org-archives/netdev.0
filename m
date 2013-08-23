From: Sekhar Nori <nsekhar@ti.com>
Subject: Re: [PATCH v4 3/5] net: ethernet: cpsw: introduce ti,am3352-cpsw
 compatible string
Date: Fri, 23 Aug 2013 22:01:55 +0530
Message-ID: <52178E7B.5070508@ti.com>
References: <1377267365-24057-1-git-send-email-zonque@gmail.com> <1377267365-24057-4-git-send-email-zonque@gmail.com> <52177052.1030308@ti.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: Daniel Mack <zonque@gmail.com>, <netdev@vger.kernel.org>,
	<bcousson@baylibre.com>, <sergei.shtylyov@cogentembedded.com>,
	<davem@davemloft.net>, <ujhelyi.m@gmail.com>,
	<mugunthanvnm@ti.com>, <vaibhav.bedia@ti.com>, <d-gerlach@ti.com>,
	<linux-arm-kernel@lists.infradead.org>,
	<linux-omap@vger.kernel.org>, <devicetree@vger.kernel.org>
To: Santosh Shilimkar <santosh.shilimkar@ti.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from bear.ext.ti.com ([192.94.94.41]:33316 "EHLO bear.ext.ti.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754557Ab3HWQc2 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 23 Aug 2013 12:32:28 -0400
In-Reply-To: <52177052.1030308@ti.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 8/23/2013 7:53 PM, Santosh Shilimkar wrote:
> On Friday 23 August 2013 10:16 AM, Daniel Mack wrote:
>> In order to support features that are specific to the AM335x IP, we have
>> to add hardware types and another compatible string.
>>
>> Signed-off-by: Daniel Mack <zonque@gmail.com>
>> ---
>>  Documentation/devicetree/bindings/net/cpsw.txt |  3 ++-
>>  drivers/net/ethernet/ti/cpsw.c                 | 32 ++++++++++++++++++++------
>>  drivers/net/ethernet/ti/cpsw.h                 |  1 +
>>  3 files changed, 28 insertions(+), 8 deletions(-)
>>
>> diff --git a/Documentation/devicetree/bindings/net/cpsw.txt b/Documentation/devicetree/bindings/net/cpsw.txt
>> index 4e5ca54..b717458 100644
>> --- a/Documentation/devicetree/bindings/net/cpsw.txt
>> +++ b/Documentation/devicetree/bindings/net/cpsw.txt
>> @@ -2,7 +2,8 @@ TI SoC Ethernet Switch Controller Device Tree Bindings
>>  ------------------------------------------------------
>>  
>>  Required properties:
>> -- compatible		: Should be "ti,cpsw"
>> +- compatible		: Should be "ti,cpsw" for generic cpsw support, or
>> +			  "ti,am3352-cpsw" for AM3352 SoCs
>>  - reg			: physical base address and size of the cpsw
>>  			  registers map.
>>  			  An optional third memory region can be supplied if
>> diff --git a/drivers/net/ethernet/ti/cpsw.c b/drivers/net/ethernet/ti/cpsw.c
>> index 7a25ff4..73c44cb6 100644
>> --- a/drivers/net/ethernet/ti/cpsw.c
>> +++ b/drivers/net/ethernet/ti/cpsw.c
>> @@ -155,6 +155,11 @@ do {								\
>>  		((priv->data.dual_emac) ? priv->emac_port :	\
>>  		priv->data.active_slave)
>>  
>> +enum {
>> +	CPSW_TYPE_GENERIC,
>> +	CPSW_TYPE_AM33XX
>> +};
>> +
>>  static int debug_level;
>>  module_param(debug_level, int, 0);
>>  MODULE_PARM_DESC(debug_level, "cpsw debug level (NETIF_MSG bits)");
>> @@ -1692,17 +1697,36 @@ static void cpsw_slave_init(struct cpsw_slave *slave, struct cpsw_priv *priv,
>>  	slave->port_vlan = data->dual_emac_res_vlan;
>>  }
>>  
>> +static const struct of_device_id cpsw_of_mtable[] = {
>> +	{
>> +		.compatible	= "ti,am3352-cpsw",
> I didn't notice this earlier, but can't you use the IP version
> as a compatible instead of using a SOC name. Whats really SOC specific
> on this IP ? Sorry i have missed any earlier discussion on this but
> this approach doesn't seem good. Its like adding SOC checks in the
> driver subsystem.

The objection then should not just be to the name of compatible string,
but to handling AM335x control module register in CPSW driver. What
would be the alternate method of doing what Daniel is doing? I vaguely
remember there were attempts to develop an independent control module
driver that were abandoned.

Thanks,
Sekhar
