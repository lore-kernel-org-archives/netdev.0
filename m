From: Daniel Borkmann <dborkman@redhat.com>
Subject: [PATCH net-next] net: tcp_probe: adapt tbuf size for recent changes
Date: Tue,  3 Sep 2013 18:24:02 +0200
Message-ID: <1378225442-6676-1-git-send-email-dborkman@redhat.com>
Cc: netdev@vger.kernel.org
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:11520 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754053Ab3ICQYE (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 3 Sep 2013 12:24:04 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

With recent changes in tcp_probe module (e.g. f925d0a62d ("net: tcp_probe:
add IPv6 support")) we also need to take into account that tbuf needs to
be updated as format string will be further expanded. tbuf sits on the stack
in tcpprobe_read() function that is invoked when user space reads procfs
file /proc/net/tcpprobe, hence not fast path as in jtcp_rcv_established().
Having a size similarly as in sctp_probe module of 256 bytes is fully
sufficient for that, we need theoretical maximum of 252 bytes otherwise we
could get truncated.

Signed-off-by: Daniel Borkmann <dborkman@redhat.com>
---
 net/ipv4/tcp_probe.c | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/net/ipv4/tcp_probe.c b/net/ipv4/tcp_probe.c
index 622a437..1f6aa54 100644
--- a/net/ipv4/tcp_probe.c
+++ b/net/ipv4/tcp_probe.c
@@ -218,7 +218,7 @@ static ssize_t tcpprobe_read(struct file *file, char __user *buf,
 		return -EINVAL;
 
 	while (cnt < len) {
-		char tbuf[164];
+		char tbuf[256];
 		int width;
 
 		/* Wait for data in buffer */
-- 
1.7.11.7
