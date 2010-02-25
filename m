From: William Allen Simpson <william.allen.simpson@gmail.com>
Subject: Re: [PATCH 0/7] tcp: bugs and cleanup for 2.6.33
Date: Thu, 25 Feb 2010 15:34:14 -0500
Message-ID: <4B86DEC6.1090307@gmail.com>
References: <4B86DDCB.50608@gmail.com>
Mime-Version: 1.0
Content-Type: multipart/mixed;
 boundary="------------040003010600050603030607"
Cc: Linux Kernel Developers <linux-kernel@vger.kernel.org>,
	Linux Kernel Network Developers <netdev@vger.kernel.org>,
	David Miller <davem@davemloft.net>
To: Linus Torvalds <torvalds@linux-foundation.org>,
	Andrew Morton <akpm@linux-foundation.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-gw0-f46.google.com ([74.125.83.46]:38214 "EHLO
	mail-gw0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932934Ab0BYUeS (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 25 Feb 2010 15:34:18 -0500
In-Reply-To: <4B86DDCB.50608@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This is a multi-part message in MIME format.
--------------040003010600050603030607
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

--------------040003010600050603030607
Content-Type: text/plain; x-mac-type="54455854"; x-mac-creator="0";
 name="len_th+2a3+2.6.33.patch"
Content-Transfer-Encoding: 7bit
Content-Disposition: inline;
 filename="len_th+2a3+2.6.33.patch"

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


--------------040003010600050603030607--
