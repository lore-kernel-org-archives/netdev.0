From: Giuseppe CAVALLARO <peppe.cavallaro@st.com>
Subject: Re: [PATCH] stmmac: Add device-tree support
Date: Mon, 12 Mar 2012 16:30:37 +0100
Message-ID: <4F5E169D.3070508@st.com>
References: <1331561157-3820-1-git-send-email-sr@denx.de> <4F5E0993.9020000@gmail.com> <201203121606.26926.sr@denx.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: Rob Herring <robherring2@gmail.com>, netdev@vger.kernel.org,
	Viresh Kumar <viresh.kumar@st.com>,
	devicetree-discuss@ozlabs.org, linux-arm-kernel@lists.infradead.org
To: Stefan Roese <sr@denx.de>
Return-path: <netdev-owner@vger.kernel.org>
Received: from eu1sys200aog110.obsmtp.com ([207.126.144.129]:34417 "EHLO
	eu1sys200aog110.obsmtp.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1755949Ab2CLPcL (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 12 Mar 2012 11:32:11 -0400
In-Reply-To: <201203121606.26926.sr@denx.de>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 3/12/2012 4:06 PM, Stefan Roese wrote:
> Hi Rob,
> 
> On Monday 12 March 2012 15:34:59 Rob Herring wrote:
>> On 03/12/2012 09:05 AM, Stefan Roese wrote:
>>> This patch adds support to configure the STMMAC ethernet driver via
>>> device-tree instead of platform_data.
>>>
>>> Currently, only the properties needed on SPEAr600 are provided. All
>>> other properties should be added once needed on other platforms.
>>>
>>> Signed-off-by: Stefan Roese <sr@denx.de>
>>> Cc: Giuseppe Cavallaro <peppe.cavallaro@st.com>
>>> Cc: Viresh Kumar <viresh.kumar@st.com>
>>> ---
>>>
>>>  Documentation/devicetree/bindings/net/stmmac.txt   |   38 +++++++++++
>>>  .../net/ethernet/stmicro/stmmac/stmmac_platform.c  |   66
>>>  +++++++++++++++++++- 2 files changed, 103 insertions(+), 1 deletion(-)
>>>  create mode 100644 Documentation/devicetree/bindings/net/stmmac.txt
>>>
>>> diff --git a/Documentation/devicetree/bindings/net/stmmac.txt
>>> b/Documentation/devicetree/bindings/net/stmmac.txt new file mode 100644
>>> index 0000000..386a47f
>>> --- /dev/null
>>> +++ b/Documentation/devicetree/bindings/net/stmmac.txt
>>> @@ -0,0 +1,38 @@
>>> +* STMicroelectronics 10/100/1000 Ethernet driver (GMAC)
>>> +
>>> +Required properties:
>>> +- compatible: Should be "stm,gmac"
>>
>> This is too generic. This should be 1 string per version of h/w.
> 
> Viresh, Giuseppe, can you please suggest a proper string for the SPEAr600 
> STMMAC core, including version?
>  
>> 'stm' should be 'st' according to vendor-prefixes.txt.

I'm not familiar with devicetree; maybe we should have:

"stmicro,mac100"
"stmicro,gmac"

or: st instead of stmicro if you prefer.

in fact, stmmac is for mac100 and gmac devices.

> 
> Okay.
>  
>>> +- reg: Address and length of the register set for the device
>>> +- interrupt-parent: Should be the phandle for the interrupt controller
>>> +  that services interrupts for this device
>>> +- interrupts: Should contain the STMMAC interrupts
>>> +- interrupt-names: Should contain the interrupt names "macirq"
>>> +  "eth_wake_irq" if this interrupt is supported in the "interrupts"
>>> +  property
>>
>> You should be able to tell this from the compatible string and number of
>> interrupts.
> 
> Yes. Currently the driver uses platform_get_irq_byname() to register the 
> irq's. That's why I added these properties. Is there something wrong with 
> using it this way?
>  
>>> +- phy-mode: String, operation mode of the PHY interface.
>>> +  Supported values are: "mii", "rmii", "gmii", "rgmii".
>>> +- phy-addr: MDIO address of the PHY
>>
>> This is normally probed or the mdio bus is a sub-node of the MAC node.
>> See arch/powerpc/boot/dts/mpc8377_mds.dts for an example.
> 
> Okay, I'll rework this.
> 
>>> +
>>> +Optional properties:
>>> +- stm,prog-burst-len: Specify the burst length
>>> +- stm,has-gmac: Indicates that the controller supports 1000Mbps
>>> +- stm,has-pmt: Indicates that the controller supports power management
>>
>> I think these should all be encoded by the compatible string.

and should we have all the other flags e.g. tx_coe etc?
(see stmmac.txt)

Peppe

> 
> You mean that by defining a specific compatible string (e.g.
> "st,gmac-spear600"), these settings are implicitly set? And should therefore 
> be omitted from the dts?
> 
> Thanks,
> Stefan
> --
> To unsubscribe from this list: send the line "unsubscribe netdev" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
> 
