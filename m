From: "Waskiewicz Jr, Peter P" <peter.p.waskiewicz.jr@intel.com>
Subject: RE: [PATCH] NET: Multiqueue network device support.
Date: Tue, 5 Jun 2007 08:51:26 -0700
Message-ID: <D5C1322C3E673F459512FB59E0DDC32902F91748@orsmsx414.amr.corp.intel.com>
References: <1181044231.4075.51.camel@localhost>
Mime-Version: 1.0
Content-Type: text/plain;
	charset="us-ascii"
Content-Transfer-Encoding: 8BIT
Cc: <davem@davemloft.net>, <netdev@vger.kernel.org>, <jeff@garzik.org>,
	"Kok, Auke-jan H" <auke-jan.h.kok@intel.com>
To: <hadi@cyberus.ca>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga01.intel.com ([192.55.52.88]:27403 "EHLO mga01.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S932306AbXFEPv3 convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 5 Jun 2007 11:51:29 -0400
Content-class: urn:content-classes:message
In-Reply-To: <1181044231.4075.51.camel@localhost>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

>From a high level i see a good start that you at least have 
> a separate
> qdisc. I dont see the need for making any subqueue semantics 
> in the qdisc. We already have them.

No, we don't have subqueue semantics going directly to the hardware
subqueues.  Only in software.

> I also still dont see the need for the patching of the prio 
> qdisc or the subqueue control.

sch_rr gives a qdisc without a strict scheduling policy for people that
either want direct control of where flows go, or hardware with a
scheduler.  sch_prio can give people the flexibility to have a
scheduling policy for hardware that has none (e1000 for example).
Patrick had suggested/requested a qdisc like sch_rr before, so here it
is.  I kept sch_prio for flexibility and choice for users.

> I am now uncertain that after all those discussions (and a 
> lot other private ones) whether you understood me. We are 
> still not meeting in the middle. 

I certainly understood what you were saying, however, what I'm trying to
solve with my patches is not what you were suggesting.  A WRR scheduler,
and no exposure of hardware queues in the network stack is not what I'm
trying to solve.

> Sorry, Peter i dont mean to rain on your parade but i cant 
> let this just slide by[1]. So please give me sometime and 
> this week i will send patches to demonstrate my view. I didnt 
> mean to do that, but as i see it i have no other choice.

I don't want to seem ungrateful, but this is what I've been asking of
you since you had objections to my patches.  Patrick, Thomas, and Yi Zhu
all gave technical feedback on the patches, I defended and/or updated
the patches, and they seemed fine with them then.  However, you want
something different from what I'm doing, not a different approach for
what it is I'm proposing.  I'd love to see the patches you're thinking
of, and see if they really do solve what I'm trying to solve.

> BTW, wheres the e1000 change?

The previously posted e1000 patch for this multiqueue patchset is
identical.  I can repost it if you want, but this is just an RFC
patchset for the new qdisc, and I didn't want to cloud the point of the
RFC.

> [1] If for example you wrote a classifier or a qdisc (as in a 
> recent discussion I had with Patrick) i would say it is your 
> code and your effort and i have the choice not to use it (by 
> virtue of there being other alternatives). I have no such 
> luxury but to use the changes you make to that code path 
> whenever i use multi tx rings.

I disagree completely.  Have you seriously looked at the patches??  The
driver is in control whether or not it wants to present multiple tx
rings to the stack.  The driver has to call alloc_etherdev_mq()
explicitly to allow the stack to see the queues; otherwise, there's only
one queue presented.  I don't understand what you have a problem with
here; the API allows complete control from the driver's perspective to
use the new multiqueue codepath or not use it.  You have all the control
in the world to decide whether to use or not use the multiqueue
codepath.  Can you please explain what your real issue is here?


Cheers,

-PJ Waskiewicz
