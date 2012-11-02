From: John Fastabend <john.r.fastabend@intel.com>
Subject: [net PATCH] rtnetlink: Use nlmsg type RTM_NEWNEIGH from dflt fdb dump
Date: Thu, 01 Nov 2012 19:23:10 -0700
Message-ID: <20121102022310.2692.60718.stgit@jf-dev1-dcblab>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga03.intel.com ([143.182.124.21]:41561 "EHLO mga03.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1758264Ab2KBCkl (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 1 Nov 2012 22:40:41 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Change the dflt fdb dump handler to use RTM_NEWNEIGH to
be compatible with bridge dump routines.

The dump reply from the network driver handlers should
match the reply from bridge handler. The fact they were
not in the ixgbe case was effectively a bug. This patch
resolves it.

Applications that were not checking the nlmsg type will
continue to work. And now applications that do check
the type will work as expected.

Signed-off-by: John Fastabend <john.r.fastabend@intel.com>
---

 net/core/rtnetlink.c |    3 ++-
 1 files changed, 2 insertions(+), 1 deletions(-)

diff --git a/net/core/rtnetlink.c b/net/core/rtnetlink.c
index 76d4c2c..fad649a 100644
--- a/net/core/rtnetlink.c
+++ b/net/core/rtnetlink.c
@@ -2192,7 +2192,8 @@ static int nlmsg_populate_fdb(struct sk_buff *skb,
 			goto skip;
 
 		err = nlmsg_populate_fdb_fill(skb, dev, ha->addr,
-					      portid, seq, 0, NTF_SELF);
+					      portid, seq,
+					      RTM_NEWNEIGH, NTF_SELF);
 		if (err < 0)
 			return err;
 skip:
