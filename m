From: Patrick McHardy <kaber@trash.net>
Subject: Re: Question: how to detect if a qdisc is root or not?
Date: Thu, 19 Jul 2007 01:23:50 +0200
Message-ID: <469EA106.5010106@trash.net>
References: <D5C1322C3E673F459512FB59E0DDC3290340F84A@orsmsx414.amr.corp.intel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-15
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: "Waskiewicz Jr, Peter P" <peter.p.waskiewicz.jr@intel.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from stinky.trash.net ([213.144.137.162]:50701 "EHLO
	stinky.trash.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752437AbXGRXY2 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 18 Jul 2007 19:24:28 -0400
In-Reply-To: <D5C1322C3E673F459512FB59E0DDC3290340F84A@orsmsx414.amr.corp.intel.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Waskiewicz Jr, Peter P wrote:
> I've been tracking down an issue with the recent multiqueue code,
> specifically with sch_prio and sch_rr loading as a root qdisc.  Right
> now, we do not want to allow child qdiscs of sch_rr and sch_prio to load
> with multiqueue enabled; we want to restrict multiqueue-enabled qdiscs
> to the root qdisc (since this is the only thing to push into the
> device).  The issue I have is I don't know how to detect if the qdisc
> I'm currently processing is the root qdisc, or if it's a child.  From
> sch_prio.c:
> 
>         q->mq = RTA_GET_FLAG(tb[TCA_PRIO_MQ - 1]);
>         if (q->mq) {
>                 if (sch->handle != TC_H_ROOT)
>                         return -EINVAL;
> 
>                 if (netif_is_multiqueue(sch->dev)) { 
> 
> Unfortunately, this code isn't working.  This sch->handle is the handle
> assigned to the qdisc upon creation, and it's not TC_H_ROOT.


You're right, thats a bug. TC_H_ROOT is the parent ID, which is
stored in sch->parent. IIRC its also passed to the ->init() function.

