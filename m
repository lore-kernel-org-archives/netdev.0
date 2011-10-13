From: David Daney <david.daney@cavium.com>
Subject: Re: [PATCH v3 1/3] phylib: Convert MDIO and PHY Lib drivers to support
 10G
Date: Thu, 13 Oct 2011 09:18:18 -0700
Message-ID: <4E970F4A.3080405@cavium.com>
References: <1318516660-25452-1-git-send-email-afleming@freescale.com> <1318516660-25452-2-git-send-email-afleming@freescale.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: davem@davemloft.net, netdev@vger.kernel.org
To: Andy Fleming <afleming@freescale.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail3.caviumnetworks.com ([12.108.191.235]:10299 "EHLO
	mail3.caviumnetworks.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755978Ab1JMQSW (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 13 Oct 2011 12:18:22 -0400
In-Reply-To: <1318516660-25452-2-git-send-email-afleming@freescale.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 10/13/2011 07:37 AM, Andy Fleming wrote:

>   /**
> + * is_10g_interface - Distinguishes 10G from 10/100/1000
> + * @interface: PHY interface type
> + *
> + * Returns true if the passed interface is capable of 10G,
> + * and therefore indicates the need for Clause-45-style
> + * MDIO transactions.
> + *
> + * For now, XGMII is the only 10G interface
> + */
> +static inline bool is_10g_interface(phy_interface_t interface)
> +{
> +	return interface == PHY_INTERFACE_MODE_XGMII;
> +}
> +

The packet interface to the PHY and the protocol used on its MDIO bus 
are two separate things.  This function conflates them.

Although it is not perfect, my alternate approach:

http://marc.info/?l=linux-netdev&m=131844284003871

Adds a flag bit to struct phy_device that indicates the MDIO bus 
protocol to be used.  Have you considered doing something like that instead?

David Daney
