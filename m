From: Sergei Shtylyov <sergei.shtylyov@cogentembedded.com>
Subject: Re: [PATCH 2/2] sh_eth: add device tree support
Date: Wed, 04 Sep 2013 23:42:02 +0400
Message-ID: <52278D0A.6010901@cogentembedded.com>
References: <201308310429.34856.sergei.shtylyov@cogentembedded.com> <E4C90BAA-A89F-4C7C-B186-12C2DF7E6F31@codeaurora.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, rob.herring@calxeda.com,
	pawel.moll@arm.com, mark.rutland@arm.com, swarren@wwwdotorg.org,
	ian.campbell@citrix.com, grant.likely@linaro.org,
	devicetree@vger.kernel.org, nobuhiro.iwamatsu.yj@renesas.com,
	linux-sh@vger.kernel.org, rob@landley.net,
	linux-doc@vger.kernel.org
To: Kumar Gala <galak@codeaurora.org>
Return-path: <linux-doc-owner@vger.kernel.org>
In-Reply-To: <E4C90BAA-A89F-4C7C-B186-12C2DF7E6F31@codeaurora.org>
Sender: linux-doc-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hello.

On 09/04/2013 02:08 AM, Kumar Gala wrote:

>> Add support of the device tree probing for the Renesas SH-Mobile SoCs.

>> This work is loosely based on an original patch by Nobuhiro Iwamatsu
>> <nobuhiro.iwamatsu.yj@renesas.com>.

>> Signed-off-by: Sergei Shtylyov <sergei.shtylyov@cogentembedded.com>

>> ---
>> This patch is against Dave's 'net-next.git' repo.

>> Documentation/devicetree/bindings/net/sh_eth.txt |   40 +++++++++++++
>> drivers/net/ethernet/renesas/sh_eth.c            |   66 ++++++++++++++++++++++-
>> 2 files changed, 105 insertions(+), 1 deletion(-)

>> Index: net-next/Documentation/devicetree/bindings/net/sh_eth.txt
>> ===================================================================
>> --- /dev/null
>> +++ net-next/Documentation/devicetree/bindings/net/sh_eth.txt
>> @@ -0,0 +1,40 @@
>> +* Renesas Electronics SH EtherMAC
>> +
>> +This file provides information on what the device node for the SH EtherMAC
>> +interface contains.
>> +
>> +Required properties:
>> +- compatible: "renesas,gether-r8a7740" if the device is a part of R8A7740 SoC.
>> +	      "renesas,ether-r8a7779" if the device is a part of R8A7778/9 SoCs.
>> +	      "renesas,ether-r8a7790" if the device is a part of R8A7790/1 SoCs.

> Curious, 7779 (vs 7778) but 7790 (vs 7791).

    Support for R8A7779 appeared in Linux before support for R8A7778 (probably 
the chips appeared on the market in the same order). The same can be said 
about R8A7790 -- it appeared first; R8A7791 isn't yet supported by Linux (it 
should be in 3.13). R8A7779/90 are high end chips, R8A7778/91 are middle class 
chips. Anyway, by request of Magnus Damm, I'll have to use the individual 
"compatible" properties.

>> +- reg: offset and length of the register set for the device; if the device has
>> +       TSU registers, you need to specify two register sets here.
>> +- interrupt-parent: the phandle for the interrupt controller that services
>> +		    interrupts for this device.
>> +- interrupts: interrupt mapping for the interrupt source.
>> +- phy-mode: string, operation mode of the PHY interface (a string that
>> +	    of_get_phy_mode() can understand).
>> +- phy-handle: phandle of the PHY device.
>> +

> Should add something about requiring a phy subnode

    OK.

>> +Optional properties:
>> +- local-mac-address: 6 bytes, MAC address.

> What's the assumption if local-mac-address is not specified?

    The driver will try to read the chip's MAC address registers hoping to 
find an address left there programmed by U-Boot. If no valid address is found 
(usual case on R8A7778/9 development boards which have an extra network chip), 
the random one will be used.

>> +- renesas,no-ether-link: specify when a board does not provide a proper LINK
>> +			 signal.

> How is this different from the fixed link concept we have?

    Here the chip-specific LINK signal is meant which is supposed to go from a 
PHY to the SoC. Sometimes it's wired from the PHY's link/active LED output or 
just absent on the board, so we aren't able to use it for the link detection.
In this case, phylib's notification is used.

>> +- renesas,ether-link-active-low: specify when the LINK signal is active-low.
>> +
>> +Example (Armadillo800EVA board):
>> +
>> +	ethernet@e9a00000 {
>> +		compatible = "renesas,gether-r8a7740";
>> +		reg = <0xe9a00000 0x800>, <0xe9a01800 0x800>;
>> +		interrupt-parent = <&gic>;
>> +		interrupts = <0 142 0x4>;
>> +		phy-mode = "mii";
>> +		phy-handle = <&phy0>;
>> +		#address-cells = <1>;
>> +		#size-cells = <0>;
>> +
>> +		phy0: ethernet-phy@0 {
>> +			reg = <0>;
>> +		};
>> +	};

> - k

WBR, Sergei

