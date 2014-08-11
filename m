From: Wei Liu <wei.liu2@citrix.com>
Subject: [PATCH net v3 0/3] xen-netback: synchronisation between core driver and netback
Date: Mon, 11 Aug 2014 11:11:21 +0100
Message-ID: <1407751884-9005-1-git-send-email-wei.liu2@citrix.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: <ian.campbell@citrix.com>, <zoltan.kiss@citrix.com>,
	Wei Liu <wei.liu2@citrix.com>
To: <xen-devel@lists.xen.org>, <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp.citrix.com ([66.165.176.89]:20270 "EHLO SMTP.CITRIX.COM"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753165AbaHKKL0 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 11 Aug 2014 06:11:26 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The zero-copy netback has far more interactions with core network driver than
the old copying backend. One significant thing is that netback now relies on
a callback from core driver to correctly release resources.

However correct synchronisation between core driver and netback is missing.
Currently netback relies on a loop to wait for core driver to release
resources. This is proven not enough and erronous recently, partly due to code
structure, partly due to missing synchronisation. Short-live domains like
OpenMirage unikernels can easily trigger race in backend, rendering backend
unresponsive.

This patch series aims to slove this issue by introducing proper
synchronisation between core driver and netback.

Wei.

Change in v3: improve commit message in patch 1

Change in v2: fix Zoltan's email address in commit message

Wei Liu (3):
  xen-netback: move NAPI add/remove calls
  xen-netback: don't stop dealloc kthread too early
  xen-netback: remove loop waiting function

 drivers/net/xen-netback/common.h    |    5 +++
 drivers/net/xen-netback/interface.c |   57 +++++++++++++++--------------------
 drivers/net/xen-netback/netback.c   |   24 ++++++++++++---
 3 files changed, 49 insertions(+), 37 deletions(-)

-- 
1.7.10.4
