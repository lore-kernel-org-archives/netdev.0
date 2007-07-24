From: PJ Waskiewicz <peter.p.waskiewicz.jr@intel.com>
Subject: [FIX] NET: Fix sch_api and sch_prio to properly set and detect the
	root qdisc
Date: Tue, 24 Jul 2007 15:33:46 -0700
Message-ID: <20070724223346.10658.80645.stgit@localhost.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, kaber@trash.net
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga02.intel.com ([134.134.136.20]:53351 "EHLO mga02.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1757434AbXGXWeD (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 24 Jul 2007 18:34:03 -0400
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

This is a patch from Patrick McHardy to fix the sch_api code, which I
went ahead and tested and made a slight fix to.  This also includes
the fix to sch_prio based on Patrick's patch.

The sch->parent handle should contain the parent qdisc ID.  When the
qdisc is the root qdisc (TC_H_ROOT), the parent handle should be the
value TC_H_ROOT.  This fixes sch_api to set this correctly on
qdisc_create() for both ingress and egress qdiscs.

Change this check in prio_tune() so that only the root qdisc can be
multiqueue-enabled; use sch->parent instead of sch->handle.

-- 
PJ Waskiewicz <peter.p.waskiewicz.jr@intel.com>
