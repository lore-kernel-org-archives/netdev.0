From: Stephen Hemminger <stephen@networkplumber.org>
Subject: [PATCH net-next 10/12] vxlan:  use initializer for dummy structures
Date: Mon, 10 Jun 2013 13:24:40 -0700
Message-ID: <20130610132440.07cd0833@nehalam.linuxnetplumber.net>
References: <20130610200524.721617349@vyatta.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org,
	Stephen Hemminger <stephen@networkplumber.org>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f53.google.com ([209.85.220.53]:47542 "EHLO
	mail-pa0-f53.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752599Ab3FJUZs (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 10 Jun 2013 16:25:48 -0400
Received: by mail-pa0-f53.google.com with SMTP id tj12so2963131pac.26
        for <netdev@vger.kernel.org>; Mon, 10 Jun 2013 13:25:47 -0700 (PDT)
In-Reply-To: <20130610200524.721617349@vyatta.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

For the notification code, a couple of places build fdb entries on
the stack, use structure initialization instead and fix formatting.

Signed-off-by: Stephen Hemminger <stephen@networkplumber.org>


--- a/drivers/net/vxlan.c	2013-06-10 12:20:03.034052087 -0700
+++ b/drivers/net/vxlan.c	2013-06-10 12:20:04.266038079 -0700
@@ -311,14 +311,13 @@ errout:
 static void vxlan_ip_miss(struct net_device *dev, __be32 ipa)
 {
 	struct vxlan_dev *vxlan = netdev_priv(dev);
-	struct vxlan_fdb f;
-	struct vxlan_rdst remote;
-
-	memset(&f, 0, sizeof f);
-	f.state = NUD_STALE;
-
-	remote.remote_ip = ipa; /* goes to NDA_DST */
-	remote.remote_vni = VXLAN_N_VID;
+	struct vxlan_fdb f = {
+		.state = NUD_STALE,
+	};
+	struct vxlan_rdst remote = {
+		.remote_ip = ipa, /* goes to NDA_DST */
+		.remote_vni = VXLAN_N_VID,
+	};
 
 	INIT_LIST_HEAD(&f.remotes);
 	list_add_rcu(&remote.list, &f.remotes);
@@ -328,11 +327,11 @@ static void vxlan_ip_miss(struct net_dev
 
 static void vxlan_fdb_miss(struct vxlan_dev *vxlan, const u8 eth_addr[ETH_ALEN])
 {
-	struct vxlan_fdb	f;
+	struct vxlan_fdb f = {
+		.state = NUD_STALE,
+	};
 
-	memset(&f, 0, sizeof f);
 	INIT_LIST_HEAD(&f.remotes);
-	f.state = NUD_STALE;
 	memcpy(f.eth_addr, eth_addr, ETH_ALEN);
 
 	vxlan_fdb_notify(vxlan, &f, RTM_GETNEIGH);
@@ -1501,6 +1500,7 @@ static struct vxlan_sock *vxlan_socket_c
 	struct sockaddr_in vxlan_addr = {
 		.sin_family = AF_INET,
 		.sin_addr.s_addr = htonl(INADDR_ANY),
+		.sin_port = port,
 	};
 	int rc;
 	unsigned int h;
@@ -1526,8 +1526,6 @@ static struct vxlan_sock *vxlan_socket_c
 	sk = vs->sock->sk;
 	sk_change_net(sk, net);
 
-	vxlan_addr.sin_port = port;
-
 	rc = kernel_bind(vs->sock, (struct sockaddr *) &vxlan_addr,
 			 sizeof(vxlan_addr));
 	if (rc < 0) {
