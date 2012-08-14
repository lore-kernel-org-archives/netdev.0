From: Scott Wood <scottwood@freescale.com>
Subject: Re: [PATCH 2/2] powerpc/85xx: add Fman MDIO muxing support to the
 P4080DS
Date: Tue, 14 Aug 2012 18:12:29 -0500
Message-ID: <502ADB5D.9070309@freescale.com>
References: <1344637896-14267-1-git-send-email-timur@freescale.com> <1344637896-14267-2-git-send-email-timur@freescale.com> <5F0028FE-C555-47DE-B69A-888E7322A6E1@kernel.crashing.org> <502AC7C3.9030902@freescale.com> <502AC8D3.4010602@freescale.com> <502ACA09.6070906@freescale.com> <502AD9F4.10903@freescale.com> <502ADA75.7020200@freescale.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: Kumar Gala <galak@kernel.crashing.org>,
	Andy Fleming <afleming@freescale.com>, <ddaney.cavm@gmail.com>,
	<linuxppc-dev@ozlabs.org>, <netdev@vger.kernel.org>
To: Timur Tabi <timur@freescale.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from am1ehsobe002.messaging.microsoft.com ([213.199.154.205]:20488
	"EHLO am1outboundpool.messaging.microsoft.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1753858Ab2HNXMg (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 14 Aug 2012 19:12:36 -0400
In-Reply-To: <502ADA75.7020200@freescale.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 08/14/2012 06:08 PM, Timur Tabi wrote:
> Scott Wood wrote:
>>
>> If anything, I'd make the ordering be "wrong" to force that code path to
>> be tested -- though ideally there would be a more systematic approach to
>> such testing, that doesn't require inefficiency during normal boot.
> 
> I can't force the ordering to be wrong, because it's the only entry in the
> list. The DPAA entries are not there yet.

Right, I mean once the DPAA entries are added.

> This is what I have now:
> 
> static const struct of_device_id of_device_ids[] __devinitconst = {
> 	{
> 		.compatible	= "simple-bus"
> 	},
> 	{
> 		.compatible	= "fsl,srio",
> 	},
> 	{
> 		.compatible	= "fsl,p4080-pcie",
> 	},
> 	{
> 		.compatible	= "fsl,qoriq-pcie-v2.2",
> 	},
> 	{
> 		.compatible	= "fsl,qoriq-pcie-v2.3",
> 	},
> 	{
> 		.compatible	= "fsl,qoriq-pcie-v2.4",
> 	},
> 	/* The following two are for the Freescale hypervisor */
> 	{
> 		.name		= "hypervisor",
> 	},
> 	{
> 		.name		= "handles",
> 	},
> 	{
> 		/*
> 		 * Warning: this entry might need to be located before those
> 		 * for the Fman Ethernet nodes, although using EPROBE_DEFER
> 		 * in the DPAA drivers could fix that.
> 		 */
> 		.compatible	= "mdio-mux",
> 	},

I'd either say nothing here or say only "The ethernet driver should use
EPROBE_DEFER to ensure that the mdio-mux is probed first".  Don't give
whoever submits the DPAA ethernet driver the idea that relying on list
order is an acceptable solution.

-Scott
