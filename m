From: Rob Herring <robh@kernel.org>
Subject: Re: [PATCH 1/5] stmmac: create of compatible mdio bus for stmacc
 driver
Date: Fri, 4 Dec 2015 10:16:14 -0600
Message-ID: <20151204161614.GA8791@rob-hp-laptop>
References: <1449220125-67417-1-git-send-email-preid@electromag.com.au>
 <1449220125-67417-2-git-send-email-preid@electromag.com.au>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, devicetree@vger.kernel.org,
	davem@davemloft.net
To: Phil Reid <preid@electromag.com.au>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.kernel.org ([198.145.29.136]:56161 "EHLO mail.kernel.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753494AbbLDQQT (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 4 Dec 2015 11:16:19 -0500
Content-Disposition: inline
In-Reply-To: <1449220125-67417-2-git-send-email-preid@electromag.com.au>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, Dec 04, 2015 at 05:08:41PM +0800, Phil Reid wrote:
> The DSA driver needs to be passed a reference to an mdio bus. Typically
> the mac is configured to use a fixed link but the mdio bus still needs
> to be registered so that it con configure the switch.
> This patch follows the same process as the altera tse ethernet driver for
> creation of the mdio bus.
> 
> Signed-off-by: Phil Reid <preid@electromag.com.au>
> ---
>  Documentation/devicetree/bindings/net/stmmac.txt   | 10 ++++++-
>  drivers/net/ethernet/stmicro/stmmac/stmmac_mdio.c  | 32 ++++++++++++++++------
>  .../net/ethernet/stmicro/stmmac/stmmac_platform.c  |  2 +-
>  3 files changed, 34 insertions(+), 10 deletions(-)
> 
> diff --git a/Documentation/devicetree/bindings/net/stmmac.txt b/Documentation/devicetree/bindings/net/stmmac.txt
> index f34fc3c..0056c4c 100644
> --- a/Documentation/devicetree/bindings/net/stmmac.txt
> +++ b/Documentation/devicetree/bindings/net/stmmac.txt
> @@ -47,7 +47,8 @@ Optional properties:
>  - snps,burst_len: The AXI burst lenth value of the AXI BUS MODE register.
>  - tx-fifo-depth: See ethernet.txt file in the same directory
>  - rx-fifo-depth: See ethernet.txt file in the same directory
> -
> +- mdio: with compatible = "snps,dwmac-mdio", create and register mdio bus.
> +  
>  Examples:
>  
>  	gmac0: ethernet@e0800000 {
> @@ -65,4 +66,11 @@ Examples:
>  		tx-fifo-depth = <16384>;
>  		clocks = <&clock>;
>  		clock-names = "stmmaceth";
> +		mdio0: mdio@0 {

Don't need a unit address here. Otherwise, for the binding:

Acked-by: Rob Herring <robh@kernel.org>


> +			#address-cells = <1>;
> +			#size-cells = <0>;
> +			compatible = "snps,dwmac-mdio";
> +			phy1: ethernet-phy@0 {
> +			};
> +		};    
>  	};
