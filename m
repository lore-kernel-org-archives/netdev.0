From: =?UTF-8?q?R=C3=A9mi=20Denis-Courmont?=
	<remi.denis-courmont@nokia.com>
Subject: [PATCH 8/8] Phonet: kill the ST-Ericsson pipe controller Kconfig
Date: Tue,  8 Mar 2011 15:57:06 +0200
Message-ID: <1299592626-18510-8-git-send-email-remi.denis-courmont@nokia.com>
References: <201103081556.18877.remi.denis-courmont@nokia.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp.nokia.com ([147.243.1.48]:37554 "EHLO mgw-sa02.nokia.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755015Ab1CHN5M (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 8 Mar 2011 08:57:12 -0500
Received: from leon.remlab.com (esdhcp034153.research.nokia.com [172.21.34.153])
	by mgw-sa02.nokia.com (Switch-3.4.3/Switch-3.4.3) with ESMTP id p28Dv8Cj006174
	for <netdev@vger.kernel.org>; Tue, 8 Mar 2011 15:57:10 +0200
In-Reply-To: <201103081556.18877.remi.denis-courmont@nokia.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This is now a run-time choice so that a single kernel can support both
old and new generation ISI modems.

Signed-off-by: R=C3=A9mi Denis-Courmont <remi.denis-courmont@nokia.com>
---
 Documentation/networking/phonet.txt |   13 -------------
 include/linux/phonet.h              |    2 --
 net/phonet/Kconfig                  |   12 ------------
 net/phonet/pep.c                    |   25 -------------------------
 4 files changed, 0 insertions(+), 52 deletions(-)

diff --git a/Documentation/networking/phonet.txt b/Documentation/networ=
king/phonet.txt
index 3d12779..8100358 100644
--- a/Documentation/networking/phonet.txt
+++ b/Documentation/networking/phonet.txt
@@ -205,19 +205,6 @@ The pipe protocol provides two socket options at t=
he SOL_PNPIPE level:
     socket descriptors that are already connected or being connected.
=20
=20
-Phonet Pipe-controller Implementation
--------------------------------------
-
-Phonet Pipe-controller is enabled by selecting the CONFIG_PHONET_PIPEC=
TRLR
-Kconfig option.
-
-The implementation adds socket options at SOL_PNPIPE level:
-
-  PNPIPE_ENABLE accepts one integer value (int). If set to zero, the p=
ipe
-    is disabled. If the value is non-zero, the pipe is enabled. If the=
 pipe
-    is not (yet) connected, ENOTCONN is error is returned.
-
-
 Authors
 -------
=20
diff --git a/include/linux/phonet.h b/include/linux/phonet.h
index 32a0965..6fb1384 100644
--- a/include/linux/phonet.h
+++ b/include/linux/phonet.h
@@ -37,8 +37,6 @@
 #define PNPIPE_ENCAP		1
 #define PNPIPE_IFINDEX		2
 #define PNPIPE_HANDLE		3
-#define PNPIPE_ENABLE           4
-/* unused slot */
=20
 #define PNADDR_ANY		0
 #define PNADDR_BROADCAST	0xFC
diff --git a/net/phonet/Kconfig b/net/phonet/Kconfig
index 0d9b8a2..6ec7d55 100644
--- a/net/phonet/Kconfig
+++ b/net/phonet/Kconfig
@@ -14,15 +14,3 @@ config PHONET
=20
 	  To compile this driver as a module, choose M here: the module
 	  will be called phonet. If unsure, say N.
-
-config PHONET_PIPECTRLR
-	bool "Phonet Pipe Controller (EXPERIMENTAL)"
-	depends on PHONET && EXPERIMENTAL
-	default N
-	help
-	  The Pipe Controller implementation in Phonet stack to support Pipe
-	  data with Nokia Slim modems like WG2.5 used on ST-Ericsson U8500
-	  platform.
-
-	  This option is incompatible with older Nokia modems.
-	  Say N here unless you really know what you are doing.
diff --git a/net/phonet/pep.c b/net/phonet/pep.c
index 671effb..68e635f 100644
--- a/net/phonet/pep.c
+++ b/net/phonet/pep.c
@@ -167,15 +167,6 @@ static int pipe_handler_send_created_ind(struct so=
ck *sk)
 				data, 4, GFP_ATOMIC);
 }
=20
-#ifdef CONFIG_PHONET_PIPECTRLR
-static int pipe_handler_enable_pipe(struct sock *sk, int enable)
-{
-	u8 id =3D enable ? PNS_PEP_ENABLE_REQ : PNS_PEP_DISABLE_REQ;
-
-	return pipe_handler_request(sk, id, PAD, NULL, 0);
-}
-#endif
-
 static int pep_accept_conn(struct sock *sk, struct sk_buff *skb)
 {
 	static const u8 data[20] =3D {
@@ -968,16 +959,6 @@ static int pep_setsockopt(struct sock *sk, int lev=
el, int optname,
 		}
 		goto out_norel;
=20
-#ifdef CONFIG_PHONET_PIPECTRLR
-	case PNPIPE_ENABLE:
-		if ((1 << sk->sk_state) & ~(TCPF_SYN_RECV|TCPF_ESTABLISHED)) {
-			err =3D -ENOTCONN;
-			break;
-		}
-		err =3D pipe_handler_enable_pipe(sk, val);
-		break;
-#endif
-
 	default:
 		err =3D -ENOPROTOOPT;
 	}
@@ -1013,12 +994,6 @@ static int pep_getsockopt(struct sock *sk, int le=
vel, int optname,
 			return -EINVAL;
 		break;
=20
-#ifdef CONFIG_PHONET_PIPECTRLR
-	case PNPIPE_ENABLE:
-		val =3D sk->sk_state =3D=3D TCP_ESTABLISHED;
-		break;
-#endif
-
 	default:
 		return -ENOPROTOOPT;
 	}
--=20
1.7.1

