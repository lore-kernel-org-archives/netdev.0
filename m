From: William Allen Simpson <william.allen.simpson@gmail.com>
Subject: [PATCH 1/7] net: tcp_header_len_th and tcp_option_len_th
Date: Sat, 23 Jan 2010 00:32:25 -0500
Message-ID: <4B5A89E9.90209@gmail.com>
References: <4B5A88C4.7050205@gmail.com>
Mime-Version: 1.0
Content-Type: multipart/mixed;
 boundary="------------090000080502010508000600"
Cc: Andrew Morton <akpm@linux-foundation.org>
To: Linux Kernel Developers <linux-kernel@vger.kernel.org>,
	Linux Kernel Network Developers <netdev@vger.kernel.org>
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S1753236Ab0AWFcb@vger.kernel.org>
In-Reply-To: <4B5A88C4.7050205@gmail.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

This is a multi-part message in MIME format.
--------------090000080502010508000600
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

--------------090000080502010508000600
Content-Type: text/plain; x-mac-type="54455854"; x-mac-creator="0";
 name="len_th+2a3+2.6.33-rc5.patch"
Content-Transfer-Encoding: 7bit
Content-Disposition: inline;
 filename="len_th+2a3+2.6.33-rc5.patch"

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


--------------090000080502010508000600--
