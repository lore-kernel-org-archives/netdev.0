From: sjur.brandeland@stericsson.com
Subject: [net-next 02/11] caif: added check for potential null return
Date: Mon, 25 Jun 2012 19:49:34 +0200
Message-ID: <1340646583-21059-3-git-send-email-sjur.brandeland@stericsson.com>
References: <1340646583-21059-1-git-send-email-sjur.brandeland@stericsson.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org, sjurbren@gmail.com,
	Kim Lilliestierna XX <kim.xx.lilliestierna@stericsson.com>,
	Kim Lilliestierna <Kim.xx.Lilliestierna@stericsson.com>,
	=?UTF-8?q?Sjur=20Br=C3=A6ndeland?=
	<sjur.brandeland@stericssion.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-lb0-f174.google.com ([209.85.217.174]:34031 "EHLO
	mail-lb0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753651Ab2FYRty (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 25 Jun 2012 13:49:54 -0400
Received: by mail-lb0-f174.google.com with SMTP id gm6so6807265lbb.19
        for <netdev@vger.kernel.org>; Mon, 25 Jun 2012 10:49:53 -0700 (PDT)
In-Reply-To: <1340646583-21059-1-git-send-email-sjur.brandeland@stericsson.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

=46rom: Kim Lilliestierna XX <kim.xx.lilliestierna@stericsson.com>

Add check on NULL return from caif_get().

Signed-off-by: Kim Lilliestierna <Kim.xx.Lilliestierna@stericsson.com>
Signed-off-by: Sjur Br=C3=A6ndeland <sjur.brandeland@stericssion.com>
---
 net/caif/caif_dev.c |    5 +++++
 1 files changed, 5 insertions(+), 0 deletions(-)

diff --git a/net/caif/caif_dev.c b/net/caif/caif_dev.c
index 92c9397..0f010af 100644
--- a/net/caif/caif_dev.c
+++ b/net/caif/caif_dev.c
@@ -129,6 +129,11 @@ void caif_flow_cb(struct sk_buff *skb)
=20
 	rcu_read_lock();
 	caifd =3D caif_get(skb->dev);
+
+	WARN_ON(caifd =3D=3D NULL);
+	if (caifd =3D=3D NULL)
+		return;
+
 	caifd_hold(caifd);
 	rcu_read_unlock();
=20
--=20
1.7.5.4
