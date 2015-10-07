From: =?UTF-8?q?Vincent=20Stehl=C3=A9?= <vincent.stehle@laposte.net>
Subject: [PATCH] nfc: netlink: avoid NULL pointer dereference on error
Date: Wed,  7 Oct 2015 11:33:19 +0200
Message-ID: <1444210399-3913-1-git-send-email-vincent.stehle@laposte.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	=?UTF-8?q?Vincent=20Stehl=C3=A9?= <vincent.stehle@laposte.net>,
	Thierry Escande <thierry.escande@linux.intel.com>,
	Samuel Ortiz <sameo@linux.intel.com>
To: linux-wireless@vger.kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

The function nfc_genl_llc_sdreq() can dereference the dev pointer while
it is NULL on its error path. Create a new error handling label to avoi=
d
that.

This fixes the following coccinelle error:

  ./net/nfc/netlink.c:1175:21-24: ERROR: dev is NULL but dereferenced.

Signed-off-by: Vincent Stehl=C3=A9 <vincent.stehle@laposte.net>
Cc: Thierry Escande <thierry.escande@linux.intel.com>
Cc: Samuel Ortiz <sameo@linux.intel.com>
---
 net/nfc/netlink.c | 3 ++-
 1 file changed, 2 insertions(+), 1 deletion(-)

diff --git a/net/nfc/netlink.c b/net/nfc/netlink.c
index 853172c..51c48f0 100644
--- a/net/nfc/netlink.c
+++ b/net/nfc/netlink.c
@@ -1111,7 +1111,7 @@ static int nfc_genl_llc_sdreq(struct sk_buff *skb=
, struct genl_info *info)
 	dev =3D nfc_get_device(idx);
 	if (!dev) {
 		rc =3D -ENODEV;
-		goto exit;
+		goto exit_nodev;
 	}
=20
 	device_lock(&dev->dev);
@@ -1176,6 +1176,7 @@ exit:
=20
 	nfc_put_device(dev);
=20
+exit_nodev:
 	return rc;
 }
=20
--=20
2.5.1
