From: Rob Herring <robh@kernel.org>
Subject: Re: [PATCH v2] net: fec: Add "phy-reset-active-low" property to DT
Date: Fri, 12 Feb 2016 09:20:11 -0600
Message-ID: <20160212152011.GA28563@rob-hp-laptop>
References: <1455048072-869-1-git-send-email-bernhard@bwalle.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: fabio.estevam@freescale.com, devicetree@vger.kernel.org,
	linux-kernel@vger.kernel.org, netdev@vger.kernel.org
To: Bernhard Walle <bernhard@bwalle.de>
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <1455048072-869-1-git-send-email-bernhard@bwalle.de>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Tue, Feb 09, 2016 at 09:01:12PM +0100, Bernhard Walle wrote:
> We need that for a custom hardware that needs the reverse reset
> sequence.
> 
> Signed-off-by: Bernhard Walle <bernhard@bwalle.de>
> ---
> Changes compared to v1:
>  - Add documentation to 'phy-reset-gpios' that flags are ignored
>    as suggested by Andrew Lunn.
> 
>  Documentation/devicetree/bindings/net/fsl-fec.txt | 7 ++++++-
>  drivers/net/ethernet/freescale/fec_main.c         | 8 ++++++--
>  2 files changed, 12 insertions(+), 3 deletions(-)
> 
> diff --git a/Documentation/devicetree/bindings/net/fsl-fec.txt b/Documentation/devicetree/bindings/net/fsl-fec.txt
> index a9eb611..0caa429 100644
> --- a/Documentation/devicetree/bindings/net/fsl-fec.txt
> +++ b/Documentation/devicetree/bindings/net/fsl-fec.txt
> @@ -7,11 +7,16 @@ Required properties:
>  - phy-mode : See ethernet.txt file in the same directory
>  
>  Optional properties:
> -- phy-reset-gpios : Should specify the gpio for phy reset
> +- phy-reset-gpios : Should specify the gpio for phy reset. Additional
> +  flags are ignored, see the non-standard 'phy-reset-active-low' property
> +  instead.
>  - phy-reset-duration : Reset duration in milliseconds.  Should present
>    only if property "phy-reset-gpios" is available.  Missing the property
>    will have the duration be 1 millisecond.  Numbers greater than 1000 are
>    invalid and 1 millisecond will be used instead.
> +- phy-reset-active-low : If present then the reset sequence using the GPIO
> +  specified in the "phy-reset-gpios" property is reversed (H=reset state,
> +  L=operation state).

This is what the gpio flags are for. Why can't you use that?

>  - phy-supply : regulator that powers the Ethernet PHY.
>  - phy-handle : phandle to the PHY device connected to this device.
>  - fixed-link : Assume a fixed link. See fixed-link.txt in the same directory.
