From: Alexander Duyck <alexander.h.duyck@intel.com>
Subject: [ethtool PATCH 0/4] Add support for network flow classifier rules
Date: Fri, 25 Feb 2011 15:48:40 -0800
Message-ID: <20110225233902.8409.74474.stgit@gitlad.jf.intel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: davem@davemloft.net, jeffrey.t.kirsher@intel.com,
	bhutchings@solarflare.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga02.intel.com ([134.134.136.20]:9921 "EHLO mga02.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755506Ab1BYXsl (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 25 Feb 2011 18:48:41 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This patch series implements the user-space portion of network flow
classifier rules.  The original patches were applied to the kernel a couple
of years ago, but the user-space side was never applied.  As such I have
gone though and updated the original patch from Santwona Behera to make it
applicable to the current ethtool git tree.

In addition this updates the network flow classification rules to handle
displaying the same fields as ntuple filters due to the fact that ntuple
display functionality had some serious issues, and provided no means for a
driver to display rules if they are stored internally.

The formatting of the man page and the help text may still need some work.
I was having difficulties determining the best way to layout the
class-rule-add and flow-type help instructions since they are mutually
exclusive but both contain a large number of possible options.

Finally there was one minor change adding ESP hashing as a separate option
to Rx-hashing that was contained in the original patch that I have moved
out into a separate patch.

---

Alexander Duyck (3):
      Add support for displaying a ntuple contained in an rx_flow_spec
      Remove strings based approach for displaying ntuple
      Add support for ESP as a separate protocol from AH

Santwona Behera (1):
      v2 Add RX packet classification interface


 Makefile.am      |    3 
 ethtool-bitops.h |   25 +
 ethtool-copy.h   |   23 +
 ethtool-util.h   |   42 ++
 ethtool.8.in     |  204 +++++----
 ethtool.c        |  344 ++++++---------
 rxclass.c        | 1241 ++++++++++++++++++++++++++++++++++++++++++++++++++++++
 7 files changed, 1573 insertions(+), 309 deletions(-)
 create mode 100644 ethtool-bitops.h
 create mode 100644 rxclass.c

-- 
