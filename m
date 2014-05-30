From: Florian Fainelli <f.fainelli@gmail.com>
Subject: Re: [PATCH V1 net-next 1/5] amd-xgbe: AMD 10GbE device bindings documentation
Date: Fri, 30 May 2014 10:11:57 -0700
Message-ID: <CAGVrzcbb1x_DrqmqH4D5qm2Nh0OBzNZMZ9APMcAq=hbXUsDBKw@mail.gmail.com>
References: <20140530161055.31154.97537.stgit@tlendack-t1.amdoffice.net> <20140530161101.31154.21311.stgit@tlendack-t1.amdoffice.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: netdev <netdev@vger.kernel.org>, jcm@redhat.com,
	David Miller <davem@davemloft.net>
To: Tom Lendacky <thomas.lendacky@amd.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-qg0-f43.google.com ([209.85.192.43]:37198 "EHLO
	mail-qg0-f43.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S934048AbaE3RMi (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 30 May 2014 13:12:38 -0400
Received: by mail-qg0-f43.google.com with SMTP id 63so6157817qgz.2
        for <netdev@vger.kernel.org>; Fri, 30 May 2014 10:12:37 -0700 (PDT)
In-Reply-To: <20140530161101.31154.21311.stgit@tlendack-t1.amdoffice.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi,

2014-05-30 9:11 GMT-07:00 Tom Lendacky <thomas.lendacky@amd.com>:
> This patch provides the documentation of the device bindings
> for the AMD 10GbE platform driver.
>
> Signed-off-by: Tom Lendacky <thomas.lendacky@amd.com>
> ---
>  .../devicetree/bindings/net/amd-xgbe-phy.txt       |   17 +++++++++++
>  Documentation/devicetree/bindings/net/amd-xgbe.txt |   32 ++++++++++++++++++++
>  2 files changed, 49 insertions(+)
>  create mode 100644 Documentation/devicetree/bindings/net/amd-xgbe-phy.txt
>  create mode 100644 Documentation/devicetree/bindings/net/amd-xgbe.txt
>
> diff --git a/Documentation/devicetree/bindings/net/amd-xgbe-phy.txt b/Documentation/devicetree/bindings/net/amd-xgbe-phy.txt
> new file mode 100644
> index 0000000..cd821d0
> --- /dev/null
> +++ b/Documentation/devicetree/bindings/net/amd-xgbe-phy.txt
> @@ -0,0 +1,17 @@
> +* AMD 10GbE PHY driver (amd-xgbe-phy)
> +
> +Required properties:
> +- compatible: Should be "amd,xgbe-phy-seattle-v1a" and
> +  "ethernet-phy-ieee802.3-c45"
> +- reg: Address and length of the register sets for the device
> +   - SerDes Rx/Tx registers
> +   - SerDes integration registers (1/2)
> +   - SerDes integration registers (2/2)
> +
> +Example:
> +       xgbe_phy@e1240800 {
> +               compatible = "amd,xgbe-phy-seattle-v1a", "ethernet-phy-ieee802.3-c45";
> +               reg = <0 0xe1240800 0 0x00400>,
> +                     <0 0xe1250000 0 0x00060>,
> +                     <0 0xe1250080 0 0x00004>;
> +       };
> diff --git a/Documentation/devicetree/bindings/net/amd-xgbe.txt b/Documentation/devicetree/bindings/net/amd-xgbe.txt
> new file mode 100644
> index 0000000..2aec10d
> --- /dev/null
> +++ b/Documentation/devicetree/bindings/net/amd-xgbe.txt
> @@ -0,0 +1,32 @@
> +* AMD 10GbE driver (amd-xgbe)
> +
> +Required properties:
> +- compatible: Should be "amd,xgbe-seattle-v1a"
> +- reg: Address and length of the register sets for the device
> +   - MAC registers
> +   - PCS registers
> +- interrupt-parent: Should be the phandle for the interrupt controller
> +  that services interrupts for this device
> +- interrupts: Should contain the amd-xgbe interrupt
> +- clocks: Should be the DMA clock for the amd-xgbe device (used for
> +  calculating the correct Rx interrupt watchdog timer value on a DMA
> +  channel for coalescing)
> +- clock-names: Should be the name of the DMA clock, "dma_clk"
> +- phy-handle: Should be the phandle for the associated phy

You can also reference ethernet.txt and phy.txt in the same directory
for details about 'phy-handle'.

'phy-mode' is also a required property here since you have specified a
'phy-handle' phandle to the PHY node.

> +
> +Optional properties:
> +- mac-address: mac address to be assigned to the device. Can be overridden
> +  by UEFI.
> +
> +Example:
> +       xgbe@e0700000 {
> +               compatible = "amd,xgbe-seattle-v1a";
> +               reg = <0 0xe0700000 0 0x80000>,
> +                     <0 0xe0780000 0 0x80000>;
> +               interrupt-parent = <&gic>;
> +               interrupts = <0 325 4>;
> +               clocks = <&xgbe_clk>;
> +               clock-names = "dma_clk";
> +               phy-handle = <&phy>;
> +               mac-address = [ 02 a1 a2 a3 a4 a5 ];
> +       };
>
> --
> To unsubscribe from this list: send the line "unsubscribe netdev" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html



-- 
Florian
