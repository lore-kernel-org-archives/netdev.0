From: Stefan Wahren <stefan.wahren@i2se.com>
Subject: Re: [PATCH RFC V2 1/2] Documentation: add Device tree bindings for
 QCA7000
Date: Wed, 02 Jul 2014 09:01:48 +0200
Message-ID: <53B3AE5C.6040005@i2se.com>
References: <1404232609-4314-1-git-send-email-stefan.wahren@i2se.com> <1404232609-4314-2-git-send-email-stefan.wahren@i2se.com> <53B2F0D1.6070602@cogentembedded.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, devicetree@vger.kernel.org
To: Sergei Shtylyov <sergei.shtylyov@cogentembedded.com>,
	davem@davemloft.net, robh+dt@kernel.org, pawel.moll@arm.com,
	mark.rutland@arm.com, ijc+devicetree@hellion.org.uk,
	galak@codeaurora.org, f.fainelli@gmail.com, eric.dumazet@gmail.com,
	dave.taht@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from mout.kundenserver.de ([212.227.126.187]:58308 "EHLO
	mout.kundenserver.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751341AbaGBHCI (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 2 Jul 2014 03:02:08 -0400
In-Reply-To: <53B2F0D1.6070602@cogentembedded.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hello Sergei,

Am 01.07.2014 19:33, schrieb Sergei Shtylyov:
> Hello.
>
> On 07/01/2014 08:36 PM, Stefan Wahren wrote:
>
>> This patch adds the Device tree bindings for the
>> Ethernet over SPI protocol driver of the Qualcomm
>> QCA7000 HomePlug GreenPHY.
>
>> Signed-off-by: Stefan Wahren <stefan.wahren@i2se.com>
>> ---
>>   .../devicetree/bindings/net/qca-qca7000-spi.txt    |   47
>> ++++++++++++++++++++
>>   1 file changed, 47 insertions(+)
>>   create mode 100644
>> Documentation/devicetree/bindings/net/qca-qca7000-spi.txt
>
>> diff --git
>> a/Documentation/devicetree/bindings/net/qca-qca7000-spi.txt
>> b/Documentation/devicetree/bindings/net/qca-qca7000-spi.txt
>> new file mode 100644
>> index 0000000..66ff588
>> --- /dev/null
>> +++ b/Documentation/devicetree/bindings/net/qca-qca7000-spi.txt
>> @@ -0,0 +1,47 @@
>> +* Qualcomm QCA7000 (Ethernet over SPI protocol)
>> +
>> +Note: The QCA7000 is useable as a SPI device. In this case it must
>> be defined
>> +as a child of a SPI master in the device tree.
>> +
>> +Required properties:
>> +- compatible : Should be "qca,qca7000"
>> +- reg : Should specify the SPI chip select
>> +- interrupt-parent : Should specify the pHandle of the source interrupt
>
>    This property is not really required, it could be inherited from an
> upper-level node.

should i move this property to the optional properties or drop it from
the properties?

>
>> +- interrupts : The first cell should specify the index of the source
>> interrupt
>> +  and the second cell should specify the trigger type as rising edge
>> +- spi-cpha : Must be set
>> +- spi-cpol: Must be set
>> +
>> +Optional properties:
>> +- spi-max-frequency : Maximum frequency of the SPI bus the chip can
>> operate at.
>> +  Numbers smaller than 1000000 or greater than 16000000 are invalid.
>> Missing
>> +  the property will set the SPI frequency to 8000000 Hertz.
>> +- local-mac-address: 6 bytes, mac address
>
>    s/mac/MAC/.

I assume that the replacement should apply only to the property
description not to the property name.

>
>
>> +- qca,legacy-mode : Set the SPI data transfer of the QCA7000 to
>> legacy mode.
>> +  In this mode the SPI master must toggle the chip select between
>> each data
>> +  word. In burst mode these gaps aren't necessary, which is faster.
>> +  This setting depends on how the QCA7000 is setup via GPIO pin
>> strapping.
>> +  If the property is missing the driver defaults to burst mode.
>> +
>> +Example:
>> +
>> +/* Freescale i.MX28 SPI master*/
>> +ssp2: ssp@80014000 {
>> +    #address-cells = <1>;
>> +    #size-cells = <0>;
>> +    compatible = "fsl,imx28-spi";
>> +    pinctrl-names = "default";
>> +    pinctrl-0 = <&spi2_pins_a>;
>> +    status = "okay";
>> +
>> +    qca7000@0 {
>
>    According to the ePAPR standard [1]:
>
> The name of a node should be somewhat generic, reflecting the function
> of the device and not its precise programming model. If appropriate,
> the name should be one of the following choices:
> [...]
>  - ethernet;

I have doubts about that. I agree that the current node name doesn't fit
to ePAPR. The function of a QCA7000 isn't really a ethernet device. Yes,
this linux driver implementation handle the QCA7000 as a ethernet
device. But the QCA7000 a powerline device according to Homeplug GreenPHY.

How about using powerline as node name?

>
>> +        compatible = "qca,qca7000";
>> +        interrupt-parent = <&gpio3>;      /* GPIO Bank 3 */
>> +        interrupts = <25 0x1>;            /* Index: 25, rising edge */
>> +        reg = <0x0>;
>> +        spi-cpha;                         /* SPI mode: CPHA=1 */
>> +        spi-cpol;                         /* SPI mode: CPOL=1 */
>> +        spi-max-frequency = <8000000>;    /* freq: 8 MHz */
>> +        local-mac-address = [ A0 B0 C0 D0 E0 F0 ];
>> +    };
>> +};
>
> [1]
> http://www.power.org/resources/downloads/Power_ePAPR_APPROVED_v1.0.pdf
>
> WBR, Sergei
>

BR Stefan Wahren
