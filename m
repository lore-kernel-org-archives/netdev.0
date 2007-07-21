From: Patrick McHardy <kaber@trash.net>
Subject: Re: Question: how to detect if a qdisc is root or not?
Date: Sat, 21 Jul 2007 06:01:07 +0200
Message-ID: <46A18503.8000800@trash.net>
References: <D5C1322C3E673F459512FB59E0DDC329034460BA@orsmsx414.amr.corp.intel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-15
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: "Waskiewicz Jr, Peter P" <peter.p.waskiewicz.jr@intel.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from stinky.trash.net ([213.144.137.162]:42851 "EHLO
	stinky.trash.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755128AbXGUECj (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 21 Jul 2007 00:02:39 -0400
In-Reply-To: <D5C1322C3E673F459512FB59E0DDC329034460BA@orsmsx414.amr.corp.intel.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Waskiewicz Jr, Peter P wrote:
>>Its set after grafting the parent, which is after initialization.
>>I think what should work is to set it in qdisc_create 
>>instead, sch_api.c around line 490:
>>
>>+	sch->parent = handle;
>>
>>        if (handle == TC_H_INGRESS) {
>>                sch->flags |= TCQ_F_INGRESS;
>>                sch->stats_lock = &dev->ingress_lock; ...
>>
>>and remove the initialization in qdisc_graft. That would 
>>additionally have the benefit that ingress qdiscs also have 
>>it initialized properly.
> 
> 
> I just sent out a patch to fix this.


I didn't see it yet.

> Sorry for the delay; my
> development machine oops'd in the middle of some disk I/O, and it
> corrupted part of the inode table...the ext3 journal application seemed
> to make it worse too.  Rebuilt the machine, so I'm back on my feet.


No worries :)

> Anyways, I tried a few different things, and what it looks like is
> sch->parent will be NULL (0) for the top-level device.  This is correct,
> and trying to mess with that screws up qdisc_graft() when unloading the
> qdisc.  I also tried adding a TCQ_F_ROOT flag to sch->flags when classid
> is TC_H_ROOT, but that also screwed up unloading the qdisc.


I dont think I understand. Whats the problem with setting sch->parent
on initialization instead on grafting as I did in my example patch?
Please explain the problems arrising on unload in detail.


