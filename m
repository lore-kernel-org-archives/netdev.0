From: "Waskiewicz Jr, Peter P" <peter.p.waskiewicz.jr@intel.com>
Subject: RE: [PATCH 2/3] NET: [SCHED] Qdisc changes and sch_rr added for multiqueue
Date: Mon, 18 Jun 2007 14:04:11 -0700
Message-ID: <D5C1322C3E673F459512FB59E0DDC329030D5A10@orsmsx414.amr.corp.intel.com>
References: <4676F111.4000105@trash.net>
Mime-Version: 1.0
Content-Type: text/plain;
	charset="us-ascii"
Content-Transfer-Encoding: 8BIT
Cc: <davem@davemloft.net>, <netdev@vger.kernel.org>, <jeff@garzik.org>,
	"Kok, Auke-jan H" <auke-jan.h.kok@intel.com>, <hadi@cyberus.ca>
To: "Patrick McHardy" <kaber@trash.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga09.intel.com ([134.134.136.24]:39036 "EHLO mga09.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1764229AbXFRVEO convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 18 Jun 2007 17:04:14 -0400
Content-class: urn:content-classes:message
In-Reply-To: <4676F111.4000105@trash.net>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

> > Hmm.  This is the sch_prio from the first 2.6.23-dev tree.  I'll 
> > resync and make sure it's the correct one.
> 
> Current 2.6.22-rc and net-2.6.23 have
> 
>         if (band >= q->bands)

I just pulled 2.6.23 down, and see that is true.  I must have had that
left over.  I'll fix that.

> > I'm not sure I understand what you mean here about nested 
> attributes.
> 
> 
> Nested netlink attributes, like most qdisc use, instead of 
> struct tc_rr_qopt (or additionally). The way you've done it 
> makes it hard to add further attributes later.

I'm going to need to think about this more, since I'm not immediately
getting what you're referring to.  I see the qdisc using tc_prio_qopt as
a single member; do you have an example outside of the qdiscs I can look
at and see what you're referring to?  Please bear with me: my netlink
skills are still very green.

> 
> BTw, couldn't you just merge sch_rr with prio? AFAICT you 
> only need a new dequeue function, a new struct Qdisc_ops and 
> a MODULE_ALIAS.

Are you suggesting a module that can determine RR or PRIO at runtime?
Because the two are so similar, I definitely thought about combining
them, but because of the dequeue difference, you'd need a load-time
switch to determine which mode to run the module in.  That would break
ABI for sch_prio, which I was trying to avoid.

Thanks Patrick,
-PJ
