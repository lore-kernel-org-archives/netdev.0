From: Ben Hutchings <bhutchings@solarflare.com>
Subject: Re: [net-next 11/36] bnx2x: MDC/MDIO CL45 IOCTLs
Date: Thu, 13 Aug 2009 14:57:36 +0100
Message-ID: <1250171856.2778.8.camel@achroite>
References: <1250101388.27379.163.camel@lb-tlvb-eilong>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: David Miller <davem@davemloft.net>, netdev@vger.kernel.org
To: eilong@broadcom.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from smarthost02.mail.zen.net.uk ([212.23.3.141]:43124 "EHLO
	smarthost02.mail.zen.net.uk" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1752251AbZHMN5j (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 13 Aug 2009 09:57:39 -0400
In-Reply-To: <1250101388.27379.163.camel@lb-tlvb-eilong>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, 2009-08-12 at 21:23 +0300, Eilon Greenstein wrote:
> As suggested by Ben Hutchings <bhutchings@solarflare.com>, using the MDC/MDIO
> IOCTL
> 
> Signed-off-by: Eilon Greenstein <eilong@broadcom.com>
> ---
[...]
> @@ -11419,6 +11458,14 @@ static int __devinit bnx2x_init_dev(struct pci_dev *pdev,
>  	dev->vlan_features |= NETIF_F_TSO6;
>  #endif
>  
> +	/* get_port_hwinfo() will set prtad and mmds properly */
> +	bp->mdio.prtad = MDIO_PRTAD_NONE;
> +	bp->mdio.mmds = 0;

I didn't see any code to change mmds.

> +	bp->mdio.mode_support = MDIO_SUPPORTS_C45 | MDIO_EMULATE_C22;

MDIO_EMULATE_C22 means the mdio module will map a few clause 22
registers to clause 45 (and reject access to all other clause 22
registers), and you will never be passed devad = MDIO_DEVAD_NONE.

If you want to support clause 22 register access yourself then use
MDIO_SUPPORTS_C22.

Ben.

-- 
Ben Hutchings, Senior Software Engineer, Solarflare Communications
Not speaking for my employer; that's the marketing department's job.
They asked us to note that Solarflare product names are trademarked.

