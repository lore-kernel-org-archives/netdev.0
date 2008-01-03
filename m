From: "=?ISO-8859-1?Q?Ilpo_J=E4rvinen?=" <ilpo.jarvinen@helsinki.fi>
Subject: [PATCH net-2.6.25 1/3] [TCP]: cleanup tcp_parse_options deep indented switch
Date: Thu,  3 Jan 2008 13:00:05 +0200
Message-ID: <11993580071900-git-send-email-ilpo.jarvinen@helsinki.fi>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=ISO-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from courier.cs.helsinki.fi ([128.214.9.1]:59872 "EHLO
	mail.cs.helsinki.fi" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751579AbYACLAK (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 3 Jan 2008 06:00:10 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Removed case indentation level & combined some nested ifs, mostly
within 80 lines now. This is a leftover from indent patch, it
just had to be done manually to avoid messing it up completely.

Signed-off-by: Ilpo J=E4rvinen <ilpo.jarvinen@helsinki.fi>
---
 net/ipv4/tcp_input.c |  135 +++++++++++++++++++++++++-----------------=
--------
 1 files changed, 67 insertions(+), 68 deletions(-)

diff --git a/net/ipv4/tcp_input.c b/net/ipv4/tcp_input.c
index 18e099c..d5b6adf 100644
--- a/net/ipv4/tcp_input.c
+++ b/net/ipv4/tcp_input.c
@@ -3278,81 +3278,80 @@ void tcp_parse_options(struct sk_buff *skb, str=
uct tcp_options_received *opt_rx,
 		int opsize;
=20
 		switch (opcode) {
-			case TCPOPT_EOL:
+		case TCPOPT_EOL:
+			return;
+		case TCPOPT_NOP:	/* Ref: RFC 793 section 3.1 */
+			length--;
+			continue;
+		default:
+			opsize =3D *ptr++;
+			if (opsize < 2) /* "silly options" */
 				return;
-			case TCPOPT_NOP:	/* Ref: RFC 793 section 3.1 */
-				length--;
-				continue;
-			default:
-				opsize=3D*ptr++;
-				if (opsize < 2) /* "silly options" */
-					return;
-				if (opsize > length)
-					return;	/* don't parse partial options */
-				switch (opcode) {
-				case TCPOPT_MSS:
-					if (opsize=3D=3DTCPOLEN_MSS && th->syn && !estab) {
-						u16 in_mss =3D ntohs(get_unaligned((__be16 *)ptr));
-						if (in_mss) {
-							if (opt_rx->user_mss && opt_rx->user_mss < in_mss)
-								in_mss =3D opt_rx->user_mss;
-							opt_rx->mss_clamp =3D in_mss;
-						}
-					}
-					break;
-				case TCPOPT_WINDOW:
-					if (opsize=3D=3DTCPOLEN_WINDOW && th->syn && !estab)
-						if (sysctl_tcp_window_scaling) {
-							__u8 snd_wscale =3D *(__u8 *) ptr;
-							opt_rx->wscale_ok =3D 1;
-							if (snd_wscale > 14) {
-								if (net_ratelimit())
-									printk(KERN_INFO "tcp_parse_options: Illegal window "
-									       "scaling value %d >14 received.\n",
-									       snd_wscale);
-								snd_wscale =3D 14;
-							}
-							opt_rx->snd_wscale =3D snd_wscale;
-						}
-					break;
-				case TCPOPT_TIMESTAMP:
-					if (opsize=3D=3DTCPOLEN_TIMESTAMP) {
-						if ((estab && opt_rx->tstamp_ok) ||
-						    (!estab && sysctl_tcp_timestamps)) {
-							opt_rx->saw_tstamp =3D 1;
-							opt_rx->rcv_tsval =3D ntohl(get_unaligned((__be32 *)ptr));
-							opt_rx->rcv_tsecr =3D ntohl(get_unaligned((__be32 *)(ptr+4)));
-						}
+			if (opsize > length)
+				return;	/* don't parse partial options */
+			switch (opcode) {
+			case TCPOPT_MSS:
+				if (opsize =3D=3D TCPOLEN_MSS && th->syn && !estab) {
+					u16 in_mss =3D ntohs(get_unaligned((__be16 *)ptr));
+					if (in_mss) {
+						if (opt_rx->user_mss &&
+						    opt_rx->user_mss < in_mss)
+							in_mss =3D opt_rx->user_mss;
+						opt_rx->mss_clamp =3D in_mss;
 					}
-					break;
-				case TCPOPT_SACK_PERM:
-					if (opsize=3D=3DTCPOLEN_SACK_PERM && th->syn && !estab) {
-						if (sysctl_tcp_sack) {
-							opt_rx->sack_ok =3D 1;
-							tcp_sack_reset(opt_rx);
-						}
+				}
+				break;
+			case TCPOPT_WINDOW:
+				if (opsize =3D=3D TCPOLEN_WINDOW && th->syn &&
+				    !estab && sysctl_tcp_window_scaling) {
+					__u8 snd_wscale =3D *(__u8 *)ptr;
+					opt_rx->wscale_ok =3D 1;
+					if (snd_wscale > 14) {
+						if (net_ratelimit())
+							printk(KERN_INFO "tcp_parse_options: Illegal window "
+							       "scaling value %d >14 received.\n",
+							       snd_wscale);
+						snd_wscale =3D 14;
 					}
-					break;
+					opt_rx->snd_wscale =3D snd_wscale;
+				}
+				break;
+			case TCPOPT_TIMESTAMP:
+				if ((opsize =3D=3D TCPOLEN_TIMESTAMP) &&
+				    ((estab && opt_rx->tstamp_ok) ||
+				     (!estab && sysctl_tcp_timestamps))) {
+					opt_rx->saw_tstamp =3D 1;
+					opt_rx->rcv_tsval =3D ntohl(get_unaligned((__be32 *)ptr));
+					opt_rx->rcv_tsecr =3D ntohl(get_unaligned((__be32 *)(ptr+4)));
+				}
+				break;
+			case TCPOPT_SACK_PERM:
+				if (opsize =3D=3D TCPOLEN_SACK_PERM && th->syn &&
+				    !estab && sysctl_tcp_sack) {
+ 					opt_rx->sack_ok =3D 1;
+					tcp_sack_reset(opt_rx);
+				}
+				break;
=20
-				case TCPOPT_SACK:
-					if ((opsize >=3D (TCPOLEN_SACK_BASE + TCPOLEN_SACK_PERBLOCK)) &&
-					   !((opsize - TCPOLEN_SACK_BASE) % TCPOLEN_SACK_PERBLOCK) &&
-					   opt_rx->sack_ok) {
-						TCP_SKB_CB(skb)->sacked =3D (ptr - 2) - (unsigned char *)th;
-					}
-					break;
+			case TCPOPT_SACK:
+				if ((opsize >=3D (TCPOLEN_SACK_BASE + TCPOLEN_SACK_PERBLOCK)) &&
+				   !((opsize - TCPOLEN_SACK_BASE) % TCPOLEN_SACK_PERBLOCK) &&
+				   opt_rx->sack_ok) {
+					TCP_SKB_CB(skb)->sacked =3D (ptr - 2) - (unsigned char *)th;
+				}
+				break;
 #ifdef CONFIG_TCP_MD5SIG
-				case TCPOPT_MD5SIG:
-					/*
-					 * The MD5 Hash has already been
-					 * checked (see tcp_v{4,6}_do_rcv()).
-					 */
-					break;
+			case TCPOPT_MD5SIG:
+				/*
+				 * The MD5 Hash has already been
+				 * checked (see tcp_v{4,6}_do_rcv()).
+				 */
+				break;
 #endif
-				}
+			}
=20
-				ptr+=3Dopsize-2;
-				length-=3Dopsize;
+			ptr +=3D opsize-2;
+			length -=3D opsize;
 		}
 	}
 }
--=20
1.5.0.6

