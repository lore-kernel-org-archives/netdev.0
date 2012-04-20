From: John Fastabend <john.r.fastabend@intel.com>
Subject: [net-next PATCH] net: dcb: add CEE notify calls
Date: Fri, 20 Apr 2012 12:49:23 -0700
Message-ID: <20120420194923.8103.54825.stgit@jf-dev1-dcblab>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, eilong@broadcom.com,
	amirv@dev.mellanox.co.il
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga01.intel.com ([192.55.52.88]:58377 "EHLO mga01.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1749667Ab2DTUCm (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 20 Apr 2012 16:02:42 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This adds code to trigger CEE events when an APP change or setall
command is made from user space. This simplifies user space code
significantly by creating a single interface to listen on that
works with both firmware and userland agents.

And if we end up with multiple agents this keeps every thing in
sync userland agents, firmware agents, and kernel notifier consumers.

For an example agent that listens for these events see:

https://github.com/jrfastab/cgdcbxd

cgdcbxd is a daemon used to monitor DCB netlink events and manage
the net_prio control group sub-system.

Signed-off-by: John Fastabend <john.r.fastabend@intel.com>
---

 net/dcb/dcbnl.c |    2 ++
 1 files changed, 2 insertions(+), 0 deletions(-)

diff --git a/net/dcb/dcbnl.c b/net/dcb/dcbnl.c
index 8dfa1da..656c7c7 100644
--- a/net/dcb/dcbnl.c
+++ b/net/dcb/dcbnl.c
@@ -704,6 +704,7 @@ static int dcbnl_setapp(struct net_device *netdev, struct nlattr **tb,
 
 	ret = dcbnl_reply(err, RTM_SETDCB, DCB_CMD_SAPP, DCB_ATTR_APP,
 			  pid, seq, flags);
+	dcbnl_cee_notify(netdev, RTM_SETDCB, DCB_CMD_SAPP, seq, 0);
 out:
 	return ret;
 }
@@ -936,6 +937,7 @@ static int dcbnl_setall(struct net_device *netdev, struct nlattr **tb,
 
 	ret = dcbnl_reply(netdev->dcbnl_ops->setall(netdev), RTM_SETDCB,
 	                  DCB_CMD_SET_ALL, DCB_ATTR_SET_ALL, pid, seq, flags);
+	dcbnl_cee_notify(netdev, RTM_SETDCB, DCB_CMD_SET_ALL, seq, 0);
 
 	return ret;
 }
