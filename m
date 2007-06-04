From: PJ Waskiewicz <peter.p.waskiewicz.jr@intel.com>
Subject: [RFC] NET: Multiple queue hardware support
Date: Mon, 04 Jun 2007 14:40:37 -0700
Message-ID: <20070604214037.1524.58506.stgit@localhost.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, jeff@garzik.org, auke-jan.h.kok@intel.com
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga09.intel.com ([134.134.136.24]:23177 "EHLO mga09.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752479AbXFDVkl (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 4 Jun 2007 17:40:41 -0400
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

This patchset is an updated version of previous multiqueue network device
support patches.  The general approach of introducing a new API for multiqueue
network devices to register with the stack has remained.  The changes include
adding a round-robin qdisc, heavily based on sch_prio, which will allow
queueing to hardware with no OS-enforced queuing policy.  sch_prio still has
the multiqueue code in it, but has a Kconfig option to compile it out of the
qdisc.  This allows people with hardware containing scheduling policies to
use sch_rr (round-robin), and others without scheduling policies in hardware
to continue using sch_prio if they wish to have some notion of scheduling
priority.

The patches to iproute2 for tc will be sent separately, to support sch_rr.

I'm soliciting feedback for a 2.6.23 submission.  Thanks.

-- 
PJ Waskiewicz <peter.p.waskiewicz.jr@intel.com>
