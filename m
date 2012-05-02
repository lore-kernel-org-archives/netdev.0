From: Jason Wang <jasowang@redhat.com>
Subject: [V2 PATCH 0/9] vhost/macvtap zeropcopy fixes
Date: Wed, 02 May 2012 11:41:21 +0800
Message-ID: <20120502033901.11782.13157.stgit@amd-6168-8-1.englab.nay.redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
To: eric.dumazet@gmail.com, mst@redhat.com, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org, ebiederm@xmission.com,
	davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:1378 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752494Ab2EBDqi (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 1 May 2012 23:46:38 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This is an updated since the last series of vhost/macvtap zerocopy fixes which
fixes the the possible transmission stall, host kernel stack overflow and other
misc fixes.

Changes from V1:
- Addressing comments from Eric and Michael.
- Adding more fixes into the seires.

---

Jason Wang (9):
      macvtap: zerocopy: fix offset calculation when building skb
      macvtap: zerocopy: fix truesize underestimation
      macvtap: zerocopy: put page when fail to get all requested user pages
      macvtap: zerocopy: set SKBTX_DEV_ZEROCOPY only when skb is built successfully
      macvtap: zerocopy: validate vectors before building skb
      vhost_net: zerocopy: fix possible NULL pointer dereference of vq->bufs
      vhost_net: re-poll only on EAGAIN or ENOBUFS
      vhost_net: zerocopy: adding and signalling immediately when fully copied
      vhost: zerocopy: poll vq in zerocopy callback


 drivers/net/macvtap.c |   57 ++++++++++++++++++++++++++++++++++---------------
 drivers/vhost/net.c   |    7 ++++--
 drivers/vhost/vhost.c |    1 +
 3 files changed, 46 insertions(+), 19 deletions(-)

-- 
Jason Wang
