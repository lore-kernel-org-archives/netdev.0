From: Asias He <asias.hejun@gmail.com>
Subject: [RFC V2 2/7] VSOCK: Add dgram_skb to vsock_sock
Date: Sat,  5 Jul 2014 11:23:11 +0800
Message-ID: <294e5a9eaad00941ae3125c0d1c6b25bd3368881.1404529115.git.asias.hejun@gmail.com>
References: <cover.1404529115.git.asias.hejun@gmail.com>
To: kvm@vger.kernel.org, virtualization@lists.linux-foundation.org,
	netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f53.google.com ([209.85.220.53]:39956 "EHLO
	mail-pa0-f53.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753964AbaGEDXw (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 4 Jul 2014 23:23:52 -0400
In-Reply-To: <cover.1404529115.git.asias.hejun@gmail.com>
In-Reply-To: <cover.1404529115.git.asias.hejun@gmail.com>
References: <cover.1404529115.git.asias.hejun@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Asias He <asias@redhat.com>

Signed-off-by: Asias He <asias@redhat.com>
---
 include/net/af_vsock.h   | 1 +
 net/vmw_vsock/af_vsock.c | 1 +
 2 files changed, 2 insertions(+)

diff --git a/include/net/af_vsock.h b/include/net/af_vsock.h
index 88f559a..ef668a0 100644
--- a/include/net/af_vsock.h
+++ b/include/net/af_vsock.h
@@ -58,6 +58,7 @@ struct vsock_sock {
 	 */
 	struct list_head pending_links;
 	struct list_head accept_queue;
+	struct list_head dgram_skb;
 	bool rejected;
 	struct delayed_work dwork;
 	u32 peer_shutdown;
diff --git a/net/vmw_vsock/af_vsock.c b/net/vmw_vsock/af_vsock.c
index 9b48d4e..df8781c 100644
--- a/net/vmw_vsock/af_vsock.c
+++ b/net/vmw_vsock/af_vsock.c
@@ -684,6 +684,7 @@ struct sock *__vsock_create(struct net *net,
 	vsk->listener = NULL;
 	INIT_LIST_HEAD(&vsk->pending_links);
 	INIT_LIST_HEAD(&vsk->accept_queue);
+	INIT_LIST_HEAD(&vsk->dgram_skb);
 	vsk->rejected = false;
 	vsk->sent_request = false;
 	vsk->ignore_connecting_rst = false;
-- 
1.9.3
