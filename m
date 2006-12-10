From: Ralf Baechle <ralf@linux-mips.org>
Subject: [PATCH] Re: baycom_epp.c compile failure
Date: Sun, 10 Dec 2006 20:42:39 +0000
Message-ID: <20061210204239.GA14501@linux-mips.org>
References: <20061210005632.d980f651.akpm@osdl.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, "David S. Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from ftp.linux-mips.org ([194.74.144.162]:49832 "EHLO
	ftp.linux-mips.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1762555AbWLJUmo (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 10 Dec 2006 15:42:44 -0500
Received: from localhost.localdomain ([127.0.0.1]:47043 "EHLO
	dl5rb.ham-radio-op.net") by ftp.linux-mips.org with ESMTP
	id S20039343AbWLJUmn (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sun, 10 Dec 2006 20:42:43 +0000
To: Andrew Morton <akpm@osdl.org>
Content-Disposition: inline
In-Reply-To: <20061210005632.d980f651.akpm@osdl.org>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Fix foobar in 15b1c0e822f578306332d4f4c449250db5c5dceb and
e8cc49bb0fdb9e18a99e6780073d1400ba2b0d1f patch series.

Signed-off-by: Ralf Baechle <ralf@linux-mips.org>

diff --git a/drivers/net/hamradio/baycom_epp.c b/drivers/net/hamradio/baycom_epp.c
index 8a83db0..153b6dc 100644
--- a/drivers/net/hamradio/baycom_epp.c
+++ b/drivers/net/hamradio/baycom_epp.c
@@ -1177,7 +1177,7 @@ static void baycom_probe(struct net_devi
 	dev->mtu = AX25_DEF_PACLEN;        /* eth_mtu is the default */
 	dev->addr_len = AX25_ADDR_LEN;     /* sizeof an ax.25 address */
 	memcpy(dev->broadcast, &ax25_bcast, AX25_ADDR_LEN);
-	memcpy(dev->dev_addr, &ax25_nocall, AX25_ADDR_LEN);
+	memcpy(dev->dev_addr, &null_ax25_address, AX25_ADDR_LEN);
 	dev->tx_queue_len = 16;
 
 	/* New style flags */
diff --git a/include/net/ax25.h b/include/net/ax25.h
index e1d116f..14b72d8 100644
--- a/include/net/ax25.h
+++ b/include/net/ax25.h
@@ -285,6 +285,8 @@ extern struct sock *ax25_make_new(struct
 extern const ax25_address ax25_bcast;
 extern const ax25_address ax25_defaddr;
 extern const ax25_address null_ax25_address;
+extern char *ax2asc(char *buf, const ax25_address *);
+extern void asc2ax(ax25_address *addr, const char *callsign);
 extern int ax25cmp(const ax25_address *, const ax25_address *);
 extern int ax25digicmp(const ax25_digi *, const ax25_digi *);
 extern const unsigned char *ax25_addr_parse(const unsigned char *, int,
diff --git a/net/ax25/ax25_addr.c b/net/ax25/ax25_addr.c
index 21a0616..97a49c7 100644
--- a/net/ax25/ax25_addr.c
+++ b/net/ax25/ax25_addr.c
@@ -83,7 +83,7 @@ EXPORT_SYMBOL(ax2asc);
  */
 void asc2ax(ax25_address *addr, const char *callsign)
 {
-	char *s;
+	const char *s;
 	int n;
 
 	for (s = callsign, n = 0; n < 6; n++) {
