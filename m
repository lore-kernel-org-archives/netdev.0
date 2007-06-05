From: jamal <hadi@cyberus.ca>
Subject: RE: [PATCH] NET: Multiqueue network device support.
Date: Tue, 05 Jun 2007 18:28:37 -0400
Message-ID: <1181082517.4062.31.camel@localhost>
References: <D5C1322C3E673F459512FB59E0DDC32902F91748@orsmsx414.amr.corp.intel.com>
Reply-To: hadi@cyberus.ca
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: davem@davemloft.net, netdev@vger.kernel.org, jeff@garzik.org,
	"Kok, Auke-jan H" <auke-jan.h.kok@intel.com>
To: "Waskiewicz Jr, Peter P" <peter.p.waskiewicz.jr@intel.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from nz-out-0506.google.com ([64.233.162.239]:15371 "EHLO
	nz-out-0506.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1763270AbXFEW2l (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 5 Jun 2007 18:28:41 -0400
Received: by nz-out-0506.google.com with SMTP id n1so1532968nzf
        for <netdev@vger.kernel.org>; Tue, 05 Jun 2007 15:28:40 -0700 (PDT)
In-Reply-To: <D5C1322C3E673F459512FB59E0DDC32902F91748@orsmsx414.amr.corp.intel.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Tue, 2007-05-06 at 08:51 -0700, Waskiewicz Jr, Peter P wrote:

> No, we don't have subqueue semantics going directly to the hardware
> subqueues.  Only in software.

Yes, that is one thing i was speaking against.

> sch_rr gives a qdisc without a strict scheduling policy for people that
> either want direct control of where flows go, or hardware with a
> scheduler.  sch_prio can give people the flexibility to have a
> scheduling policy for hardware that has none (e1000 for example).
> Patrick had suggested/requested a qdisc like sch_rr before, so here it
> is.  

I did too - right here:
http://marc.info/?l=linux-netdev&m=117810985623646&w=2

[..]

> > BTW, wheres the e1000 change?
> 
> The previously posted e1000 patch for this multiqueue patchset is
> identical.  I can repost it if you want, but this is just an RFC
> patchset for the new qdisc, and I didn't want to cloud the point of the
> RFC.
> 

Please send it to me privately.

> I disagree completely.  Have you seriously looked at the patches??  

yes, I have looked at the patches. And i gave you the nod that you have
improved over the previous patches. you actually semi-listened - but the
core conflicting views we have still remain.

> The
> driver is in control whether or not it wants to present multiple tx
> rings to the stack.  The driver has to call alloc_etherdev_mq()
> explicitly to allow the stack to see the queues; otherwise, there's only
> one queue presented.  I don't understand what you have a problem with
> here; the API allows complete control from the driver's perspective to
> use the new multiqueue codepath or not use it.  You have all the control
> in the world to decide whether to use or not use the multiqueue
> codepath.  Can you please explain what your real issue is here?

There will be no issue if a) multiple APIs would be allowed for driver
multi-rings[1] and b) you didnt touch the qdiscs.
 
Given that #a is not a sensible thing to do since there can only be one
API and for #b you are not compromising, what do you want me to do?

cheers,
jamal

[1] Our main difference for the API remains that according to me, the
core needs to know nothing about the multi rings and according to you,
the driver exposes such info to the core. They are two conflicting
approaches.

