From: Alexander Duyck <alexander.h.duyck@intel.com>
Subject: [ethtool PATCH 0/4] v6 Add support for network flow classifier
Date: Wed, 04 May 2011 11:41:30 -0700
Message-ID: <20110504183752.26394.29231.stgit@gitlad.jf.intel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: davem@davemloft.net, jeffrey.t.kirsher@intel.com, dm@chelsio.com,
	bhutchings@solarflare.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga02.intel.com ([134.134.136.20]:47845 "EHLO mga02.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751051Ab1EDSlc (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 4 May 2011 14:41:32 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This series is nearly identical to the last series with only a few changes in
the RX packet classification interface patch.  Specifically I have narrowed
down the rule manager to the point where it is only used to identify a
location for a rule if the rule location is unspecified.  The display
functionality for rules now just pulls the rule list in and goes through the
list from top to bottom displaying the rules instead of initializing the rule
manager and pulling the rules form there.

The main advantage to this approach is that the rule manager could easily be
replaced by a future ioctl call and on the failure of that ioctl call with a
return of EOPNOTSUPP it should be easy to fall back and just use the rule
manager.

Thanks,

Alex

---

Alexander Duyck (3):
      Add support for __be64 and bitops, centralize several needed macros
      Cleanup defines and header includes to address several issues
      ethtool: remove strings based approach for displaying n-tuple

Santwona Behera (1):
      v6 Add RX packet classification interface


 Makefile.am      |    3 
 ethtool-bitops.h |   25 +
 ethtool-util.h   |   47 ++
 ethtool.8.in     |  194 +++++-----
 ethtool.c        |  449 +++++++++++------------
 rxclass.c        | 1073 ++++++++++++++++++++++++++++++++++++++++++++++++++++++
 6 files changed, 1467 insertions(+), 324 deletions(-)
 create mode 100644 ethtool-bitops.h
 create mode 100644 rxclass.c

-- 
