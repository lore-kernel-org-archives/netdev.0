From: "Waskiewicz Jr, Peter P" <peter.p.waskiewicz.jr@intel.com>
Subject: RE: [PATCH] NET: Multiqueue network device support.
Date: Mon, 11 Jun 2007 11:15:32 -0700
Message-ID: <D5C1322C3E673F459512FB59E0DDC3290303AB41@orsmsx414.amr.corp.intel.com>
References: <466D8EF2.50203@trash.net>
Mime-Version: 1.0
Content-Type: text/plain;
	charset="us-ascii"
Content-Transfer-Encoding: 8BIT
Cc: <davem@davemloft.net>, <netdev@vger.kernel.org>, <jeff@garzik.org>,
	"Kok, Auke-jan H" <auke-jan.h.kok@intel.com>
To: "Patrick McHardy" <kaber@trash.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga09.intel.com ([134.134.136.24]:24516 "EHLO mga09.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751127AbXFKSPg convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 11 Jun 2007 14:15:36 -0400
Content-class: urn:content-classes:message
In-Reply-To: <466D8EF2.50203@trash.net>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

> I think grepping will help more than testing :)
> 
> The only issue I can see is that packets going to a 
> multiqueue device that doesn't have a multiqueue aware qdisc 
> attached will get a random value. So you would have to 
> conditionally reset it before ->enqueue.

I currently clear queue_mapping before ->enqueue().  Perhaps keeping
queue_mapping in there might solve needing a conditional in the hotpath.
Let me think about this one.

> Another question is what to do about other hard_start_xmit callers.
> Independant of which field is used, should the classification 
> that may have happend on a different device be retained (TC 
> actions again)?

The two cases I can think of here are ip forwarding and bonding.  In the
case of bonding, things should be fine since the bonded device will only
have one "ring."  Therefore if the underlying slave devices are
heterogenous, there shouldn't be a problem retaining the previous TC
classification; if the device has its own qdisc and classifiers, it can
override it.

For ip forwarding, I believe it will also be ok since ultimately the
device doing the last transmit will have his classifiers applied and
remap skb's if necessary.  Either way, before it gets enqueued through
dev_queue_xmit(), the value will get cleared, so having an artifact
laying around won't be possible.

If that's not what you're referring to, please let me know.

Thanks,
-PJ Waskiewicz
