From: Alexander Duyck <alexander.h.duyck@intel.com>
Subject: [ethtool PATCH 0/2] Add support for RX network flow classifier rules
Date: Thu, 10 Feb 2011 17:18:28 -0800
Message-ID: <20110211010806.23554.98333.stgit@gitlad.jf.intel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: bhutchings@solarflare.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga01.intel.com ([192.55.52.88]:21645 "EHLO mga01.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1756899Ab1BKBS3 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 10 Feb 2011 20:18:29 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

These two patches add support for the RX network flow classifier set and get
rules calls already supported by the kernel.  The first patch is actually just
a cleanup patch in the manpage to make it a bit easier to do the value/mask
pairing follow ons in the second patch.

The second patch is the meat of the changes and implements the packet
classifier interface.  In updating and testing it I found a number of issues
that had to be addressed.  In resolving them though I found several features
that I felt were better off removed such as prioritization of filters which
was causing multiple issues including memory leaks and non-constructive
blocking of filter insertions due to the state of expanded priorities not
being saved.

I'm still currently exploring my options in resolving the needs for ixgbe to
have the ability to retain and display its filters and plan to submit RFC
patches in the next few days to get some feedback on that.

Thanks,

Alex

---

Alexander Duyck (1):
      Add macro for displaying [value N] formatting to manpage

Santwona Behera (1):
      Add RX packet classification interface


 Makefile.am      |    3 
 ethtool-bitops.h |   25 ++
 ethtool-util.h   |   13 +
 ethtool.8.in     |  203 +++++++++-----
 ethtool.c        |  144 +++++++++-
 rxclass.c        |  809 ++++++++++++++++++++++++++++++++++++++++++++++++++++++
 6 files changed, 1115 insertions(+), 82 deletions(-)
 create mode 100644 ethtool-bitops.h
 create mode 100644 rxclass.c

-- 
