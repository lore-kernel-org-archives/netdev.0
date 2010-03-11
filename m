From: William Allen Simpson <william.allen.simpson@gmail.com>
Subject: [PATCH v3 1/7] net: tcp_header_len_th and tcp_option_len_th
Date: Thu, 11 Mar 2010 06:41:17 -0500
Message-ID: <4B98D6DD.2010309@gmail.com>
References: <4B98D592.6040301@gmail.com>
Mime-Version: 1.0
Content-Type: multipart/mixed;
 boundary="------------030603020305080906020502"
Cc: Linux Kernel Developers <linux-kernel@vger.kernel.org>,
	Linux Kernel Network Developers <netdev@vger.kernel.org>,
	David Miller <davem@davemloft.net>
To: Linus Torvalds <torvalds@linux-foundation.org>,
	Andrew Morton <akpm@linux-foundation.org>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <4B98D592.6040301@gmail.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

This is a multi-part message in MIME format.
--------------030603020305080906020502
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

--------------030603020305080906020502
Content-Type: text/plain; x-mac-type="54455854"; x-mac-creator="0";
 name="len_th+2a3+2.6.34-rc1.patch"
Content-Transfer-Encoding: 7bit
Content-Disposition: attachment;
 filename="len_th+2a3+2.6.34-rc1.patch"

diff --git a/include/linux/tcp.h b/include/linux/tcp.h
index a778ee0..48ddeb8 100644
--- a/include/linux/tcp.h
+++ b/include/linux/tcp.h
@@ -225,6 +225,18 @@ static inline unsigned int tcp_optlen(const struct sk_buff *skb)
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


--------------030603020305080906020502--
