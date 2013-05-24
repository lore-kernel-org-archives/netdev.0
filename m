From: Wei Liu <wei.liu2@citrix.com>
Subject: [PATCH net-next 0/3] xen-netback: switch to NAPI + kthread 1:1 model
Date: Fri, 24 May 2013 11:32:30 +0100
Message-ID: <1369391553-16835-1-git-send-email-wei.liu2@citrix.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: <ian.campbell@citrix.com>, <konrad.wilk@oracle.com>,
	Wei Liu <wei.liu2@citrix.com>
To: <xen-devel@lists.xen.org>, <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp.citrix.com ([66.165.176.89]:29464 "EHLO SMTP.CITRIX.COM"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1760354Ab3EXKcf (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 24 May 2013 06:32:35 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This series implements NAPI + kthread 1:1 model for Xen netback.

This model
 - provides better scheduling fairness among vifs
 - is prerequisite for implementing multiqueue for Xen network driver

The first two patches are ground work for the third patch. They aim to reduce
memory footprint of netback.

The third patch has the real meat:
 - make use of NAPI to mitigate interrupt 
 - kthreads are not bound to CPUs any more, so that we can take advantage of
   backend scheduler and trust it to do the right thing

Wei Liu (3):
  xen-netback: page pool support
  xen-netback: switch to per-cpu scratch space
  xen-netback: switch to NAPI + kthread 1:1 model

 drivers/net/xen-netback/Makefile    |    2 +-
 drivers/net/xen-netback/common.h    |   92 ++--
 drivers/net/xen-netback/interface.c |  124 +++--
 drivers/net/xen-netback/netback.c   |  977 +++++++++++++++--------------------
 drivers/net/xen-netback/page_pool.c |  186 +++++++
 drivers/net/xen-netback/page_pool.h |   60 +++
 6 files changed, 812 insertions(+), 629 deletions(-)
 create mode 100644 drivers/net/xen-netback/page_pool.c
 create mode 100644 drivers/net/xen-netback/page_pool.h

-- 
1.7.10.4
