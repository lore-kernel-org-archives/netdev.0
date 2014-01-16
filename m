From: Ben Hutchings <bhutchings@solarflare.com>
Subject: Re: [PATCH net-next v4 1/2] dts: Add a binding for Synopsys emac
 max-frame-size
Date: Thu, 16 Jan 2014 17:50:01 +0000
Message-ID: <1389894601.11912.54.camel@bwh-desktop.uk.level5networks.com>
References: <1389881155-9758-1-git-send-email-vbridgers2013@gmail.com>
	 <1389881155-9758-2-git-send-email-vbridgers2013@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: <devicetree@vger.kernel.org>, <netdev@vger.kernel.org>,
	<peppe.cavallaro@st.com>, <robh+dt@kernel.org>,
	<pawel.moll@arm.com>, <mark.rutland@arm.com>,
	<ijc+devicetree@hellion.org.uk>, <galak@codeaurora.org>,
	<dinguyen@altera.com>, <rayagond@vayavyalabs.com>
To: Vince Bridgers <vbridgers2013@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from webmail.solarflare.com ([12.187.104.25]:55405 "EHLO
	webmail.solarflare.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751172AbaAPRuH (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 16 Jan 2014 12:50:07 -0500
In-Reply-To: <1389881155-9758-2-git-send-email-vbridgers2013@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, 2014-01-16 at 08:05 -0600, Vince Bridgers wrote:
> This change adds a parameter for the Synopsys 10/100/1000
> stmmac Ethernet driver to configure the maximum frame
> size supported by the EMAC driver. Synopsys allows the FIFO
> sizes to be configured when the cores are built for a particular
> device, but do not provide a way for the driver to read
> information from the device about the maximum MTU size
> supported as limited by the device's FIFO size.
> 
> Signed-off-by: Vince Bridgers <vbridgers2013@gmail.com>
> ---
> V4: add comments to explain use of max-frame-size with respect
>     to inconsistent definition and use in the ePAPR v1.1 spec

Well, ePAPR does not seem to be consistent with itself. :-)

> V3: change snps,max-frame-size to max-frame-size
> V2: change snps,max-mtu to snps,max-frame-size
> ---
>  Documentation/devicetree/bindings/net/stmmac.txt |   13 ++++++++++++-
>  1 file changed, 12 insertions(+), 1 deletion(-)
> 
> diff --git a/Documentation/devicetree/bindings/net/stmmac.txt b/Documentation/devicetree/bindings/net/stmmac.txt
> index eba0e5e..d553be2 100644
> --- a/Documentation/devicetree/bindings/net/stmmac.txt
> +++ b/Documentation/devicetree/bindings/net/stmmac.txt
> @@ -29,7 +29,17 @@ Required properties:
>  				ignored if force_thresh_dma_mode is set.
>  
>  Optional properties:
> -- mac-address: 6 bytes, mac address
> +- mac-address:		6 bytes, mac address
> +- max-frame-size:	Maximum frame size permitted. This parameter is useful
> +			since different implementations of the Synopsys MAC may
> +			have different FIFO sizes depending on the selections
> +			made in Synopsys Core Consultant. Note that the usage
> +			is inconsistent with the definition in the ePAPR v1.1
> +			specification, as it defines max-frame-size inclusive
> +			of the MAC DA, SA, Ethertype and CRC while usage is
> +			consistent with the IEEE definition of MAC Client
> +			Data, which is sans the MAC DA, SA, Ethertype and
> +			CRC.
[...]

While this is very precise, I fear that it is now so verbose that it
actually becomes confusing.  Can this not be condensed to 'the maximum
MTU and MRU, rather than the maximum Ethernet frame size'?

Ben.

-- 
Ben Hutchings, Staff Engineer, Solarflare
Not speaking for my employer; that's the marketing department's job.
They asked us to note that Solarflare product names are trademarked.
