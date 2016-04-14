From: Timur Tabi <timur@codeaurora.org>
Subject: Re: [PATCH 1/2] [v4] net: emac: emac gigabit ethernet controller
 driver
Date: Thu, 14 Apr 2016 11:47:03 -0500
Message-ID: <570FC987.80304@codeaurora.org>
References: <1460570393-19838-1-git-send-email-timur@codeaurora.org>
 <20160414163240.GB15303@rob-hp-laptop>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	devicetree@vger.kernel.org, linux-arm-msm@vger.kernel.org,
	sdharia@codeaurora.org,
	Shanker Donthineni <shankerd@codeaurora.org>,
	Greg Kroah-Hartman <greg@kroah.com>, vikrams@codeaurora.org,
	cov@codeaurora.org, gavidov@codeaurora.org, andrew@lunn.ch,
	bjorn.andersson@linaro.org, Mark Langsdorf <mlangsdo@redhat.com>,
	Jon Masters <jcm@redhat.com>,
	Andy Gross <agross@codeaurora.org>,
	"David S. Miller" <davem@davemloft.net>
To: Rob Herring <robh@kernel.org>
Return-path: <linux-arm-msm-owner@vger.kernel.org>
In-Reply-To: <20160414163240.GB15303@rob-hp-laptop>
Sender: linux-arm-msm-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Rob Herring wrote:

>> @@ -0,0 +1,65 @@
>> +Qualcomm EMAC Gigabit Ethernet Controller
>> +
>> +Required properties:
>> +- compatible : Should be "qcom,emac".
>
> Come on... Can you guess what I'm going to say here.

Ooops, I missed that one.

>
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
>> +- phy-addr            : Specifies phy address on MDIO bus.
>> +			Required if the optional property "qcom,no-external-phy"
>> +			is not specified.
>
> As I mentioned in the last version, you should still describe this with
> a standard MDIO bus binding even if you can't use the generic code.

You mean like this?

	phy0: ethernet-phy@0 {
		compatible = "qcom,fsm9900-emac-phy";
		reg = <4>;
	};

>> +Optional properties:
>> +- qcom,emac-tstamp-en       : Enables the PTP (1588) timestamping feature.
>> +			      Include this only if PTP (1588) timestamping
>> +			      feature is needed. If included, "ptp" register
>> +			      base should be specified.
>> +- mac-address               : The 6-byte MAC address. If present, it is the
>> +			      default MAC address.
>> +- qcom,no-external-phy      : Indicates there is no external PHY connected to
>> +			      EMAC. Include this only if the EMAC is directly
>> +			      connected to the peer end without EPHY.
>> +Example:
>> +	emac0: qcom,emac@feb20000 {
>
> ethernet@
>
>> +		compatible = "qcom,fsm9900-emac";
>
> Ah, I see you fixed it here...

and in the code, I just missed it in the top of the file.  I'll fix it 
everywhere in v5.

-- 
Qualcomm Innovation Center, Inc.
The Qualcomm Innovation Center, Inc. is a member of the Code Aurora
Forum, a Linux Foundation collaborative project.
