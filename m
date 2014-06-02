From: Wei Liu <wei.liu2@citrix.com>
Subject: [PATCH v9 0/7] xen-net{back,front}: Multiple transmit and receive queues
Date: Mon, 2 Jun 2014 11:50:05 +0100
Message-ID: <1401706212-8208-1-git-send-email-wei.liu2@citrix.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: <ian.campbell@citrix.com>, <david.vrabel@citrix.com>,
	<zoltan.kiss@citrix.com>, <paul.durrant@citrix.com>,
	<a.j.bennieston@gmail.com>, Wei Liu <wei.liu2@citrix.com>
To: <xen-devel@lists.xen.org>, <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp.citrix.com ([66.165.176.89]:26241 "EHLO SMTP.CITRIX.COM"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752258AbaFBKuN (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 2 Jun 2014 06:50:13 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This is rebased version of Andrew's V8 patch series. The original cover letter
can be found at 
  http://lwn.net/Articles/598559/
or with message ID:
  <1400075550-4580-1-git-send-email-andrew.bennieston@citrix.com>

I rebased this on top of net-next. No functional change is introduced.  The
patch that needed some extra care was "xen-netback: Factor queue-specific data
into queue struct" because it clashed with a fix introduced in net. A simple
test of creating guest, iperf, then shutting down guest worked as expected.

The last patch fixes a minor problem that queue name is not initialised in
xen-netfront, resulting in names like "-tx" "-rx" in /proc/interrupt.

Wei.

Andrew J. Bennieston (5):
  xen-netback: Move grant_copy_op array back into struct xenvif.
  xen-netback: Add support for multiple queues
  xen-netfront: Factor queue-specific data into queue struct.
  xen-netfront: Add support for multiple queues
  xen-net{back,front}: Document multi-queue feature in netif.h

Wei Liu (2):
  xen-netback: Factor queue-specific data into queue struct
  xen-netfront: initialise queue name in xennet_init_queue

 drivers/net/xen-netback/common.h    |  107 ++--
 drivers/net/xen-netback/interface.c |  522 ++++++++++------
 drivers/net/xen-netback/netback.c   |  718 +++++++++++-----------
 drivers/net/xen-netback/xenbus.c    |  182 +++++-
 drivers/net/xen-netfront.c          | 1121 ++++++++++++++++++++++-------------
 include/xen/interface/io/netif.h    |   53 ++
 6 files changed, 1680 insertions(+), 1023 deletions(-)

-- 
1.7.10.4
