From: Alexander Duyck <alexander.h.duyck@intel.com>
Subject: [ethtool PATCH 0/4] Add support for network flow classifier
Date: Tue, 03 May 2011 09:12:05 -0700
Message-ID: <20110503160547.29251.84333.stgit@gitlad.jf.intel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: davem@davemloft.net, jeffrey.t.kirsher@intel.com,
	bhutchings@solarflare.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga14.intel.com ([143.182.124.37]:57513 "EHLO mga14.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753290Ab1ECQMJ (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 3 May 2011 12:12:09 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This series is version 5 of the patches for adding network flow classifier
rules support to ethtool.  The main changes are that I split a general header
cleanup off into a separate patch, I combined the documentation update into
the addition of the RX packet classification interface, and I generally
cleaned up the code further for when we need to maintain the rule table and
when we don't.  As a result I dropped a few dozen lines of code related to
finding and deleting a rule from the table since we only need the table to
determine which rules are present.

I will be submitting a set of patches through Jeff Kirsher once these patches
are accepted to allow for ixgbe to make use of the network flow classifier
rules interface.

Thanks,

Alex

---

Alexander Duyck (3):
      Add support for __be64 and bitops, centralize several needed macros
      Cleanup defines and header includes to address several issues
      ethtool: remove strings based approach for displaying n-tuple

Santwona Behera (1):
      v5 Add RX packet classification interface


 Makefile.am      |    3 
 ethtool-bitops.h |   25 +
 ethtool-util.h   |   47 ++
 ethtool.8.in     |  194 +++++-----
 ethtool.c        |  449 ++++++++++++-----------
 rxclass.c        | 1039 ++++++++++++++++++++++++++++++++++++++++++++++++++++++
 6 files changed, 1433 insertions(+), 324 deletions(-)
 create mode 100644 ethtool-bitops.h
 create mode 100644 rxclass.c

-- 
