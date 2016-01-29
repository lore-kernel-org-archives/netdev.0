From: Timur Tabi <timur@codeaurora.org>
Subject: Re: [PATCH V3] net: emac: emac gigabit ethernet controller driver
Date: Fri, 29 Jan 2016 12:22:34 -0600
Message-ID: <56ABADEA.40801@codeaurora.org>
References: <1451440135-25771-1-git-send-email-gavidov@codeaurora.org>
 <20151231231039.GA8886@rob-hp-laptop>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	devicetree@vger.kernel.org, linux-arm-msm@vger.kernel.org,
	sdharia@codeaurora.org, shankerd@codeaurora.org,
	gregkh@linuxfoundation.org, vikrams@codeaurora.org,
	cov@codeaurora.org
To: Rob Herring <robh@kernel.org>,
	Gilad Avidov <gavidov@codeaurora.org>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20151231231039.GA8886@rob-hp-laptop>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Gilad is no longer working for Qualcomm, so I'm taking over (as best as 
I can) this driver.  Let's just say it's going to be a learning experience.

Rob Herring wrote:
>> diff --git a/Documentation/devicetree/bindings/net/qcom-emac.txt b/Documentation/devicetree/bindings/net/qcom-emac.txt
>> new file mode 100644
>> index 0000000..8d58a40
>> --- /dev/null
>> +++ b/Documentation/devicetree/bindings/net/qcom-emac.txt
>> @@ -0,0 +1,68 @@
>> +Qualcomm EMAC Gigabit Ethernet Controller
>> +
>> +Required properties:
>> +- cell-index : EMAC controller instance number.
>> +- compatible : Should be "qcom,emac".
>
> This should be more specific with the SOC name.

The emac is present on a lot of Qualcomm SOCs, and there are only a few 
variations of it.  It's not really SOC-specific, and the hardware 
version can be queried by the driver.

What did you have in mind?  I don't know even have a list of which SOCs 
has an emac, especially since it's mostly on MSM parts, and I work on 
the server SOC.

>> +- reg : Offset and length of the register regions for the device
>> +- reg-names : Register region names referenced in 'reg' above.
>> +	Required register resource entries are:
>> +	"base"   : EMAC controller base register block.
>> +	"csr"    : EMAC wrapper register block.
>> +	Optional register resource entries are:
>> +	"ptp"    : EMAC PTP (1588) register block.
>> +		   Required if 'qcom,emac-tstamp-en' is present.
>> +	"sgmii"  : EMAC SGMII PHY register block.
>> +- interrupts : Interrupt numbers used by this controller
>> +- interrupt-names : Interrupt resource names referenced in 'interrupts' above.
>> +	Required interrupt resource entries are:
>> +	"emac_core0"   : EMAC core0 interrupt.
>> +	"sgmii_irq"   : EMAC SGMII interrupt.
>> +- qcom,emac-gpio-mdc  : GPIO pin number of the MDC line of MDIO bus.
>> +- qcom,emac-gpio-mdio : GPIO pin number of the MDIO line of MDIO bus.
>
> Use the standard binding for GPIO controlled MDIO bus.

I'm not familiar with that one.  Are you talking about 
bindings/net/mdio-gpio.txt?

>> +- phy-addr            : Specifies phy address on MDIO bus.
>> +			Required if the optional property "qcom,no-external-phy"
>> +			is not specified.
>
> Don't you think you will need to know the specific phy device or other
> properties of the phy?

That, I can't answer.  Aren't all MDIO devices basically the same?  It's 
been a while since I've worked on them.

>> +Optional properties:
>> +- qcom,emac-tstamp-en       : Enables the PTP (1588) timestamping feature.
>> +			      Include this only if PTP (1588) timestamping
>> +			      feature is needed. If included, "ptp" register
>> +			      base should be specified.
>
> Isn't this a user enabled feature if the h/w supports it?

Is there a sysfs entry for that?  We were planning on having a similar 
ACPI property.
