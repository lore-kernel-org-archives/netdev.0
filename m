From: Scott Wood <scottwood@freescale.com>
Subject: Re: [PATCH v13 0/6] flexcan: Add support for powerpc flexcan (freescale
 p1010)
Date: Tue, 25 Oct 2011 16:37:16 -0500
Message-ID: <4EA72C0C.3000908@freescale.com>
References: <1313551944-28603-1-git-send-email-holt@sgi.com> <16FBAA47-5133-43A1-80CE-C6D63B79FB5D@kernel.crashing.org> <20111018094328.GC22814@sgi.com> <D79CB818-C14E-4C8D-9A8D-42B39ADE20B2@kernel.crashing.org>
Mime-Version: 1.0
Content-Type: text/plain; charset="ISO-8859-1"
Content-Transfer-Encoding: 7bit
Cc: Robin Holt <holt@sgi.com>, <netdev@vger.kernel.org>,
	U Bhaskar-B22300 <B22300@freescale.com>,
	<socketcan-core@lists.berlios.de>,
	PPC list <linuxppc-dev@lists.ozlabs.org>,
	"David S. Miller" <davem@davemloft.net>
To: Kumar Gala <galak@kernel.crashing.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from ch1ehsobe001.messaging.microsoft.com ([216.32.181.181]:40995
	"EHLO ch1outboundpool.messaging.microsoft.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1753370Ab1JYVhX (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 25 Oct 2011 17:37:23 -0400
In-Reply-To: <D79CB818-C14E-4C8D-9A8D-42B39ADE20B2@kernel.crashing.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 10/18/2011 06:43 AM, Kumar Gala wrote:
> 
>>> Robin,
>>>
>>> Do you remember why we went with just 'fsl,p1010-flexcan' as the device tree compatible?  Do we feel the flex can on P1010 isn't the same as on MPC5xxx? or the ARM SoCs?
>>
>> The decision was due to the fact there is no true "generic" fsl.flexcan
>> chip free of any SOC implementation and therefore not something which
>> could be separately defined.  That decision was made by Grant Likely.
>> I will inline that email below.
>>
>> Robin
> 
> 
> Thanks, I'll look into this internally at FSL.  I think its confusing as hell to have "fsl,p1010-flexcan" in an ARM .dts

It's confusing to have devices labelled in vague ways that we can't tie
back to any real piece of hardware, or even a public architectural spec.
 If you're talking to our hardware people, ask them to put public names
and versions, guaranteed unique throughout FSL, on all of our logic
blocks -- with public block manuals that have any SW-relevant
integration parameters clearly itemized.

Why is putting "fsl,p1010-flexcan" an an ARM device any more confusing
than putting it on some PowerPC chip that is not a p1010?  Think of it
like a PCI ID, the actual value not being meaningful for much other than
its uniqueness and the ability to find a manual for the hardware.

This has been the recommended practice for quite some time.

> and don't think any reasonable ARM customer of FSL would know to put
> a PPC SOC name in their .dts.  

If an ARM device tree comes along that just has
"fsl,some-arm-chip-flexcan", so what?  Let the same driver bind against
both, again like PCI IDs.  Additional compatibles are mainly a
convenience to give things a chance to work before the driver is updated
(a frequent irritant with PCI IDs and new hardware).

Ideally we would be publishing a sample device tree for our ARM chips
and their peripherals, though. :-P

> I'll ask the HW guys what's going on
> so we can come up with a bit more generic name so we don't have to
> constantly change this.  Even if its just:
> 
> fsl,ppc-flexcan & fsl,arm-flexcan.

Why is CPU instruction set relevant?

Would a QorIQ customer think to check for an existing compatible in
mpc5xxx, or even mpc83xx or mpc86xx?

-Scott
