From: "Waskiewicz Jr, Peter P" <peter.p.waskiewicz.jr@intel.com>
Subject: RE: Question: how to detect if a qdisc is root or not?
Date: Fri, 20 Jul 2007 15:59:25 -0700
Message-ID: <D5C1322C3E673F459512FB59E0DDC329034460BA@orsmsx414.amr.corp.intel.com>
References: <469EA4CE.4000402@trash.net>
Mime-Version: 1.0
Content-Type: text/plain;
	charset="us-ascii"
Content-Transfer-Encoding: 8BIT
Cc: <netdev@vger.kernel.org>
To: "Patrick McHardy" <kaber@trash.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga09.intel.com ([134.134.136.24]:10028 "EHLO mga09.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1763234AbXGTW71 convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 20 Jul 2007 18:59:27 -0400
Content-class: urn:content-classes:message
In-Reply-To: <469EA4CE.4000402@trash.net>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

> Its set after grafting the parent, which is after initialization.
> I think what should work is to set it in qdisc_create 
> instead, sch_api.c around line 490:
> 
> +	sch->parent = handle;
> 
>         if (handle == TC_H_INGRESS) {
>                 sch->flags |= TCQ_F_INGRESS;
>                 sch->stats_lock = &dev->ingress_lock; ...
> 
> and remove the initialization in qdisc_graft. That would 
> additionally have the benefit that ingress qdiscs also have 
> it initialized properly.

I just sent out a patch to fix this.  Sorry for the delay; my
development machine oops'd in the middle of some disk I/O, and it
corrupted part of the inode table...the ext3 journal application seemed
to make it worse too.  Rebuilt the machine, so I'm back on my feet.

Anyways, I tried a few different things, and what it looks like is
sch->parent will be NULL (0) for the top-level device.  This is correct,
and trying to mess with that screws up qdisc_graft() when unloading the
qdisc.  I also tried adding a TCQ_F_ROOT flag to sch->flags when classid
is TC_H_ROOT, but that also screwed up unloading the qdisc.

The ingress qdisc does have the parent handle set correctly, namely
NULL, since it will always be the top-level qdisc on ingress sessions.

Thx Patrick,
-PJ Waskiewicz
