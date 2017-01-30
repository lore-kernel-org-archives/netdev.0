From: Vladislav Yasevich <vyasevich@gmail.com>
Subject: [PATCH net] ipv6:  Paritially checksum full MTU frames
Date: Sun, 29 Jan 2017 22:52:53 -0500
Message-ID: <1485748373-14909-1-git-send-email-vyasevic@redhat.com>
Cc: Vladislav Yasevich <vyasevic@redhat.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-qk0-f193.google.com ([209.85.220.193]:34248 "EHLO
        mail-qk0-f193.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751138AbdA3DxD (ORCPT
        <rfc822;netdev@vger.kernel.org>); Sun, 29 Jan 2017 22:53:03 -0500
Received: by mail-qk0-f193.google.com with SMTP id e1so17179086qkh.1
        for <netdev@vger.kernel.org>; Sun, 29 Jan 2017 19:53:02 -0800 (PST)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

IPv6 will mark data that is smaller that mtu - headersize as
CHECKSUM_PARTIAL, but if the data will completely fill the mtu,
the packet checksum will be computed in software instead.
Extend the conditional to include the data that fills the mtu
as well.

Signed-off-by: Vladislav Yasevich <vyasevic@redhat.com>
---
 net/ipv6/ip6_output.c | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/net/ipv6/ip6_output.c b/net/ipv6/ip6_output.c
index 2c0df09..b6a94ff 100644
--- a/net/ipv6/ip6_output.c
+++ b/net/ipv6/ip6_output.c
@@ -1344,7 +1344,7 @@ static int __ip6_append_data(struct sock *sk,
 	 */
 	if (transhdrlen && sk->sk_protocol == IPPROTO_UDP &&
 	    headersize == sizeof(struct ipv6hdr) &&
-	    length < mtu - headersize &&
+	    length <= mtu - headersize &&
 	    !(flags & MSG_MORE) &&
 	    rt->dst.dev->features & (NETIF_F_IPV6_CSUM | NETIF_F_HW_CSUM))
 		csummode = CHECKSUM_PARTIAL;
-- 
2.7.4
