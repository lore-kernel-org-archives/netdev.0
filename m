From: greearb@candelatech.com
Subject: [PATCH v2 4/5] net:  Support sending frame with specified FCS.
Date: Sat, 18 Jun 2011 13:47:24 -0700
Message-ID: <1308430045-24816-5-git-send-email-greearb@candelatech.com>
References: <1308430045-24816-1-git-send-email-greearb@candelatech.com>
Cc: Ben Greear <greearb@candelatech.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.candelatech.com ([208.74.158.172]:53644 "EHLO
	ns3.lanforge.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752197Ab1FRUsk (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 18 Jun 2011 16:48:40 -0400
In-Reply-To: <1308430045-24816-1-git-send-email-greearb@candelatech.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Ben Greear <greearb@candelatech.com>

This allows user-space to send a packet with the
ethernet FCS appended to the end.  Supporting NICs
will know to disable their own FCS calculations and
send frame as is.

This is useful for injecting bad frames on a network
for testing.

Signed-off-by: Ben Greear <greearb@candelatech.com>
---
:100644 100644 06edfef... 655fbe7... M	arch/alpha/include/asm/socket.h
:100644 100644 90ffd04... 4aa1c92... M	arch/arm/include/asm/socket.h
:100644 100644 c8d1fae... b70cfa3... M	arch/avr32/include/asm/socket.h
:100644 100644 1a4a619... 54d2d2b... M	arch/cris/include/asm/socket.h
:100644 100644 a6b2688... c77015c... M	arch/frv/include/asm/socket.h
:100644 100644 04c0f45... 5c8a75d... M	arch/h8300/include/asm/socket.h
:100644 100644 51427ea... f0062e6... M	arch/ia64/include/asm/socket.h
:100644 100644 469787c3.. a259a66... M	arch/m32r/include/asm/socket.h
:100644 100644 9bf49c8... 2442b97... M	arch/m68k/include/asm/socket.h
:100644 100644 9de5190... 9b1fe294.. M	arch/mips/include/asm/socket.h
:100644 100644 4e60c42... 1eb5bf5... M	arch/mn10300/include/asm/socket.h
:100644 100644 225b7d6... 22538f0... M	arch/parisc/include/asm/socket.h
:100644 100644 866f760... d1ecf79... M	arch/powerpc/include/asm/socket.h
:100644 100644 fdff1e9... c4ab6ea... M	arch/s390/include/asm/socket.h
:100644 100644 9d3fefc... af8b622... M	arch/sparc/include/asm/socket.h
:100644 100644 cbdf2ff... 4c0cf9c... M	arch/xtensa/include/asm/socket.h
:100644 100644 9a6115e... 22193a2... M	include/asm-generic/socket.h
:100644 100644 c0a4f3a... 05b15be... M	include/linux/skbuff.h
:100644 100644 f2046e4... d7e0d88... M	include/net/sock.h
:100644 100644 46cbd28... a552560... M	net/core/skbuff.c
:100644 100644 6e81978... 0c5f827... M	net/core/sock.c
:100644 100644 c0c3cda... 7b39092... M	net/packet/af_packet.c
 arch/alpha/include/asm/socket.h   |    1 +
 arch/arm/include/asm/socket.h     |    1 +
 arch/avr32/include/asm/socket.h   |    1 +
 arch/cris/include/asm/socket.h    |    1 +
 arch/frv/include/asm/socket.h     |    1 +
 arch/h8300/include/asm/socket.h   |    1 +
 arch/ia64/include/asm/socket.h    |    1 +
 arch/m32r/include/asm/socket.h    |    1 +
 arch/m68k/include/asm/socket.h    |    1 +
 arch/mips/include/asm/socket.h    |    1 +
 arch/mn10300/include/asm/socket.h |    1 +
 arch/parisc/include/asm/socket.h  |    1 +
 arch/powerpc/include/asm/socket.h |    1 +
 arch/s390/include/asm/socket.h    |    1 +
 arch/sparc/include/asm/socket.h   |    1 +
 arch/xtensa/include/asm/socket.h  |    1 +
 include/asm-generic/socket.h      |    7 +++++++
 include/linux/skbuff.h            |    5 ++++-
 include/net/sock.h                |    6 ++++++
 net/core/skbuff.c                 |    1 +
 net/core/sock.c                   |    7 +++++++
 net/packet/af_packet.c            |   18 ++++++++++++++++--
 22 files changed, 57 insertions(+), 3 deletions(-)

diff --git a/arch/alpha/include/asm/socket.h b/arch/alpha/include/asm/socket.h
index 06edfef..655fbe7 100644
--- a/arch/alpha/include/asm/socket.h
+++ b/arch/alpha/include/asm/socket.h
@@ -68,6 +68,7 @@
 #define SCM_TIMESTAMPING	SO_TIMESTAMPING
 
 #define SO_RXQ_OVFL             40
+#define SO_NOFCS		41
 
 /* O_NONBLOCK clashes with the bits used for socket types.  Therefore we
  * have to define SOCK_NONBLOCK to a different value here.
diff --git a/arch/arm/include/asm/socket.h b/arch/arm/include/asm/socket.h
index 90ffd04..4aa1c92 100644
--- a/arch/arm/include/asm/socket.h
+++ b/arch/arm/include/asm/socket.h
@@ -61,5 +61,6 @@
 #define SO_DOMAIN		39
 
 #define SO_RXQ_OVFL             40
+#define SO_NOFCS		41
 
 #endif /* _ASM_SOCKET_H */
diff --git a/arch/avr32/include/asm/socket.h b/arch/avr32/include/asm/socket.h
index c8d1fae..b70cfa3 100644
--- a/arch/avr32/include/asm/socket.h
+++ b/arch/avr32/include/asm/socket.h
@@ -61,5 +61,6 @@
 #define SO_DOMAIN		39
 
 #define SO_RXQ_OVFL             40
+#define SO_NOFCS		41
 
 #endif /* __ASM_AVR32_SOCKET_H */
diff --git a/arch/cris/include/asm/socket.h b/arch/cris/include/asm/socket.h
index 1a4a619..54d2d2b 100644
--- a/arch/cris/include/asm/socket.h
+++ b/arch/cris/include/asm/socket.h
@@ -63,6 +63,7 @@
 #define SO_DOMAIN		39
 
 #define SO_RXQ_OVFL             40
+#define SO_NOFCS		41
 
 #endif /* _ASM_SOCKET_H */
 
diff --git a/arch/frv/include/asm/socket.h b/arch/frv/include/asm/socket.h
index a6b2688..c77015c 100644
--- a/arch/frv/include/asm/socket.h
+++ b/arch/frv/include/asm/socket.h
@@ -61,6 +61,7 @@
 #define SO_DOMAIN		39
 
 #define SO_RXQ_OVFL             40
+#define SO_NOFCS		41
 
 #endif /* _ASM_SOCKET_H */
 
diff --git a/arch/h8300/include/asm/socket.h b/arch/h8300/include/asm/socket.h
index 04c0f45..5c8a75d 100644
--- a/arch/h8300/include/asm/socket.h
+++ b/arch/h8300/include/asm/socket.h
@@ -61,5 +61,6 @@
 #define SO_DOMAIN		39
 
 #define SO_RXQ_OVFL             40
+#define SO_NOFCS		41
 
 #endif /* _ASM_SOCKET_H */
diff --git a/arch/ia64/include/asm/socket.h b/arch/ia64/include/asm/socket.h
index 51427ea..f0062e6 100644
--- a/arch/ia64/include/asm/socket.h
+++ b/arch/ia64/include/asm/socket.h
@@ -70,5 +70,6 @@
 #define SO_DOMAIN		39
 
 #define SO_RXQ_OVFL             40
+#define SO_NOFCS		41
 
 #endif /* _ASM_IA64_SOCKET_H */
diff --git a/arch/m32r/include/asm/socket.h b/arch/m32r/include/asm/socket.h
index 469787c3..a259a66 100644
--- a/arch/m32r/include/asm/socket.h
+++ b/arch/m32r/include/asm/socket.h
@@ -61,5 +61,6 @@
 #define SO_DOMAIN		39
 
 #define SO_RXQ_OVFL             40
+#define SO_NOFCS		41
 
 #endif /* _ASM_M32R_SOCKET_H */
diff --git a/arch/m68k/include/asm/socket.h b/arch/m68k/include/asm/socket.h
index 9bf49c8..2442b97 100644
--- a/arch/m68k/include/asm/socket.h
+++ b/arch/m68k/include/asm/socket.h
@@ -61,5 +61,6 @@
 #define SO_DOMAIN		39
 
 #define SO_RXQ_OVFL             40
+#define SO_NOFCS		41
 
 #endif /* _ASM_SOCKET_H */
diff --git a/arch/mips/include/asm/socket.h b/arch/mips/include/asm/socket.h
index 9de5190..9b1fe294 100644
--- a/arch/mips/include/asm/socket.h
+++ b/arch/mips/include/asm/socket.h
@@ -81,6 +81,7 @@ To add: #define SO_REUSEPORT 0x0200	/* Allow local address and port reuse.  */
 #define SCM_TIMESTAMPING	SO_TIMESTAMPING
 
 #define SO_RXQ_OVFL             40
+#define SO_NOFCS		41
 
 #ifdef __KERNEL__
 
diff --git a/arch/mn10300/include/asm/socket.h b/arch/mn10300/include/asm/socket.h
index 4e60c42..1eb5bf5 100644
--- a/arch/mn10300/include/asm/socket.h
+++ b/arch/mn10300/include/asm/socket.h
@@ -61,5 +61,6 @@
 #define SO_DOMAIN		39
 
 #define SO_RXQ_OVFL             40
+#define SO_NOFCS		41
 
 #endif /* _ASM_SOCKET_H */
diff --git a/arch/parisc/include/asm/socket.h b/arch/parisc/include/asm/socket.h
index 225b7d6..22538f0 100644
--- a/arch/parisc/include/asm/socket.h
+++ b/arch/parisc/include/asm/socket.h
@@ -60,6 +60,7 @@
 #define SCM_TIMESTAMPING	SO_TIMESTAMPING
 
 #define SO_RXQ_OVFL             0x4021
+#define SO_NOFCS		0x4022
 
 /* O_NONBLOCK clashes with the bits used for socket types.  Therefore we
  * have to define SOCK_NONBLOCK to a different value here.
diff --git a/arch/powerpc/include/asm/socket.h b/arch/powerpc/include/asm/socket.h
index 866f760..d1ecf79 100644
--- a/arch/powerpc/include/asm/socket.h
+++ b/arch/powerpc/include/asm/socket.h
@@ -68,5 +68,6 @@
 #define SO_DOMAIN		39
 
 #define SO_RXQ_OVFL             40
+#define SO_NOFCS		41
 
 #endif	/* _ASM_POWERPC_SOCKET_H */
diff --git a/arch/s390/include/asm/socket.h b/arch/s390/include/asm/socket.h
index fdff1e9..c4ab6ea 100644
--- a/arch/s390/include/asm/socket.h
+++ b/arch/s390/include/asm/socket.h
@@ -69,5 +69,6 @@
 #define SO_DOMAIN		39
 
 #define SO_RXQ_OVFL             40
+#define SO_NOFCS		41
 
 #endif /* _ASM_SOCKET_H */
diff --git a/arch/sparc/include/asm/socket.h b/arch/sparc/include/asm/socket.h
index 9d3fefc..af8b622 100644
--- a/arch/sparc/include/asm/socket.h
+++ b/arch/sparc/include/asm/socket.h
@@ -57,6 +57,7 @@
 #define SCM_TIMESTAMPING	SO_TIMESTAMPING
 
 #define SO_RXQ_OVFL             0x0024
+#define SO_NOFCS		0x0025
 
 /* Security levels - as per NRL IPv6 - don't actually do anything */
 #define SO_SECURITY_AUTHENTICATION		0x5001
diff --git a/arch/xtensa/include/asm/socket.h b/arch/xtensa/include/asm/socket.h
index cbdf2ff..4c0cf9c 100644
--- a/arch/xtensa/include/asm/socket.h
+++ b/arch/xtensa/include/asm/socket.h
@@ -72,5 +72,6 @@
 #define SO_DOMAIN		39
 
 #define SO_RXQ_OVFL             40
+#define SO_NOFCS		41
 
 #endif	/* _XTENSA_SOCKET_H */
diff --git a/include/asm-generic/socket.h b/include/asm-generic/socket.h
index 9a6115e..22193a2 100644
--- a/include/asm-generic/socket.h
+++ b/include/asm-generic/socket.h
@@ -64,4 +64,11 @@
 #define SO_DOMAIN		39
 
 #define SO_RXQ_OVFL             40
+
+/* Instruct lower device to not calculate the frame
+ * checksum.  Useful for generating Ethernet frames
+ * with custom checksums.
+ */
+#define SO_NOFCS		41
+
 #endif /* __ASM_GENERIC_SOCKET_H */
diff --git a/include/linux/skbuff.h b/include/linux/skbuff.h
index c0a4f3a..05b15be 100644
--- a/include/linux/skbuff.h
+++ b/include/linux/skbuff.h
@@ -307,6 +307,8 @@ typedef unsigned char *sk_buff_data_t;
  *	@peeked: this packet has been seen already, so stats have been
  *		done for it, don't do them again
  *	@nf_trace: netfilter packet trace flag
+ *	@use_specified_ether_crc: skb is Ethernet frame with FCS already
+ *		appended.  Use that FCS.  Requires special support in NIC.
  *	@nfctinfo: Relationship of this skb to the connection
  *	@nfct_reasm: netfilter conntrack re-assembly pointer
  *	@nf_bridge: Saved data about a bridged frame - see br_netfilter.c
@@ -396,7 +398,8 @@ struct sk_buff {
 #ifdef CONFIG_IPV6_NDISC_NODETYPE
 	__u8			ndisc_nodetype:2;
 #endif
-	__u8			ooo_okay:1;
+	__u8			ooo_okay:1,
+				use_specified_ether_crc:1;
 	kmemcheck_bitfield_end(flags2);
 
 	/* 0/13 bit hole */
diff --git a/include/net/sock.h b/include/net/sock.h
index f2046e4..d7e0d88 100644
--- a/include/net/sock.h
+++ b/include/net/sock.h
@@ -563,6 +563,12 @@ enum sock_flags {
 	SOCK_TIMESTAMPING_SYS_HARDWARE, /* %SOF_TIMESTAMPING_SYS_HARDWARE */
 	SOCK_FASYNC, /* fasync() active */
 	SOCK_RXQ_OVFL,
+	SOCK_DONT_DO_LL_FCS, /* Tell NIC not to do the Ethernet FCS.
+			      * Will use last 4 bytes of packet sent from
+			      * user-space instead.  Requires special
+			      * support in NIC.
+			      */
+
 };
 
 static inline void sock_copy_flags(struct sock *nsk, struct sock *osk)
diff --git a/net/core/skbuff.c b/net/core/skbuff.c
index 46cbd28..a552560 100644
--- a/net/core/skbuff.c
+++ b/net/core/skbuff.c
@@ -541,6 +541,7 @@ static void __copy_skb_header(struct sk_buff *new, const struct sk_buff *old)
 	new->tc_verd		= old->tc_verd;
 #endif
 #endif
+	new->use_specified_ether_crc = old->use_specified_ether_crc;
 	new->vlan_tci		= old->vlan_tci;
 
 	skb_copy_secmark(new, old);
diff --git a/net/core/sock.c b/net/core/sock.c
index 6e81978..0c5f827 100644
--- a/net/core/sock.c
+++ b/net/core/sock.c
@@ -641,6 +641,13 @@ set_rcvbuf:
 		sock_warn_obsolete_bsdism("setsockopt");
 		break;
 
+	case SO_NOFCS:
+		if (valbool)
+			sk->sk_flags |= SOCK_DONT_DO_LL_FCS;
+		else
+			sk->sk_flags &= ~(SOCK_DONT_DO_LL_FCS);
+		break;
+
 	case SO_PASSCRED:
 		if (valbool)
 			set_bit(SOCK_PASSCRED, &sock->flags);
diff --git a/net/packet/af_packet.c b/net/packet/af_packet.c
index c0c3cda..7b39092 100644
--- a/net/packet/af_packet.c
+++ b/net/packet/af_packet.c
@@ -430,6 +430,10 @@ static int packet_sendmsg_spkt(struct kiocb *iocb, struct socket *sock,
 	struct net_device *dev;
 	__be16 proto = 0;
 	int err;
+	int fcs_len = 0;
+
+	if (unlikely(sk->sk_flags & SOCK_DONT_DO_LL_FCS))
+		fcs_len = 4; /* We're doing our own FCS */
 
 	/*
 	 *	Get and verify the address.
@@ -465,7 +469,7 @@ retry:
 	 */
 
 	err = -EMSGSIZE;
-	if (len > dev->mtu + dev->hard_header_len + VLAN_HLEN)
+	if (len > dev->mtu + dev->hard_header_len + VLAN_HLEN + fcs_len)
 		goto out_unlock;
 
 	if (!skb) {
@@ -518,6 +522,9 @@ retry:
 	if (err < 0)
 		goto out_unlock;
 
+	if (unlikely(sk->sk_flags & SOCK_DONT_DO_LL_FCS))
+		skb->use_specified_ether_crc = 1;
+
 	dev_queue_xmit(skb);
 	rcu_read_unlock();
 	return len;
@@ -1134,6 +1141,10 @@ static int packet_snd(struct socket *sock,
 	int vnet_hdr_len;
 	struct packet_sock *po = pkt_sk(sk);
 	unsigned short gso_type = 0;
+	int fcs_len = 0;
+
+	if (unlikely(sk->sk_flags & SOCK_DONT_DO_LL_FCS))
+		fcs_len = 4; /* We're doing our own Ethernet FCS */
 
 	/*
 	 *	Get and verify the address.
@@ -1215,7 +1226,7 @@ static int packet_snd(struct socket *sock,
 	}
 
 	err = -EMSGSIZE;
-	if (!gso_type && (len > dev->mtu + reserve + VLAN_HLEN))
+	if (!gso_type && (len > dev->mtu + reserve + VLAN_HLEN + fcs_len))
 		goto out_unlock;
 
 	err = -ENOBUFS;
@@ -1278,6 +1289,9 @@ static int packet_snd(struct socket *sock,
 		len += vnet_hdr_len;
 	}
 
+	if (unlikely(sk->sk_flags & SOCK_DONT_DO_LL_FCS))
+		skb->use_specified_ether_crc = 1;
+
 	/*
 	 *	Now send it
 	 */
-- 
1.7.3.4

