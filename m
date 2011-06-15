From: =?UTF-8?q?Sjur=20Br=C3=A6ndeland?= <sjur.brandeland@stericsson.com>
Subject: [PATCH net-2.6] caif: Bugfix - XOFF removed channel from caif-mux
Date: Thu, 16 Jun 2011 00:38:25 +0200
Message-ID: <1308177505-1843-1-git-send-email-sjur.brandeland@stericsson.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: =?UTF-8?q?Sjur=20Br=C3=A6ndeland?= <sjur.brandeland@stericsson.com>
To: "David S. Miller" <davem@davemloft.net>, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from thalia-smout.broadpark.no ([80.202.8.21]:54941 "EHLO
	thalia-smout.broadpark.no" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753281Ab1FOXic (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 15 Jun 2011 19:38:32 -0400
Received: from terra-smin.broadpark.no ([80.202.8.13])
 by thalia-smout.broadpark.no
 (Sun Java(tm) System Messaging Server 7u3-15.01 64bit (built Feb 12 2010))
 with ESMTP id <0LMU00ALPS858L30@thalia-smout.broadpark.no> for
 netdev@vger.kernel.org; Thu, 16 Jun 2011 00:38:29 +0200 (CEST)
Received: from localhost.localdomain ([80.203.143.18])
 by terra-smin.broadpark.no
 (Sun Java(tm) System Messaging Server 7u3-15.01 64bit (built Feb 12 2010))
 with ESMTP id <0LMU001WLS84DG90@terra-smin.broadpark.no> for
 netdev@vger.kernel.org; Thu, 16 Jun 2011 00:38:29 +0200 (CEST)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

XOFF was mixed up with DOWN indication, causing causing CAIF channel to=
 be
removed from mux and all incoming traffic to be lost after receiving fl=
ow-off.
=46ix this by replacing FLOW_OFF with DOWN notification.

Signed-off-by: Sjur Br=C3=A6ndeland <sjur.brandeland@stericsson.com>
---
Hi Dave,
Please consider this bugfix for Linux 3.0.
It's a one-liner fixing a silly copy-paste mistake.

Thanks,
Sjur=20

 net/caif/cfmuxl.c |    2 +-
 1 files changed, 1 insertions(+), 1 deletions(-)

diff --git a/net/caif/cfmuxl.c b/net/caif/cfmuxl.c
index 3a66b8c..c23979e 100644
--- a/net/caif/cfmuxl.c
+++ b/net/caif/cfmuxl.c
@@ -255,7 +255,7 @@ static void cfmuxl_ctrlcmd(struct cflayer *layr, en=
um caif_ctrlcmd ctrl,
=20
 		if (cfsrvl_phyid_match(layer, phyid) && layer->ctrlcmd) {
=20
-			if ((ctrl =3D=3D _CAIF_CTRLCMD_PHYIF_FLOW_OFF_IND ||
+			if ((ctrl =3D=3D _CAIF_CTRLCMD_PHYIF_DOWN_IND ||
 				ctrl =3D=3D CAIF_CTRLCMD_REMOTE_SHUTDOWN_IND) &&
 					layer->id !=3D 0) {
=20
--=20
1.7.0.4

