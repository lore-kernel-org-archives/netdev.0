From: Alexander Duyck <alexander.h.duyck@intel.com>
Subject: [PATCH 0/2] Cleanups for head_frag usage and tcp_try_coalese
Date: Wed, 02 May 2012 20:38:50 -0700
Message-ID: <20120503033018.5482.89902.stgit@gitlad.jf.intel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: davem@davemloft.net
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga09.intel.com ([134.134.136.24]:58896 "EHLO mga09.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753137Ab2ECDih (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 2 May 2012 23:38:37 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

I wrote up these patches earlier today to address issues related to the
splitting of reference counting into two seperate counts in the case of
skbs containing a head frag.  In addition I have a secondary patch for
tcp_try_coalesce which is meant to be a general cleanup as I found it
difficult to read through the code as it was.

I have done some performance testing on the series with netperf and saw no
appreciable difference after these changes for the non-cloned case.
---

Alexander Duyck (2):
      tcp: cleanup tcp_try_coalesce
      net: Stop decapitating clones that have a head_frag


 net/core/skbuff.c    |    2 +
 net/ipv4/tcp_input.c |   85 +++++++++++++++++++++++++-------------------------
 2 files changed, 44 insertions(+), 43 deletions(-)

-- 
