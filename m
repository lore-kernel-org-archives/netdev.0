From: jamal <hadi@cyberus.ca>
Subject: RE: [PATCH] IPROUTE: Modify tc for new PRIO multiqueue behavior
Date: Thu, 03 May 2007 19:54:44 -0400
Message-ID: <1178236484.4068.42.camel@localhost>
References: <D5C1322C3E673F459512FB59E0DDC32902C70A5C@orsmsx414.amr.corp.intel.com>
Reply-To: hadi@cyberus.ca
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: Patrick McHardy <kaber@trash.net>,
	Stephen Hemminger <shemminger@linux-foundation.org>,
	netdev@vger.kernel.org, jgarzik@pobox.com,
	cramerj <cramerj@intel.com>,
	"Kok, Auke-jan H" <auke-jan.h.kok@intel.com>,
	"Leech, Christopher" <christopher.leech@intel.com>,
	davem@davemloft.net
To: "Waskiewicz Jr, Peter P" <peter.p.waskiewicz.jr@intel.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from wx-out-0506.google.com ([66.249.82.224]:41022 "EHLO
	wx-out-0506.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754767AbXECXyt (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 3 May 2007 19:54:49 -0400
Received: by wx-out-0506.google.com with SMTP id h31so597571wxd
        for <netdev@vger.kernel.org>; Thu, 03 May 2007 16:54:49 -0700 (PDT)
In-Reply-To: <D5C1322C3E673F459512FB59E0DDC32902C70A5C@orsmsx414.amr.corp.intel.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Thu, 2007-03-05 at 14:03 -0700, Waskiewicz Jr, Peter P wrote:

> Here is a paper that describes what exactly we're trying to do:
> http://www.ieee802.org/3/ar/public/0503/wadekar_1_0503.pdf.  Basically
> we need the ability to pause a queue independantly of another queue.

Ok, this is useful info Peter. 

Let me see if i got this right:
This new standard sends _flow control_ packets per 802.1p value?
Sounds a bit fscked. I am assuming that the link flow control is still
on (not that i am a big fan). And i wonder how it fits to end2end TCP
flow control etc; cant find much details on google. It almost smells
like credit/rate based ATM flow control in disguise. Almost like these
folks think in terms of ATM VCs..
Is Datacenter ethernet the name of the standard or just a marketing
term?
I suspect that vendors have not yet started deploying this technology?
Is there a switch out there that supports the feature? In your view
is this technology going to be more prelevant or just a half-ass
marketing adventure?

> Because of this requirement, the kernel needs visibility into the driver
> and to have knowledge of and provide control of each queue.  Please note
> that the API I'm proposing is a generic representation of the Datacenter
> Ethernet mentioned in the paper; I figured if we're putting in an
> interface to support it, it should be generic so other technologies out
> there could easily use it.

This certainly adds a new twist to the whole thing. I agree that we need
to support the feature and i see more room for a consensus now (which
was missing before). I need to think some more.

> Hopefully that paper can help people understand the motivation why I've
> done things the way they are in the patches.  Given this information,
> I'd really like to solicit feedback on the patches as they stand (both
> approach and implementation).

Like i said this is very useful detail to know.
Give me sometime to get back to you. I need to mull over it.
My strong view is still:
a)  the changes to be totaly transparent to the user.
b)  to have any new qdiscs (WRR for example) for multi-ring hardware to
benefit single-ring hardware
c)  no changes to the core; i can see perhaps a new call to the
qdisc to provide +/- credit but i need to think some more about it ..

If you can achieve those goals, we can go a long way ...

cheers,
jamal

