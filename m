From: jamal <hadi@cyberus.ca>
Subject: [RFC][GENETLINK] move command capabilities  to flags
Date: Sat, 02 Dec 2006 06:56:52 -0500
Message-ID: <1165060612.3564.8.camel@localhost>
Reply-To: hadi@cyberus.ca
Mime-Version: 1.0
Content-Type: multipart/mixed; boundary="=-cpzuSaOl4K7VhuxUjO2X"
Cc: davem@davemloft.net, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from py-out-1112.google.com ([64.233.166.183]:24356 "EHLO
	py-out-1112.google.com") by vger.kernel.org with ESMTP
	id S1162969AbWLBL44 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sat, 2 Dec 2006 06:56:56 -0500
Received: by py-out-1112.google.com with SMTP id a29so1967140pyi
        for <netdev@vger.kernel.org>; Sat, 02 Dec 2006 03:56:56 -0800 (PST)
To: Thomas Graf <tgraf@suug.ch>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


--=-cpzuSaOl4K7VhuxUjO2X
Content-Type: text/plain
Content-Transfer-Encoding: 7bit


Dave,
If there is no objections on this approach, please apply this patch.
Against net-2.6.20

cheers,
jamal

--=-cpzuSaOl4K7VhuxUjO2X
Content-Disposition: attachment; filename=genl_capab_flags
Content-Type: text/plain; name=genl_capab_flags; charset=us-ascii
Content-Transfer-Encoding: 7bit

This patch moves command capabilities to command flags. Other than
being cleaner, saves several bytes.

Signed-off-by: Jamal Hadi Salim <hadi@cyberus.ca>

---
commit b6ac8f41bdd2edd9d215e376efa47261e9b118a1
tree fec2a968aad15264b30e2d550cb0c6f7939d4c93
parent 4bacaeb2cea3c6684f9b3acc54f71958bb2c25c5
author Jamal Hadi Salim <hadi@cyberus.ca> Sat, 02 Dec 2006 06:54:55 -0500
committer Jamal Hadi Salim <hadi@cyberus.ca> Sat, 02 Dec 2006 06:54:55 -0500

 include/linux/genetlink.h |    3 +++
 net/netlink/genetlink.c   |   16 +++++++---------
 2 files changed, 10 insertions(+), 9 deletions(-)

diff --git a/include/linux/genetlink.h b/include/linux/genetlink.h
index 9049dc6..3bd75c2 100644
--- a/include/linux/genetlink.h
+++ b/include/linux/genetlink.h
@@ -17,6 +17,9 @@ struct genlmsghdr {
 #define GENL_HDRLEN	NLMSG_ALIGN(sizeof(struct genlmsghdr))
 
 #define GENL_ADMIN_PERM		0x01
+#define GENL_CMD_CAP_DO		0x02
+#define GENL_CMD_CAP_DUMP	0x04
+#define GENL_CMD_CAP_HASPOL	0x08
 
 /*
  * List of reserved static generic netlink identifiers:
diff --git a/net/netlink/genetlink.c b/net/netlink/genetlink.c
index cc874f0..adfc203 100644
--- a/net/netlink/genetlink.c
+++ b/net/netlink/genetlink.c
@@ -143,6 +143,13 @@ int genl_register_ops(struct genl_family *family, struct genl_ops *ops)
 		goto errout;
 	}
 
+	if (ops->dumpit)
+		ops->flags |= GENL_CMD_CAP_DO;
+	if (ops->doit)
+		ops->flags |= GENL_CMD_CAP_DUMP;
+	if (ops->policy)
+		ops->flags |= GENL_CMD_CAP_HASPOL;
+
 	genl_lock();
 	list_add_tail(&ops->ops_list, &family->ops_list);
 	genl_unlock();
@@ -425,15 +432,6 @@ static int ctrl_fill_info(struct genl_family *family, u32 pid, u32 seq,
 			NLA_PUT_U32(skb, CTRL_ATTR_OP_ID, ops->cmd);
 			NLA_PUT_U32(skb, CTRL_ATTR_OP_FLAGS, ops->flags);
 
-			if (ops->policy)
-				NLA_PUT_FLAG(skb, CTRL_ATTR_OP_POLICY);
-
-			if (ops->doit)
-				NLA_PUT_FLAG(skb, CTRL_ATTR_OP_DOIT);
-
-			if (ops->dumpit)
-				NLA_PUT_FLAG(skb, CTRL_ATTR_OP_DUMPIT);
-
 			nla_nest_end(skb, nest);
 		}
 

--=-cpzuSaOl4K7VhuxUjO2X--

