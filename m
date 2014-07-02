From: Stefan Wahren <stefan.wahren@i2se.com>
Subject: Re: [PATCH RFC V2 1/2] Documentation: add Device tree bindings for
 QCA7000
Date: Wed, 02 Jul 2014 17:37:03 +0200
Message-ID: <53B4271F.6080600@i2se.com>
References: <1404232609-4314-1-git-send-email-stefan.wahren@i2se.com> <1404232609-4314-2-git-send-email-stefan.wahren@i2se.com> <53B2F0D1.6070602@cogentembedded.com> <53B3AE5C.6040005@i2se.com> <53B3F23F.3030809@cogentembedded.com>
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
Received: from mout.kundenserver.de ([212.227.126.131]:59002 "EHLO
	mout.kundenserver.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754263AbaGBPhg (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 2 Jul 2014 11:37:36 -0400
In-Reply-To: <53B3F23F.3030809@cogentembedded.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hello Sergei,

Am 02.07.2014 13:51, schrieb Sergei Shtylyov:
>
>>>> +- qca,legacy-mode : Set the SPI data transfer of the QCA7000 to
>>>> legacy mode.
>>>> +  In this mode the SPI master must toggle the chip select between
>>>> each data
>>>> +  word. In burst mode these gaps aren't necessary, which is faster.
>>>> +  This setting depends on how the QCA7000 is setup via GPIO pin
>>>> strapping.
>>>> +  If the property is missing the driver defaults to burst mode.
>>>> +
>>>> +Example:
>>>> +
>>>> +/* Freescale i.MX28 SPI master*/
>>>> +ssp2: ssp@80014000 {
>
>    The node name should probably be "spi" here.

this working example comes from my test environment and i prefer to keep
it intact.
The strange name "ssp" comes from mxs-spi binding [1]. Unfortunately i
don't have another hardware platform.

>
>>>> +    #address-cells = <1>;
>>>> +    #size-cells = <0>;
>>>> +    compatible = "fsl,imx28-spi";
>>>> +    pinctrl-names = "default";
>>>> +    pinctrl-0 = <&spi2_pins_a>;
>>>> +    status = "okay";
>>>> +
>>>> +    qca7000@0 {
>
>>>     According to the ePAPR standard [1]:
>
>>> The name of a node should be somewhat generic, reflecting the function
>>> of the device and not its precise programming model. If appropriate,
>>> the name should be one of the following choices:
>>> [...]
>>>   - ethernet;
>
>> I have doubts about that. I agree that the current node name doesn't fit
>> to ePAPR. The function of a QCA7000 isn't really a ethernet device. Yes,
>> this linux driver implementation handle the QCA7000 as a ethernet
>> device. But the QCA7000 a powerline device according to Homeplug
>> GreenPHY.
>
>> How about using powerline as node name?
>
>    I don't know the differences between Ethernet and PowerLine but
> looks like they are minimal as you're implementing an Ethernet driver.
> So I'm still for "ethernet".

On physical layer Ethernet and Powerline are totally different, but from
user point of view they behaves similiar. If nobody appeal i will change
it to "ethernet".


>
>>>> +        compatible = "qca,qca7000";
>>>> +        interrupt-parent = <&gpio3>;      /* GPIO Bank 3 */
>>>> +        interrupts = <25 0x1>;            /* Index: 25, rising
>>>> edge */
>>>> +        reg = <0x0>;
>>>> +        spi-cpha;                         /* SPI mode: CPHA=1 */
>>>> +        spi-cpol;                         /* SPI mode: CPOL=1 */
>>>> +        spi-max-frequency = <8000000>;    /* freq: 8 MHz */
>>>> +        local-mac-address = [ A0 B0 C0 D0 E0 F0 ];
>>>> +    };
>>>> +};
>

Thanks about your comments.

BR Stefan Wahren

[1] -
https://git.kernel.org/cgit/linux/kernel/git/torvalds/linux.git/tree/Documentation/devicetree/bindings/spi/mxs-spi.txt?id=refs/tags/v3.16-rc3
