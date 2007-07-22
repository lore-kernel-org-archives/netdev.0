From: Patrick McHardy <kaber@trash.net>
Subject: Re: Question: how to detect if a qdisc is root or not?
Date: Sun, 22 Jul 2007 18:24:16 +0200
Message-ID: <46A384B0.2030404@trash.net>
References: <D5C1322C3E673F459512FB59E0DDC3290344621B@orsmsx414.amr.corp.intel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-15
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: "Waskiewicz Jr, Peter P" <peter.p.waskiewicz.jr@intel.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from stinky.trash.net ([213.144.137.162]:43382 "EHLO
	stinky.trash.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755232AbXGVQ0Z (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 22 Jul 2007 12:26:25 -0400
In-Reply-To: <D5C1322C3E673F459512FB59E0DDC3290344621B@orsmsx414.amr.corp.intel.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Waskiewicz Jr, Peter P wrote:
>>I dont think I understand. Whats the problem with setting 
>>sch->parent on initialization instead on grafting as I did in 
>>my example patch?
>>Please explain the problems arrising on unload in detail.
> 
> 
> sch->parent is getting set on initialization, and for the root and
> ingress qdiscs, it's left at zero.  If I change that value, when the
> root qdisc is unloaded and pfifo_fast is put back into place, the
> qdisc_destroy() walks the tree and attempts to free memory from the
> handle pointed at by sch->parent.


First of all, qdisc destruction never propagates up, only down
the tree. Secondly neither qdisc_destroy nor pfifo nor prio
even look at sch->parent. So this is completely wrong, the only
place where sch->parent is used for walking through the tree
is qdisc_tree_decrease_qlen.

> It stops when sch->parent is NULL,

Where are you getting this? sch->parent is an *integer*.

> so
> sch->parent is actually being set as intended.  The only thing that
> confused me is that nowhere in the qdisc is TC_H_ROOT included
> explicitly, rather, the root qdisc is where sch->parent is NULL.
> 
> So I misunderstood what was actually wrong.  The qdisc code is ok as-is,
> it's just that the top-level qdisc (root and ingress) have a sch->parent
> of NULL, which is being set correctly today.
> 
> Hope that clarifies.

Not at all :)
