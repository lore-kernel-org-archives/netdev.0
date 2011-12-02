From: Kumar Gala <galak@kernel.crashing.org>
Subject: Re: [PATCH] pq3: Add default tbi address
Date: Fri, 2 Dec 2011 01:20:19 -0600
Message-ID: <B84C6222-2359-46D5-BA54-5024E43ECD3F@kernel.crashing.org>
References: <1322809549-32622-1-git-send-email-afleming@freescale.com> <1322809549-32622-2-git-send-email-afleming@freescale.com>
Mime-Version: 1.0 (Apple Message framework v1251.1)
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 8BIT
Cc: David Miller <davem@davemloft.net>,
	<linuxppc-dev@lists.ozlabs.org>, <netdev@vger.kernel.org>
To: Andy Fleming <afleming@freescale.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from gate.crashing.org ([63.228.1.57]:58379 "EHLO gate.crashing.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752413Ab1LBHUY convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 2 Dec 2011 02:20:24 -0500
In-Reply-To: <1322809549-32622-2-git-send-email-afleming@freescale.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


On Dec 2, 2011, at 1:05 AM, Andy Fleming wrote:

> The MDIO driver has been changed so that it no longer supports
> scanning the MDIO bus for a free address for the TBI PHY. This
> feature was fragile, and required scanning the bus before the bus
> was fully up and registered. The intended way for FSL devices to
> specify the TBI PHY's address is via a tbi node in the device tree.
> All of the device trees had such a node, except for the recent p1/p2
> trees. Rather than hand-fixing all of those boards, set a default
> value (most boards were using 0x11, anyway), and any board which
> wants to change it from that default can then override it in its
> board dts file.
> 
> This fixes an issue where p1/p2 boards would fail to bring up
> Ethernet, due to not finding a tbi node.

Is this only needed on 1st controller because its what has external PHY control?

> Signed-off-by: Andy Fleming <afleming@freescale.com>
> ---
> arch/powerpc/boot/dts/fsl/pq3-etsec1-0.dtsi |    5 +++++
> arch/powerpc/boot/dts/fsl/pq3-etsec2-0.dtsi |    5 +++++
> 2 files changed, 10 insertions(+), 0 deletions(-)

This doesn't seem correct, meaning this should really be in the board .dts not in the IP.

I think the driver should check and warn if this property doesn't exist.

> 
> diff --git a/arch/powerpc/boot/dts/fsl/pq3-etsec1-0.dtsi b/arch/powerpc/boot/dts/fsl/pq3-etsec1-0.dtsi
> index a1979ae..0a42e21 100644
> --- a/arch/powerpc/boot/dts/fsl/pq3-etsec1-0.dtsi
> +++ b/arch/powerpc/boot/dts/fsl/pq3-etsec1-0.dtsi
> @@ -50,4 +50,9 @@ mdio@24520 {
> 	#size-cells = <0>;
> 	compatible = "fsl,gianfar-mdio";
> 	reg = <0x24520 0x20>;
> +
> +	tbi-phy@11 {
> +		device-type = "tbi-phy";
> +		reg = <0x11>;
> +	};
> };
> diff --git a/arch/powerpc/boot/dts/fsl/pq3-etsec2-0.dtsi b/arch/powerpc/boot/dts/fsl/pq3-etsec2-0.dtsi
> index 1382fec..964670a 100644
> --- a/arch/powerpc/boot/dts/fsl/pq3-etsec2-0.dtsi
> +++ b/arch/powerpc/boot/dts/fsl/pq3-etsec2-0.dtsi
> @@ -38,6 +38,11 @@ mdio@24000 {
> 	#size-cells = <0>;
> 	compatible = "fsl,etsec2-mdio";
> 	reg = <0x24000 0x1000 0xb0030 0x4>;
> +
> +	tbi-phy@11 {
> +		device-type = "tbi-phy";
> +		reg = <0x11>;
> +	};
> };
> 
> ethernet@b0000 {
> -- 
> 1.7.3.4
> 
