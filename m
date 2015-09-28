From: Alexander Duyck <aduyck@mirantis.com>
Subject: [net-next PATCH 1/3] net/ipv4: Pass proto as u8 instead of u16 in
 ip_check_mc_rcu
Date: Mon, 28 Sep 2015 11:10:31 -0700
Message-ID: <20150928181031.20320.2151.stgit@ahduyck-vm-fedora22>
References: <20150928175512.20320.97537.stgit@ahduyck-vm-fedora22>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: davem@davemloft.net
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f44.google.com ([209.85.220.44]:34359 "EHLO
	mail-pa0-f44.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756421AbbI1SKd (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 28 Sep 2015 14:10:33 -0400
Received: by padhy16 with SMTP id hy16so180774275pad.1
        for <netdev@vger.kernel.org>; Mon, 28 Sep 2015 11:10:33 -0700 (PDT)
In-Reply-To: <20150928175512.20320.97537.stgit@ahduyck-vm-fedora22>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This patch updates ip_check_mc_rcu so that protocol is passed as a u8
instead of a u16.

The motivation is just to avoid any unneeded type transitions since some
systems will require an instruction to zero extend a u8 field to a u16.
Also it makes it a bit more readable as to the fact that protocol is a u8
so there are no byte ordering changes needed to pass it.

Signed-off-by: Alexander Duyck <aduyck@mirantis.com>
---
 include/linux/igmp.h |    2 +-
 net/ipv4/igmp.c      |    2 +-
 2 files changed, 2 insertions(+), 2 deletions(-)

diff --git a/include/linux/igmp.h b/include/linux/igmp.h
index 908429216d9f..9c9de11549a7 100644
--- a/include/linux/igmp.h
+++ b/include/linux/igmp.h
@@ -110,7 +110,7 @@ struct ip_mc_list {
 #define IGMPV3_QQIC(value) IGMPV3_EXP(0x80, 4, 3, value)
 #define IGMPV3_MRC(value) IGMPV3_EXP(0x80, 4, 3, value)
 
-extern int ip_check_mc_rcu(struct in_device *dev, __be32 mc_addr, __be32 src_addr, u16 proto);
+extern int ip_check_mc_rcu(struct in_device *dev, __be32 mc_addr, __be32 src_addr, u8 proto);
 extern int igmp_rcv(struct sk_buff *);
 extern int ip_mc_join_group(struct sock *sk, struct ip_mreqn *imr);
 extern int ip_mc_leave_group(struct sock *sk, struct ip_mreqn *imr);
diff --git a/net/ipv4/igmp.c b/net/ipv4/igmp.c
index d38b8b61eaee..de6d4c8ba600 100644
--- a/net/ipv4/igmp.c
+++ b/net/ipv4/igmp.c
@@ -2569,7 +2569,7 @@ void ip_mc_drop_socket(struct sock *sk)
 }
 
 /* called with rcu_read_lock() */
-int ip_check_mc_rcu(struct in_device *in_dev, __be32 mc_addr, __be32 src_addr, u16 proto)
+int ip_check_mc_rcu(struct in_device *in_dev, __be32 mc_addr, __be32 src_addr, u8 proto)
 {
 	struct ip_mc_list *im;
 	struct ip_mc_list __rcu **mc_hash;
