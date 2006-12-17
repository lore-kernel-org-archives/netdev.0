From: Evgeniy Polyakov <johnpol@2ka.mipt.ru>
Subject: [1/1] connector: fix compilation breakage introduced recently.
Date: Sun, 17 Dec 2006 14:29:46 +0300
Message-ID: <20061217112946.GA15926@2ka.mipt.ru>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Toralf =?utf-8?Q?F=C3=B6rster?= <toralf.foerster@gmx.de>,
	netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from relay.2ka.mipt.ru ([194.85.82.65]:41751 "EHLO 2ka.mipt.ru"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752460AbWLQLb1 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sun, 17 Dec 2006 06:31:27 -0500
To: David Miller <davem@davemloft.net>
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Linus has changed work queue structure and has not tested it with
connector compiled in, his changes break the build.

Attached patch fixes compilation error.

Patch is against commit 99f5e9718185f07458ae70c2282c2153a2256c91.

Thanks to Toralf F=C3=B6rster for pointing this out.

Signed-off-by: Evgeniy Polyakov <johnpol@2ka.mipt.ru>

diff --git a/drivers/connector/connector.c b/drivers/connector/connecto=
r.c
index 5e7cd45..4cec1a8 100644
--- a/drivers/connector/connector.c
+++ b/drivers/connector/connector.c
@@ -135,8 +135,7 @@ static int cn_call_callback(struct cn_msg *msg, voi=
d (*destruct_data)(void *), v
 	spin_lock_bh(&dev->cbdev->queue_lock);
 	list_for_each_entry(__cbq, &dev->cbdev->queue_list, callback_entry) {
 		if (cn_cb_equal(&__cbq->id.id, &msg->id)) {
-			if (likely(!test_bit(WORK_STRUCT_PENDING,
-					     &__cbq->work.work.management) &&
+			if (likely(!work_pending(&__cbq->work.work) &&
 					__cbq->data.ddata =3D=3D NULL)) {
 				__cbq->data.callback_priv =3D msg;
=20


--=20
	Evgeniy Polyakov
