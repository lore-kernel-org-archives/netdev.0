From: "Waskiewicz Jr, Peter P" <peter.p.waskiewicz.jr@intel.com>
Subject: RE: [PATCH] NET: Fix sch_prio to detect the root qdisc loading
Date: Sun, 22 Jul 2007 11:56:24 -0700
Message-ID: <D5C1322C3E673F459512FB59E0DDC329034462BB@orsmsx414.amr.corp.intel.com>
References: <46A386A0.4050406@trash.net>
Mime-Version: 1.0
Content-Type: text/plain;
	charset="us-ascii"
Content-Transfer-Encoding: 8BIT
Cc: <davem@davemloft.net>, <netdev@vger.kernel.org>, <jeff@garzik.org>
To: "Patrick McHardy" <kaber@trash.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga01.intel.com ([192.55.52.88]:34260 "EHLO mga01.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1759696AbXGVS4q convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 22 Jul 2007 14:56:46 -0400
Content-class: urn:content-classes:message
In-Reply-To: <46A386A0.4050406@trash.net>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


> As explained in my last mail, sch->parent is an integer. And 
> it is set when grafting the qdisc, not on initilization, so 
> it is always 0 here when coming from prio_init.
> 
> This untested patch should make sure its always set correctly.

Yes, I'm using NULL and 0 interchangeably here, since in the sch_api
code, qdisc_graft(), sch->parent is referenced using NULL and not 0.  I
know it's a u32, and the value is getting set to the proper handle when
the qdisc is not the root qdisc.  When it's the root qdisc, it's left to
be 0.

This patch was tested as well, but looking at the history now, I didn't
set bands correctly, so that's why the multiqueue case failed.  My
mistake, and I'll keep working on this.


Sorry for the extra noise,
-PJ
