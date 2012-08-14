From: Timur Tabi <timur@freescale.com>
Subject: Re: [PATCH 2/2] powerpc/85xx: add Fman MDIO muxing support to the
 P4080DS
Date: Tue, 14 Aug 2012 16:48:51 -0500
Message-ID: <502AC7C3.9030902@freescale.com>
References: <1344637896-14267-1-git-send-email-timur@freescale.com> <1344637896-14267-2-git-send-email-timur@freescale.com> <5F0028FE-C555-47DE-B69A-888E7322A6E1@kernel.crashing.org>
Mime-Version: 1.0
Content-Type: text/plain; charset="ISO-8859-1"
Content-Transfer-Encoding: 7bit
Cc: Andy Fleming <afleming@freescale.com>,
	Scott Wood <scottwood@freescale.com>, <ddaney.cavm@gmail.com>,
	<linuxppc-dev@ozlabs.org>, <netdev@vger.kernel.org>
To: Kumar Gala <galak@kernel.crashing.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from va3ehsobe001.messaging.microsoft.com ([216.32.180.11]:18294
	"EHLO va3outboundpool.messaging.microsoft.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1750836Ab2HNVs4 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 14 Aug 2012 17:48:56 -0400
In-Reply-To: <5F0028FE-C555-47DE-B69A-888E7322A6E1@kernel.crashing.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Kumar Gala wrote:
>> > +	{
>> > +		/*
>> > +		 * Warning: this entry might need to be located before those
>> > +		 * for the Fman Ethernet nodes.
>> > +		 */
>> > +		.compatible	= "mdio-mux",
>> > +	},
>> > 	{}
>> > };
> Under what condition would that be the case?

We had this discussion already.  In my tests, I had to locate this entry
before these entries:

	{
		.compatible	= "fsl,dpaa"
	},
	{
		.compatible	= "fsl,srio",
	},

otherwise, the mdio-mux code would not prepare the mdio mus in time, and
there would be initialization failures.  Now maybe this goes away with
-EPROBE_DEFER, or maybe it doesn't.  But until we push the DPAA drivers
upstream, we won't know.

-- 
Timur Tabi
Linux kernel developer at Freescale
