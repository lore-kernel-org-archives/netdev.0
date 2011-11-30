From: =?UTF-8?q?Sjur=20Br=C3=A6ndeland?= <sjur.brandeland@stericsson.com>
Subject: [PATCH net-next 3/3] caif: Remove unused enum and parameter in cfserl
Date: Wed, 30 Nov 2011 20:22:48 +0100
Message-ID: <1322680968-6470-3-git-send-email-sjur.brandeland@stericsson.com>
References: <1322680968-6470-1-git-send-email-sjur.brandeland@stericsson.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: David Miller <davem@davemloft.net>,
	=?UTF-8?q?Sjur=20Br=C3=A6ndeland?= <sjur.brandeland@stericsson.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ey0-f174.google.com ([209.85.215.174]:64610 "EHLO
	mail-ey0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751838Ab1K3TXO (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 30 Nov 2011 14:23:14 -0500
Received: by eaak14 with SMTP id k14so1102413eaa.19
        for <netdev@vger.kernel.org>; Wed, 30 Nov 2011 11:23:13 -0800 (PST)
In-Reply-To: <1322680968-6470-1-git-send-email-sjur.brandeland@stericsson.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Remove unused enum cfcnfg_phy_type and the parameter to cfserl_create.

Signed-off-by: Sjur Br=C3=A6ndeland <sjur.brandeland@stericsson.com>
---
 include/net/caif/cfcnfg.h |   14 --------------
 include/net/caif/cfserl.h |    4 ++--
 net/caif/caif_dev.c       |    2 +-
 net/caif/cfserl.c         |    3 +--
 4 files changed, 4 insertions(+), 19 deletions(-)

diff --git a/include/net/caif/cfcnfg.h b/include/net/caif/cfcnfg.h
index a421723..90b4ff8 100644
--- a/include/net/caif/cfcnfg.h
+++ b/include/net/caif/cfcnfg.h
@@ -14,18 +14,6 @@
 struct cfcnfg;
=20
 /**
- * enum cfcnfg_phy_type -  Types of physical layers defined in CAIF St=
ack
- *
- * @CFPHYTYPE_FRAG:	Fragmented frames physical interface.
- * @CFPHYTYPE_CAIF:	Generic CAIF physical interface
- */
-enum cfcnfg_phy_type {
-	CFPHYTYPE_FRAG =3D 1,
-	CFPHYTYPE_CAIF,
-	CFPHYTYPE_MAX
-};
-
-/**
  * enum cfcnfg_phy_preference - Physical preference HW Abstraction
  *
  * @CFPHYPREF_UNSPECIFIED:	Default physical interface
@@ -66,8 +54,6 @@ void cfcnfg_remove(struct cfcnfg *cfg);
  * cfcnfg_add_phy_layer() - Adds a physical layer to the CAIF stack.
  * @cnfg:	Pointer to a CAIF configuration object, created by
  *		cfcnfg_create().
- * @phy_type:	Specifies the type of physical interface, e.g.
- *			CFPHYTYPE_FRAG.
  * @dev:	Pointer to link layer device
  * @phy_layer:	Specify the physical layer. The transmit function
  *		MUST be set in the structure.
diff --git a/include/net/caif/cfserl.h b/include/net/caif/cfserl.h
index b837432..f121299 100644
--- a/include/net/caif/cfserl.h
+++ b/include/net/caif/cfserl.h
@@ -8,5 +8,5 @@
 #define CFSERL_H_
 #include <net/caif/caif_layer.h>
=20
-struct cflayer *cfserl_create(int type, int instance, bool use_stx);
-#endif				/* CFSERL_H_ */
+struct cflayer *cfserl_create(int instance, bool use_stx);
+#endif
diff --git a/net/caif/caif_dev.c b/net/caif/caif_dev.c
index 70034c0..f7e8c70 100644
--- a/net/caif/caif_dev.c
+++ b/net/caif/caif_dev.c
@@ -295,7 +295,7 @@ static int caif_device_notify(struct notifier_block=
 *me, unsigned long what,
 		if (caifdev->use_frag) {
 			head_room =3D 1;
 			link_support =3D cfserl_create(dev->ifindex,
-					CFPHYTYPE_FRAG, caifdev->use_stx);
+							caifdev->use_stx);
 			if (!link_support) {
 				pr_warn("Out of memory\n");
 				break;
diff --git a/net/caif/cfserl.c b/net/caif/cfserl.c
index 797c8d1..8e68b97 100644
--- a/net/caif/cfserl.c
+++ b/net/caif/cfserl.c
@@ -31,7 +31,7 @@ static int cfserl_transmit(struct cflayer *layr, stru=
ct cfpkt *pkt);
 static void cfserl_ctrlcmd(struct cflayer *layr, enum caif_ctrlcmd ctr=
l,
 				int phyid);
=20
-struct cflayer *cfserl_create(int type, int instance, bool use_stx)
+struct cflayer *cfserl_create(int instance, bool use_stx)
 {
 	struct cfserl *this =3D kzalloc(sizeof(struct cfserl), GFP_ATOMIC);
 	if (!this)
@@ -40,7 +40,6 @@ struct cflayer *cfserl_create(int type, int instance,=
 bool use_stx)
 	this->layer.receive =3D cfserl_receive;
 	this->layer.transmit =3D cfserl_transmit;
 	this->layer.ctrlcmd =3D cfserl_ctrlcmd;
-	this->layer.type =3D type;
 	this->usestx =3D use_stx;
 	spin_lock_init(&this->sync);
 	snprintf(this->layer.name, CAIF_LAYER_NAME_SZ, "ser1");
--=20
1.7.0.4
