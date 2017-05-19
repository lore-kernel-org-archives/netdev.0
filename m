From: Stephen Hemminger <stephen@networkplumber.org>
Subject: [PATCH net-next 5/9] tcpnv: do not export local function
Date: Fri, 19 May 2017 09:55:52 -0700
Message-ID: <20170519165556.483-6-sthemmin@microsoft.com>
References: <20170519165556.483-1-sthemmin@microsoft.com>
Cc: netdev@vger.kernel.org, Stephen Hemminger <sthemmin@microsoft.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pg0-f53.google.com ([74.125.83.53]:35013 "EHLO
        mail-pg0-f53.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1752261AbdESQ4K (ORCPT
        <rfc822;netdev@vger.kernel.org>); Fri, 19 May 2017 12:56:10 -0400
Received: by mail-pg0-f53.google.com with SMTP id q125so40712762pgq.2
        for <netdev@vger.kernel.org>; Fri, 19 May 2017 09:56:10 -0700 (PDT)
In-Reply-To: <20170519165556.483-1-sthemmin@microsoft.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The TCP New Vegas congestion control was exporting an internal
function tcpnv_get_info which is not used by any other in tree
kernel code. Make it static.

Signed-off-by: Stephen Hemminger <sthemmin@microsoft.com>
---
 net/ipv4/tcp_nv.c | 5 ++---
 1 file changed, 2 insertions(+), 3 deletions(-)

diff --git a/net/ipv4/tcp_nv.c b/net/ipv4/tcp_nv.c
index 5de82a8d4d87..6d650ed3cb59 100644
--- a/net/ipv4/tcp_nv.c
+++ b/net/ipv4/tcp_nv.c
@@ -424,8 +424,8 @@ static void tcpnv_acked(struct sock *sk, const struct ack_sample *sample)
 }
 
 /* Extract info for Tcp socket info provided via netlink */
-size_t tcpnv_get_info(struct sock *sk, u32 ext, int *attr,
-		      union tcp_cc_info *info)
+static size_t tcpnv_get_info(struct sock *sk, u32 ext, int *attr,
+			     union tcp_cc_info *info)
 {
 	const struct tcpnv *ca = inet_csk_ca(sk);
 
@@ -440,7 +440,6 @@ size_t tcpnv_get_info(struct sock *sk, u32 ext, int *attr,
 	}
 	return 0;
 }
-EXPORT_SYMBOL_GPL(tcpnv_get_info);
 
 static struct tcp_congestion_ops tcpnv __read_mostly = {
 	.init		= tcpnv_init,
-- 
2.11.0
