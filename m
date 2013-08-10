From: Stephen Hemminger <stephen@networkplumber.org>
Subject: [PATCH net-next] pptp: fix byte order warnings
Date: Sat, 10 Aug 2013 15:22:58 -0700
Message-ID: <20130810152258.1cef6d89@nehalam.linuxnetplumber.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>, Dmitry Kozlov <xeb@mail.ru>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pd0-f176.google.com ([209.85.192.176]:44308 "EHLO
	mail-pd0-f176.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1758881Ab3HJWXC (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 10 Aug 2013 18:23:02 -0400
Received: by mail-pd0-f176.google.com with SMTP id q10so1898750pdj.7
        for <netdev@vger.kernel.org>; Sat, 10 Aug 2013 15:23:01 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Pptp driver has lots of byte order warnings from sparse.
This was because the on-the-wire header is in network byte order (obviously)
but the definition did not reflect that.

Also, the address structure to user space actually put the call id
in host order. Rather than break ABI compatibility, just acknowledge
the existing design.

Signed-off-by: Stephen Hemminger <stephen@networkplumber.org>


--- a/drivers/net/ppp/pptp.c	2013-08-10 10:36:10.365515260 -0700
+++ b/drivers/net/ppp/pptp.c	2013-08-10 15:17:38.514965016 -0700
@@ -83,11 +83,11 @@ static const struct proto_ops pptp_ops;
 struct pptp_gre_header {
 	u8  flags;
 	u8  ver;
-	u16 protocol;
-	u16 payload_len;
-	u16 call_id;
-	u32 seq;
-	u32 ack;
+	__be16 protocol;
+	__be16 payload_len;
+	__be16 call_id;
+	__be32 seq;
+	__be32 ack;
 } __packed;
 
 static struct pppox_sock *lookup_chan(u16 call_id, __be32 s_addr)
--- a/include/uapi/linux/if_pppox.h	2013-08-10 10:36:11.477500663 -0700
+++ b/include/uapi/linux/if_pppox.h	2013-08-10 15:10:40.093460682 -0700
@@ -46,7 +46,7 @@ struct pppoe_addr {
  * PPTP addressing definition
  */
 struct pptp_addr {
-	__be16		call_id;
+	__u16		call_id;
 	struct in_addr	sin_addr;
 };
 
