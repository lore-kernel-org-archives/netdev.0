From: Jeff Garzik <jeff@garzik.org>
Subject: [PATCH 0/5] forcedeth: several proposed updates for testing
Date: Sat, 6 Oct 2007 11:12:50 -0400
Message-ID: <20071006151250.GA17020@havoc.gtf.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: LKML <linux-kernel@vger.kernel.org>,
	Andrew Morton <akpm@linux-foundation.org>
To: netdev@vger.kernel.org, Ayaz Abdulla <aabdulla@nvidia.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from havoc.gtf.org ([69.61.125.42]:59336 "EHLO havoc.gtf.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1760050AbXJFPMw (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sat, 6 Oct 2007 11:12:52 -0400
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


The 'fe-lock' branch of
git://git.kernel.org/pub/scm/linux/kernel/git/jgarzik/netdev-2.6.git fe-lock

contains the following changes that I would like to get tested:

      [netdrvr] forcedeth: make NAPI unconditional
      [netdrvr] forcedeth: interrupt handling cleanup
      [netdrvr] forcedeth: process TX completions using NAPI
      [netdrvr] forcedeth: internal simplification and cleanups
      [netdrvr] forcedeth: timer overhaul

These are intended for feedback and testing, NOT for merging.

The goals of these changes are:
* move the driver towards a more sane, simple, easy to verify locking
  setup -- irq handler would often acquire/release the lock twice
  for each interrupt -- and hopefully

* to eliminate a rarely used, apparently fragile locking scheme that
  includes heavy use of disable_irq().  this tool is most often employed
  during NIC reset/reconfiguration, so satisfying this goal implies
  changing the way NIC reset and config are accomplished.

Miscellaneous notes:
* using the new napi_struct stuff in net-2.6.24, the TX completion
  process has been moved to a -separate- NAPI polling channel.  thus
  there are now two napi_structs, one for RX and one for TX, independent
  of each other.

* I feel TX NAPI is a useful tool, because it provides an independent TX
  process control point and system load feedback point.
  Thus I felt this was slightly superior to tasklets.

* But who knows if this is a good idea?  :)  I am interested in
  feedback and criticism on this issue.

