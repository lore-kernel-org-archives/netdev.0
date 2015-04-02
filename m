From: Paul Bolle <pebolle@tiscali.nl>
Subject: Re: [PATCH RFC 02/10] dpaa_eth: add support for DPAA Ethernet
Date: Thu, 02 Apr 2015 12:44:04 +0200
Message-ID: <1427971444.10518.40.camel@x220>
References: <1427905196-27778-1-git-send-email-madalin.bucur@freescale.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linuxppc-dev@lists.ozlabs.org,
	linux-kernel@vger.kernel.org
To: madalin.bucur@freescale.com
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1427905196-27778-1-git-send-email-madalin.bucur@freescale.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Just a few nits.

This series is posted as an RFC, so this might not be what you're
expecting right now. But as these messages got tangled up in my mail
filter anyhow, I thought I might as well bother you with these nits now.

On Wed, 2015-04-01 at 19:19 +0300, Madalin Bucur wrote:
> --- /dev/null
> +++ b/drivers/net/ethernet/freescale/dpaa/Kconfig
> @@ -0,0 +1,49 @@
> +menuconfig FSL_DPAA_ETH
> +	tristate "DPAA Ethernet"
> +	depends on FSL_SOC && FSL_BMAN && FSL_QMAN && FSL_FMAN
> +	select PHYLIB
> +	select FSL_FMAN_MAC
> +	---help---
> +	  Data Path Acceleration Architecture Ethernet driver,
> +	  supporting the Freescale QorIQ chips.
> +	  Depends on Freescale Buffer Manager and Queue Manager
> +	  driver and Frame Manager Driver.
> +
> +if FSL_DPAA_ETH
> +
> +config FSL_DPAA_CS_THRESHOLD_1G
> +	hex "Egress congestion threshold on 1G ports"
> +	depends on FSL_DPAA_ETH

This entry is inside the "if FSL_DPAA_ETH" block. So this line should be
superfluous.

> +	range 0x1000 0x10000000
> +	default "0x06000000"
> +	---help---
> +	  The size in bytes of the egress Congestion State notification threshold on 1G ports.
> +	  The 1G dTSECs can quite easily be flooded by cores doing Tx in a tight loop
> +	  (e.g. by sending UDP datagrams at "while(1) speed"),
> +	  and the larger the frame size, the more acute the problem.
> +	  So we have to find a balance between these factors:
> +	       - avoiding the device staying congested for a prolonged time (risking
> +                 the netdev watchdog to fire - see also the tx_timeout module param);
> +               - affecting performance of protocols such as TCP, which otherwise
> +	         behave well under the congestion notification mechanism;
> +	       - preventing the Tx cores from tightly-looping (as if the congestion
> +	         threshold was too low to be effective);
> +	       - running out of memory if the CS threshold is set too high.
> +
> +config FSL_DPAA_CS_THRESHOLD_10G
> +	hex "Egress congestion threshold on 10G ports"
> +	depends on FSL_DPAA_ETH

Ditto.

> +	range 0x1000 0x20000000
> +	default "0x10000000"
> +	---help ---
> +	  The size in bytes of the egress Congestion State notification threshold on 10G ports.
> +
> +config FSL_DPAA_INGRESS_CS_THRESHOLD
> +	hex "Ingress congestion threshold on FMan ports"
> +	depends on FSL_DPAA_ETH

Ditto.

> +	default "0x10000000"
> +	---help---
> +	  The size in bytes of the ingress tail-drop threshold on FMan ports.
> +	  Traffic piling up above this value will be rejected by QMan and discarded by FMan.
> +
> +endif # FSL_DPAA_ETH

A similar comment can be made for the entries added in 03/10, 05/10, and
09/10.

Thanks,


Paul Bolle
