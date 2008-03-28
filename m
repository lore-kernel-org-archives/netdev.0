From: "Denis V. Lunev" <den@openvz.org>
Subject: [PATCH 3/11 net-2.6.26] [DCCP]: dccp_v(4|6)_ctl_socket is leaked.
Date: Fri, 28 Mar 2008 12:08:50 +0300
Message-ID: <1206695338-5947-3-git-send-email-den@openvz.org>
References: <1206695071.3271.8.camel@iris.sw.ru>
Cc: netdev@vger.kernel.org, containers@lists.osdl.org,
	"Denis V. Lunev" <den@openvz.org>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mailhub.sw.ru ([195.214.232.25]:39248 "EHLO relay.sw.ru"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753155AbYC1JIa (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 28 Mar 2008 05:08:30 -0400
In-Reply-To: <1206695071.3271.8.camel@iris.sw.ru>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This seems a purism as module can't be unloaded, but though if cleanup method
is present it should be correct and clean all staff created.

Signed-off-by: Denis V. Lunev <den@openvz.org>
---
 net/dccp/ipv4.c |    1 +
 net/dccp/ipv6.c |    1 +
 2 files changed, 2 insertions(+), 0 deletions(-)

diff --git a/net/dccp/ipv4.c b/net/dccp/ipv4.c
index 79a9a4a..4ee34db 100644
--- a/net/dccp/ipv4.c
+++ b/net/dccp/ipv4.c
@@ -1023,6 +1023,7 @@ out_proto_unregister:
 
 static void __exit dccp_v4_exit(void)
 {
+	sock_release(dccp_v4_ctl_sk->sk_socket);
 	inet_unregister_protosw(&dccp_v4_protosw);
 	inet_del_protocol(&dccp_v4_protocol, IPPROTO_DCCP);
 	proto_unregister(&dccp_v4_prot);
diff --git a/net/dccp/ipv6.c b/net/dccp/ipv6.c
index 249640d..85665d5 100644
--- a/net/dccp/ipv6.c
+++ b/net/dccp/ipv6.c
@@ -1205,6 +1205,7 @@ out_unregister_proto:
 
 static void __exit dccp_v6_exit(void)
 {
+	sock_release(dccp_v6_ctl_sk->sk_socket);
 	inet6_del_protocol(&dccp_v6_protocol, IPPROTO_DCCP);
 	inet6_unregister_protosw(&dccp_v6_protosw);
 	proto_unregister(&dccp_v6_prot);
-- 
1.5.3.rc5

