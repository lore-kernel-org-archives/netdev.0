From: =?utf-8?q?R=C3=A9mi=20Denis-Courmont?=
	<remi.denis-courmont@nokia.com>
Subject: [PATCH 2/5] Phonet: allocate separate ARP type for GPRS over a Phonet pipe
Date: Wed, 17 Dec 2008 16:07:51 +0200
Message-ID: <1229522874-20636-2-git-send-email-remi.denis-courmont@nokia.com>
References: <200812171607.14184.remi.denis-courmont@nokia.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp.nokia.com ([192.100.122.233]:40534 "EHLO
	mgw-mx06.nokia.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751533AbYLQOI1 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 17 Dec 2008 09:08:27 -0500
Received: from esebh106.NOE.Nokia.com (esebh106.ntc.nokia.com [172.21.138.213])
	by mgw-mx06.nokia.com (Switch-3.2.6/Switch-3.2.6) with ESMTP id mBHE7tVq018822
	for <netdev@vger.kernel.org>; Wed, 17 Dec 2008 16:08:24 +0200
Received: from localhost.localdomain (esdhcp041160.research.nokia.com [172.21.41.160])
	by mgw-int02.ntc.nokia.com (Switch-3.2.5/Switch-3.2.5) with ESMTP id mBHE7sdc016910
	for <netdev@vger.kernel.org>; Wed, 17 Dec 2008 16:07:56 +0200
In-Reply-To: <200812171607.14184.remi.denis-courmont@nokia.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

A separate xmit lock class supports GPRS over a Phonet pipe over a TUN
device (type ARPHRD_NONE).

Signed-off-by: R=C3=A9mi Denis-Courmont <remi.denis-courmont@nokia.com>
---
 include/linux/if_arp.h |    1 +
 net/core/dev.c         |    4 ++--
 net/phonet/pep-gprs.c  |    2 +-
 3 files changed, 4 insertions(+), 3 deletions(-)

diff --git a/include/linux/if_arp.h b/include/linux/if_arp.h
index 11df77a..5ff8980 100644
--- a/include/linux/if_arp.h
+++ b/include/linux/if_arp.h
@@ -88,6 +88,7 @@
 #define ARPHRD_IEEE80211_RADIOTAP 803	/* IEEE 802.11 + radiotap header=
 */
=20
 #define ARPHRD_PHONET	820		/* PhoNet media type		*/
+#define ARPHRD_PHONET_PIPE 821		/* PhoNet pipe header		*/
=20
 #define ARPHRD_VOID	  0xFFFF	/* Void type, nothing is known */
 #define ARPHRD_NONE	  0xFFFE	/* zero header length */
diff --git a/net/core/dev.c b/net/core/dev.c
index 15aab0c..048cf11 100644
--- a/net/core/dev.c
+++ b/net/core/dev.c
@@ -284,7 +284,7 @@ static const unsigned short netdev_lock_type[] =3D
 	 ARPHRD_IRDA, ARPHRD_FCPP, ARPHRD_FCAL, ARPHRD_FCPL,
 	 ARPHRD_FCFABRIC, ARPHRD_IEEE802_TR, ARPHRD_IEEE80211,
 	 ARPHRD_IEEE80211_PRISM, ARPHRD_IEEE80211_RADIOTAP, ARPHRD_PHONET,
-	 ARPHRD_VOID, ARPHRD_NONE};
+	 ARPHRD_PHONET_PIPE, ARPHRD_VOID, ARPHRD_NONE};
=20
 static const char *netdev_lock_name[] =3D
 	{"_xmit_NETROM", "_xmit_ETHER", "_xmit_EETHER", "_xmit_AX25",
@@ -301,7 +301,7 @@ static const char *netdev_lock_name[] =3D
 	 "_xmit_IRDA", "_xmit_FCPP", "_xmit_FCAL", "_xmit_FCPL",
 	 "_xmit_FCFABRIC", "_xmit_IEEE802_TR", "_xmit_IEEE80211",
 	 "_xmit_IEEE80211_PRISM", "_xmit_IEEE80211_RADIOTAP", "_xmit_PHONET",
-	 "_xmit_VOID", "_xmit_NONE"};
+	 "_xmit_PHONET_PIPE", "_xmit_VOID", "_xmit_NONE"};
=20
 static struct lock_class_key netdev_xmit_lock_key[ARRAY_SIZE(netdev_lo=
ck_type)];
 static struct lock_class_key netdev_addr_lock_key[ARRAY_SIZE(netdev_lo=
ck_type)];
diff --git a/net/phonet/pep-gprs.c b/net/phonet/pep-gprs.c
index 0b640b0..a287320 100644
--- a/net/phonet/pep-gprs.c
+++ b/net/phonet/pep-gprs.c
@@ -260,7 +260,7 @@ static int gprs_set_mtu(struct net_device *dev, int=
 new_mtu)
 static void gprs_setup(struct net_device *dev)
 {
 	dev->features		=3D NETIF_F_FRAGLIST;
-	dev->type		=3D ARPHRD_NONE;
+	dev->type		=3D ARPHRD_PHONET_PIPE;
 	dev->flags		=3D IFF_POINTOPOINT | IFF_NOARP;
 	dev->mtu		=3D GPRS_DEFAULT_MTU;
 	dev->hard_header_len	=3D 0;
--=20
1.5.4.3

