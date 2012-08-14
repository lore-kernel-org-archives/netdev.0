From: Scott Wood <scottwood@freescale.com>
Subject: Re: [PATCH 2/2] powerpc/85xx: add Fman MDIO muxing support to the
 P4080DS
Date: Tue, 14 Aug 2012 16:53:23 -0500
Message-ID: <502AC8D3.4010602@freescale.com>
References: <1344637896-14267-1-git-send-email-timur@freescale.com> <1344637896-14267-2-git-send-email-timur@freescale.com> <5F0028FE-C555-47DE-B69A-888E7322A6E1@kernel.crashing.org> <502AC7C3.9030902@freescale.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: Kumar Gala <galak@kernel.crashing.org>,
	Andy Fleming <afleming@freescale.com>, <ddaney.cavm@gmail.com>,
	<linuxppc-dev@ozlabs.org>, <netdev@vger.kernel.org>
To: Timur Tabi <timur@freescale.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from co1ehsobe005.messaging.microsoft.com ([216.32.180.188]:19433
	"EHLO co1outboundpool.messaging.microsoft.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1751369Ab2HNVx3 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 14 Aug 2012 17:53:29 -0400
In-Reply-To: <502AC7C3.9030902@freescale.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 08/14/2012 04:48 PM, Timur Tabi wrote:
> Kumar Gala wrote:
>>>> +	{
>>>> +		/*
>>>> +		 * Warning: this entry might need to be located before those
>>>> +		 * for the Fman Ethernet nodes.
>>>> +		 */
>>>> +		.compatible	= "mdio-mux",
>>>> +	},
>>>> 	{}
>>>> };
>> Under what condition would that be the case?
> 
> We had this discussion already.

I think that was internally, and not on this specific comment wording.
I don't think that code comment adequately explains things.

> otherwise, the mdio-mux code would not prepare the mdio mus in time, and
> there would be initialization failures.  Now maybe this goes away with
> -EPROBE_DEFER, or maybe it doesn't.  But until we push the DPAA drivers
> upstream, we won't know.

Do you know if it's theoretically supposed to be fixed and just can't
test it, or are you unsure of whether it's even supposed to work?

I don't think we should be relying on the order of this list to
determine probe order.  For one thing, it won't work if the drivers
register after you create the platform devices (e.g. they're modules).

-Scott
