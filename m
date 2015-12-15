From: Florian Fainelli <f.fainelli@gmail.com>
Subject: Re: [PATCH v2] net/macb: add support for resetting PHY using GPIO
Date: Mon, 14 Dec 2015 21:31:10 -0800
Message-ID: <23E868E9-3EE2-4365-902A-C1C5BA006DFB@gmail.com>
References: <1449830093-29433-1-git-send-email-gregory.clement@free-electrons.com> <20151214225634.GA14163@rob-hp-laptop>
Mime-Version: 1.0
Content-Type: text/plain;
 charset=UTF-8
Content-Transfer-Encoding: 8bit
Cc: Thomas Petazzoni <thomas.petazzoni@free-electrons.com>,
	devicetree@vger.kernel.org, netdev@vger.kernel.org,
	Sascha Hauer <s.hauer@pengutronix.de>,
	Nicolas Ferre <nicolas.ferre@atmel.com>,
	linux-kernel@vger.kernel.org,
	"David S. Miller" <davem@davemloft.net>,
	linux-arm-kernel@lists.infradead.org
To: Rob Herring <robh@kernel.org>,
	Gregory CLEMENT <gregory.clement@free-electrons.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20151214225634.GA14163@rob-hp-laptop>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On December 14, 2015 2:56:34 PM PST, Rob Herring <robh@kernel.org> wrote:
>On Fri, Dec 11, 2015 at 11:34:53AM +0100, Gregory CLEMENT wrote:
>> With device tree it is no more possible to reset the PHY at board
>> level. Furthermore, doing in the driver allow to power down the PHY
>when
>> the network interface is no more used.
>> 
>> This reset can't be done at the PHY driver level. The PHY must be
>able to
>> answer the to the mii bus scan to let the kernel creating a PHY
>device.
>> 
>> The patch introduces a new optional property "phy-reset-gpios"
>inspired
>> from the one use for the FEC.
>> 
>> Signed-off-by: Gregory CLEMENT <gregory.clement@free-electrons.com>
>> ---
>> 
>> Since the v1, I used the gpiod functions. It allows to simplify the
>> code and to not introduce any #ifdef.
>> 
>> I also rename the property in phy-reset-gpios, even if actually the
>> gpiod will match both phy-reset-gpios and phy-reset-gpio.
>> 
>> 
>>  Documentation/devicetree/bindings/net/macb.txt | 3 +++
>>  drivers/net/ethernet/cadence/macb.c            | 8 ++++++++
>>  drivers/net/ethernet/cadence/macb.h            | 1 +
>>  3 files changed, 12 insertions(+)
>> 
>> diff --git a/Documentation/devicetree/bindings/net/macb.txt
>b/Documentation/devicetree/bindings/net/macb.txt
>> index b5d7976..4a7fb6c 100644
>> --- a/Documentation/devicetree/bindings/net/macb.txt
>> +++ b/Documentation/devicetree/bindings/net/macb.txt
>> @@ -19,6 +19,9 @@ Required properties:
>>  	Optional elements: 'tx_clk'
>>  - clocks: Phandles to input clocks.
>>  
>> +Optional properties:
>> +- phy-reset-gpios : Should specify the gpio for phy reset
>> +
>
>This alone is simple enough, but I worry that this doesn't really
>scale. 
>What if you need to enable clocks or regulators for the same reason?
>The 
>mmc folks did a pwrseq binding for similar reasons. I don't think I'd 
>recommend that here as I think it is kind of ugly. We really need a 
>pre-probe/scan hook for drivers. This is also needed for USB devices 
>mounted on boards.

In this particular case, the way Ethernet MAC drivers register their MDIO buses and therefore PHYs, there is always a good way to deassert the PHY GPIO line without requiring major core device driver changes. Worst case, there is the MDIO bus reset callback which could used for that matter.

In the case of PCI, USB etc. I do agree having a way to twiddle things before scanning/probing would be awesome. I have some boards here which have GPIO controlled regulator and hacking the RC driver to deal with that is suboptimal... 

>
>But I'm not going to hold up something simple to do all that, so:
>
>Acked-by: Rob Herring <robh@kernel.org>
>
>_______________________________________________
>linux-arm-kernel mailing list
>linux-arm-kernel@lists.infradead.org
>http://lists.infradead.org/mailman/listinfo/linux-arm-kernel


-- 
Sent from my Android device with K-9 Mail. Please excuse my brevity.
