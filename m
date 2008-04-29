From: Miika Komu <miika@iki.fi>
Subject: [PATCH] [NET] Exporting of some IPv6 symbols for HIP and SHIM6
 experimentation
Date: Wed, 30 Apr 2008 00:07:56 +0300 (EEST)
Message-ID: <Pine.SOL.4.64.0804292344490.29274@kekkonen.cs.hut.fi>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII; format=flowed
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from twilight.cs.hut.fi ([130.233.40.5]:61965 "EHLO
	twilight.cs.hut.fi" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751582AbYD2VbB (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 29 Apr 2008 17:31:01 -0400
Received: from kekkonen (kekkonen.cs.hut.fi [130.233.41.50])
	by twilight.cs.hut.fi (Postfix) with ESMTP id 404732F37
	for <netdev@vger.kernel.org>; Wed, 30 Apr 2008 00:07:56 +0300 (EEST)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Host Identity Protocol (HIP, RFC5201, RFC4423) and Site Multihoming for 
IPv6 (SHIM6, draft-ietf-shim6-proto-10) define new APIs in the URLs below. 
This patch exports some IPv6 symbols to help in initial IETF 
experimentation with external kernel modules for HIP and SHIM6 socket 
handlers. The SHIM6 and HIP socket handlers are built on top of IPv6 
socket handlers.
http://www.ietf.org/internet-drafts/draft-ietf-hip-native-api-04.txt
http://www.ietf.org/internet-drafts/draft-ietf-shim6-multihome-shim-api-05.txt


Signed-off-by: Miika Komu <miika@iki.fi>
--

diff --git a/net/ipv6/af_inet6.c b/net/ipv6/af_inet6.c
index 3c6aafb..ec96224 100644
--- a/net/ipv6/af_inet6.c
+++ b/net/ipv6/af_inet6.c
@@ -239,7 +239,7 @@ out_rcu_unlock:
  	rcu_read_unlock();
  	goto out;
  }
-
+EXPORT_SYMBOL(inet6_create);

  /* bind for INET6 API */
  int inet6_bind(struct socket *sock, struct sockaddr *uaddr, int addr_len)
@@ -498,6 +498,7 @@ const struct proto_ops inet6_stream_ops = {
  	.compat_getsockopt = compat_sock_common_getsockopt,
  #endif
  };
+EXPORT_SYMBOL(inet6_stream_ops);

  const struct proto_ops inet6_dgram_ops = {
  	.family		   = PF_INET6,
@@ -523,6 +524,7 @@ const struct proto_ops inet6_dgram_ops = {
  	.compat_getsockopt = compat_sock_common_getsockopt,
  #endif
  };
+EXPORT_SYMBOL(inet6_dgram_ops);

  static struct net_proto_family inet6_family_ops = {
  	.family = PF_INET6,
