From: Sergei Shtylyov <sergei.shtylyov@cogentembedded.com>
Subject: Re: [PATCH] rcar_can: add device tree support
Date: Thu, 03 Jul 2014 01:43:17 +0400
Message-ID: <53B47CF5.4010105@cogentembedded.com>
References: <201407020227.04235.sergei.shtylyov@cogentembedded.com> <53B33B45.1060205@pengutronix.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8; format=flowed
Content-Transfer-Encoding: 7bit
Cc: linux-sh@vger.kernel.org, vksavl@gmail.com, rdunlap@infradead.org,
	linux-doc@vger.kernel.org
To: Marc Kleine-Budde <mkl@pengutronix.de>, netdev@vger.kernel.org,
	wg@grandegger.com, linux-can@vger.kernel.org, robh+dt@kernel.org,
	pawel.moll@arm.com, mark.rutland@arm.com,
	ijc+devicetree@hellion.org.uk, galak@codeaurora.org,
	grant.likely@linaro.org, devicetree@vger.kernel.org
Return-path: <linux-sh-owner@vger.kernel.org>
In-Reply-To: <53B33B45.1060205@pengutronix.de>
Sender: linux-sh-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hello.

On 07/02/2014 02:50 AM, Marc Kleine-Budde wrote:

>> Add support of the device tree probing for the Renesas R-Car CAN controllers
>> documenting the device tree bindings as necessary.

> Please put the DT documentation into a separate patch, make it the first

    OK.

> one. When reposting, please put the device tree mailing list on Cc.

    It was among the To: recipients in this posting; I'm using 
scripts/get_maintainer.pl to find out the people/lists I should send the 
patches to.

>> Signed-off-by: Sergei Shtylyov <sergei.shtylyov@cogentembedded.com>

>> ---
>> The patch is against the Dave Miller's 'net-next.git' repo ('linux-can-next.git'
>> repo still doesn't have the R-Car CAN driver for some reason).

> Should be fixed now :)

    Indeed, thanks.

>>   Documentation/devicetree/bindings/net/can/rcar_can.txt |   40 +++++++++++++++++
>>   drivers/net/can/rcar_can.c                             |   28 +++++++++--
>>   2 files changed, 63 insertions(+), 5 deletions(-)

>> Index: net-next/Documentation/devicetree/bindings/net/can/rcar_can.txt
>> ===================================================================
>> --- /dev/null
>> +++ net-next/Documentation/devicetree/bindings/net/can/rcar_can.txt
>> @@ -0,0 +1,40 @@
>> +Renesas R-Car CAN controller Device Tree Bindings
>> +-------------------------------------------------
>> +
>> +Required properties:
>> +- compatible: "renesas,can-r8a7778" if CAN controller is a part of R8A7778 SoC.
>> +	      "renesas,can-r8a7779" if CAN controller is a part of R8A7779 SoC.
>> +	      "renesas,can-r8a7790" if CAN controller is a part of R8A7790 SoC.
>> +	      "renesas,can-r8a7791" if CAN controller is a part of R8A7791 SoC.

> AFAIK we usually specify the first SoC with this core as the only
> compatible.

    The reason we've chosen several SoC specific "compatible" props is that in 
the SH-Mobile community the maintainers want it this way. There's no version 
register in the IP blocks and the SoC manuals we have are not considered 
reliable enough sources of information, so that the compatibility between the 
different SoCs cannot be reliably established...

[...]
>> Index: net-next/drivers/net/can/rcar_can.c
>> ===================================================================
>> --- net-next.orig/drivers/net/can/rcar_can.c
>> +++ net-next/drivers/net/can/rcar_can.c
[...]
>> @@ -722,13 +723,20 @@ static int rcar_can_probe(struct platfor
>>   	struct net_device *ndev;
>>   	struct resource *mem;
>>   	void __iomem *addr;
>> +	u32 clock_select = 0;
>>   	int err = -ENODEV;
>>   	int irq;
>>
>> -	pdata = dev_get_platdata(&pdev->dev);
>> -	if (!pdata) {
>> -		dev_err(&pdev->dev, "No platform data provided!\n");
>> -		goto fail;
>> +	if (!pdev->dev.of_node) {

> nitpick: please make it positive logic.

    OK, will do.

> Marc

WBR, Sergei

