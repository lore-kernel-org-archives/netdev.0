From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [net-2.6 PATCH 2/3] net: fix nlmsg len size for skb when error bit is
	set.
Date: Fri, 25 Sep 2009 16:11:44 -0700
Message-ID: <20090925231144.23450.79736.stgit@localhost.localdomain>
References: <20090925231124.23450.94680.stgit@localhost.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, gospo@redhat.com,
	John Fastabend <john.r.fastabend@intel.com>,
	Jeff Kirsher <jeffrey.t.kirsher@intel.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from qmta13.westchester.pa.mail.comcast.net ([76.96.59.243]:40097
	"EHLO QMTA13.westchester.pa.mail.comcast.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1752744AbZIYXL6 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 25 Sep 2009 19:11:58 -0400
In-Reply-To: <20090925231124.23450.94680.stgit@localhost.localdomain>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: John Fastabend <john.r.fastabend@intel.com>

Currently, the nlmsg->len field is not set correctly in  netlink_ack()
for ack messages that include the nlmsg of the error frame.  This
corrects the length field passed to __nlmsg_put to use the correct
payload size.

Signed-off-by: John Fastabend <john.r.fastabend@intel.com>
Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
---

 net/netlink/af_netlink.c |    2 +-
 1 files changed, 1 insertions(+), 1 deletions(-)

diff --git a/net/netlink/af_netlink.c b/net/netlink/af_netlink.c
index a4bafbf..dd85320 100644
--- a/net/netlink/af_netlink.c
+++ b/net/netlink/af_netlink.c
@@ -1788,7 +1788,7 @@ void netlink_ack(struct sk_buff *in_skb, struct nlmsghdr *nlh, int err)
 	}
 
 	rep = __nlmsg_put(skb, NETLINK_CB(in_skb).pid, nlh->nlmsg_seq,
-			  NLMSG_ERROR, sizeof(struct nlmsgerr), 0);
+			  NLMSG_ERROR, payload, 0);
 	errmsg = nlmsg_data(rep);
 	errmsg->error = err;
 	memcpy(&errmsg->msg, nlh, err ? nlh->nlmsg_len : sizeof(*nlh));

