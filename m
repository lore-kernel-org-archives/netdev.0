From: Scott Wood <scottwood@freescale.com>
Subject: Re: [PATCH 2/2] powerpc/85xx: add Fman MDIO muxing support to the
 P4080DS
Date: Tue, 14 Aug 2012 18:06:28 -0500
Message-ID: <502AD9F4.10903@freescale.com>
References: <1344637896-14267-1-git-send-email-timur@freescale.com> <1344637896-14267-2-git-send-email-timur@freescale.com> <5F0028FE-C555-47DE-B69A-888E7322A6E1@kernel.crashing.org> <502AC7C3.9030902@freescale.com> <502AC8D3.4010602@freescale.com> <502ACA09.6070906@freescale.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: Kumar Gala <galak@kernel.crashing.org>,
	Andy Fleming <afleming@freescale.com>, <ddaney.cavm@gmail.com>,
	<linuxppc-dev@ozlabs.org>, <netdev@vger.kernel.org>
To: Timur Tabi <timur@freescale.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from va3ehsobe006.messaging.microsoft.com ([216.32.180.16]:21256
	"EHLO va3outboundpool.messaging.microsoft.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1754362Ab2HNXGh (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 14 Aug 2012 19:06:37 -0400
In-Reply-To: <502ACA09.6070906@freescale.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 08/14/2012 04:58 PM, Timur Tabi wrote:
> Scott Wood wrote:
> 
>> I think that was internally, and not on this specific comment wording.
>> I don't think that code comment adequately explains things.
> 
> I don't really have any more insight to add.

My point (at least, this part of it) was that more of the insight you've
already provided should be moved from e-mail discussion to the code comment.

>>> otherwise, the mdio-mux code would not prepare the mdio mus in time, and
>>> there would be initialization failures.  Now maybe this goes away with
>>> -EPROBE_DEFER, or maybe it doesn't.  But until we push the DPAA drivers
>>> upstream, we won't know.
>>
>> Do you know if it's theoretically supposed to be fixed and just can't
>> test it, or are you unsure of whether it's even supposed to work?
> 
> I'm not sure of anything.  For one thing, we don't implement EPROBE_DEFER
> in the DPAA drivers, so we'd probably have to fix that before anything.
> And then, I'm just guessing that's the solution.

I feel confident saying it is the solution, at least until it is
demonstrated otherwise.

>> I don't think we should be relying on the order of this list to
>> determine probe order.  For one thing, it won't work if the drivers
>> register after you create the platform devices (e.g. they're modules).
> 
> I agree we should not be relying on the order, but I don't know what to
> do.  EPROBE_DEFER was designed to handle this situation, so my
> recommendation is to worry about it later.  I can beef up the comment to
> talk about that, if you want.

If the DPAA driver doesn't implement it when it's submitted, it's a bug
in the DPAA driver and we should insist it be fixed.  I don't think we
should at all entertain the notion that careful device id list ordering
is even a potential solution.

If anything, I'd make the ordering be "wrong" to force that code path to
be tested -- though ideally there would be a more systematic approach to
such testing, that doesn't require inefficiency during normal boot.

-Scott
