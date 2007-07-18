From: "Waskiewicz Jr, Peter P" <peter.p.waskiewicz.jr@intel.com>
Subject: RE: Question: how to detect if a qdisc is root or not?
Date: Wed, 18 Jul 2007 16:42:12 -0700
Message-ID: <D5C1322C3E673F459512FB59E0DDC3290340F8AF@orsmsx414.amr.corp.intel.com>
References: <469EA4CE.4000402@trash.net>
Mime-Version: 1.0
Content-Type: text/plain;
	charset="us-ascii"
Content-Transfer-Encoding: 8BIT
Cc: <netdev@vger.kernel.org>
To: "Patrick McHardy" <kaber@trash.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga01.intel.com ([192.55.52.88]:46845 "EHLO mga01.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S965040AbXGRXmO convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 18 Jul 2007 19:42:14 -0400
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

That's where I'm messing around right now, and I did see that.  Let me
put it in and test.  If all is well, I'll post a patch.

Thanks for the help Patrick.

-PJ Waskiewicz
