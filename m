From: William Allen Simpson <william.allen.simpson@gmail.com>
Subject: Re: [PATCH 1/2] net: tcp_header_len_th and tcp_option_len_th
Date: Wed, 06 Jan 2010 16:28:05 -0500
Message-ID: <4B450065.4010108@gmail.com>
References: <4B44FE3C.6060809@gmail.com>
Mime-Version: 1.0
Content-Type: multipart/mixed;
 boundary="------------020303000900040805090502"
Cc: Linux Kernel Network Developers <netdev@vger.kernel.org>,
	Michael Chan <mchan@broadcom.com>
To: Linux Kernel Developers <linux-kernel@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-yw0-f176.google.com ([209.85.211.176]:52835 "EHLO
	mail-yw0-f176.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755100Ab0AFV2J (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 6 Jan 2010 16:28:09 -0500
In-Reply-To: <4B44FE3C.6060809@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This is a multi-part message in MIME format.
--------------020303000900040805090502
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


--------------020303000900040805090502
Content-Type: text/plain; x-mac-type="54455854"; x-mac-creator="0";
 name="len_th+1v3.patch"
Content-Transfer-Encoding: 7bit
Content-Disposition: inline;
 filename="len_th+1v3.patch"

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


--------------020303000900040805090502--
