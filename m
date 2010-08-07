From: Dmitry Popov <dp@highloadlab.com>
Subject: [PATCH] tcp: no md5sig option size check bug
Date: Sat, 7 Aug 2010 23:17:52 +0400
Message-ID: <AANLkTimHMAwi158ycRh_nRYPYUTSkww-psdFai-LsTsb@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Cc: "Pekka Savola (ipv6)" <pekkas@netcore.fi>,
	Gilad Ben-Yossef <gilad@codefidence.com>,
	Yony Amit <yony@comsleep.com>,
	Ori Finkelman <ori@comsleep.com>,
	=?ISO-8859-1?Q?Ilpo_J=E4rvinen?= <ilpo.jarvinen@helsinki.fi>,
	netdev@vger.kernel.org, linux-kernel@vger.kernel.org
To: "David S. Miller" <davem@davemloft.net>,
	Alexey Kuznetsov <kuznet@ms2.inr.ac.ru>,
	James Morris <jmorris@namei.org>,
	Patrick McHardy <kaber@trash.net>,
	Hideaki YOSHIFUJI <yoshfuji@lin
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Dmitry Popov <dp@highloadlab.com>

tcp_parse_md5sig_option doesn't check md5sig option (TCPOPT_MD5SIG)
length, but tcp_v[46]_inbound_md5_hash assume that it's at least 16
bytes long.

Signed-off-by: Dmitry Popov <dp@highloadlab.com>
---
 net/ipv4/tcp_input.c |    2 +-
 1 files changed, 1 insertions(+), 1 deletions(-)
diff --git a/net/ipv4/tcp_input.c b/net/ipv4/tcp_input.c
index 3c426cb..e663b78 100644
--- a/net/ipv4/tcp_input.c
+++ b/net/ipv4/tcp_input.c
@@ -3930,7 +3930,7 @@ u8 *tcp_parse_md5sig_option(struct tcphdr *th)
 			if (opsize < 2 || opsize > length)
 				return NULL;
 			if (opcode == TCPOPT_MD5SIG)
-				return ptr;
+				return opsize == TCPOLEN_MD5SIG ? ptr : NULL;
 		}
 		ptr += opsize - 2;
 		length -= opsize;
