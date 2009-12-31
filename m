From: William Allen Simpson <william.allen.simpson@gmail.com>
Subject: [PATCH v2 RFC 1/5] TCPCT part 2a: TCP header pointer functions
Date: Thu, 31 Dec 2009 14:38:34 -0500
Message-ID: <4B3CFDBA.9020405@gmail.com>
References: <4B3CFC73.3070204@gmail.com>
Mime-Version: 1.0
Content-Type: multipart/mixed;
 boundary="------------080200060208080907060408"
To: Linux Kernel Network Developers <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-yw0-f176.google.com ([209.85.211.176]:40729 "EHLO
	mail-yw0-f176.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750722AbZLaTii (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 31 Dec 2009 14:38:38 -0500
Received: by ywh6 with SMTP id 6so13103373ywh.4
        for <netdev@vger.kernel.org>; Thu, 31 Dec 2009 11:38:36 -0800 (PST)
In-Reply-To: <4B3CFC73.3070204@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This is a multi-part message in MIME format.
--------------080200060208080907060408
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit

Redefine two TCP header functions to accept TCP header pointer.
When subtracting, return signed int to allow error checking.

These functions will be used in subsequent patches that implement
additional features.

Signed-off-by: William.Allen.Simpson@gmail.com
---
  include/linux/tcp.h |   12 ++++++++++++
  1 files changed, 12 insertions(+), 0 deletions(-)

--------------080200060208080907060408
Content-Type: text/plain; x-mac-type="54455854"; x-mac-creator="522A6368";
 name="TCPCT+2a2.patch"
Content-Transfer-Encoding: 7bit
Content-Disposition: inline;
 filename="TCPCT+2a2.patch"

diff --git a/include/linux/tcp.h b/include/linux/tcp.h
index 7fee8a4..d0133cf 100644
--- a/include/linux/tcp.h
+++ b/include/linux/tcp.h
@@ -223,6 +223,18 @@ static inline unsigned int tcp_optlen(const struct sk_buff *skb)
 	return (tcp_hdr(skb)->doff - 5) * 4;
 }
 
+/* Length of fixed header plus standard options. */
+static inline unsigned int tcp_header_len_th(const struct tcphdr *th)
+{
+	return th->doff * 4;
+}
+
+/* Length of standard options only.  This could be negative. */
+static inline int tcp_option_len_th(const struct tcphdr *th)
+{
+	return (int)(th->doff * 4) - sizeof(*th);
+}
+
 /* This defines a selective acknowledgement block. */
 struct tcp_sack_block_wire {
 	__be32	start_seq;
-- 
1.6.3.3

--------------080200060208080907060408--
