From: "Waskiewicz Jr, Peter P" <peter.p.waskiewicz.jr@intel.com>
Subject: RE: [PATCH] IPROUTE: Modify tc for new PRIO multiqueue behavior
Date: Fri, 4 May 2007 08:48:07 -0700
Message-ID: <D5C1322C3E673F459512FB59E0DDC32902C70FBF@orsmsx414.amr.corp.intel.com>
References: <1178236484.4068.42.camel@localhost>
Mime-Version: 1.0
Content-Type: text/plain;
	charset="us-ascii"
Content-Transfer-Encoding: 8BIT
Cc: "Patrick McHardy" <kaber@trash.net>,
	"Stephen Hemminger" <shemminger@linux-foundation.org>,
	<netdev@vger.kernel.org>, <jgarzik@pobox.com>,
	"cramerj" <cramerj@intel.com>,
	"Kok, Auke-jan H" <auke-jan.h.kok@intel.com>,
	"Leech, Christopher" <christopher.leech@intel.com>,
	<davem@davemloft.net>
To: <hadi@cyberus.ca>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga09.intel.com ([134.134.136.24]:35355 "EHLO mga09.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1030297AbXEDPsN convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 4 May 2007 11:48:13 -0400
Content-class: urn:content-classes:message
In-Reply-To: <1178236484.4068.42.camel@localhost>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

> Let me see if i got this right:
> This new standard sends _flow control_ packets per 802.1p value?

Yes.

> Sounds a bit fscked. I am assuming that the link flow control 
> is still on (not that i am a big fan).

No, it is not.  They're mutually exclusive.

> Is Datacenter ethernet the name of the standard or just a 
> marketing term?

It's the standard name, just as it's called out in the paper.

> I suspect that vendors have not yet started deploying this technology?

No, this is new stuff.

> Is there a switch out there that supports the feature? In 
> your view is this technology going to be more prelevant or 
> just a half-ass marketing adventure?

There is no hardware that exists that does this yet that I'm aware of.
My view is that this technology will actually be pretty prevalent as the
standard is ratified, and vendors begin deploying network products using
it.  I personally cringe when I have marketing people blowing smoke
about technology, and I haven't cringed much in any discussions
surrounding this technology.

> This certainly adds a new twist to the whole thing. I agree 
> that we need to support the feature and i see more room for a 
> consensus now (which was missing before). I need to think some more.

I appreciate that.

> Like i said this is very useful detail to know.
> Give me sometime to get back to you. I need to mull over it.
> My strong view is still:
> a)  the changes to be totaly transparent to the user.

The way the patches work as-is today, the user doesn't see any change
*unless* the driver underneath uses the new code.  Otherwise, everything
that exists operates just like it does now.

> b)  to have any new qdiscs (WRR for example) for multi-ring 
> hardware to benefit single-ring hardware

I agree we'll benefit from qdiscs that can help with multi-ring; I still
think a configurable PRIO (turn multi-ring on, multi-ring off) is useful
in the meantime.

> c)  no changes to the core; i can see perhaps a new call to 
> the qdisc to provide +/- credit but i need to think some more 
> about it ..

Note that the DCE spec called out here is not saying to have any of this
credit or flow control support in software, rather it's in hardware.
The only piece of this we need in the kernel is the per-queue
start/stop.  That being said, I see no other option but to change the
core (otherwise we can't know if a queue stopped before ->dequeue()).
If you can find another option to provide what we're doing without
touching the core, I'm all ears.

Thanks,

-PJ Waskiewicz
