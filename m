From: Alan Cox <alan@linux.intel.com>
Subject: [PATCH 2/2] ethoc: fix warning from 32bit build
Date: Mon, 12 Oct 2009 16:27:55 +0100
Message-ID: <20091012152753.5694.18204.stgit@localhost.localdomain>
References: <20091012152247.5694.77290.stgit@localhost.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
To: netdev@vger.kernel.org, linux-kernel@vger.kernel.org
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S932627AbZJLPjp@vger.kernel.org>
In-Reply-To: <20091012152247.5694.77290.stgit@localhost.localdomain>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

drivers/net/ethoc.c: In function =E2=80=98ethoc_open=E2=80=99:
drivers/net/ethoc.c:667: warning: comparison of distinct pointer types
lacks a cast

Signed-off-by: Alan Cox <alan@linux.intel.com>
---

 drivers/net/ethoc.c |    3 ++-
 1 files changed, 2 insertions(+), 1 deletions(-)


diff --git a/drivers/net/ethoc.c b/drivers/net/ethoc.c
index 96f5b2a..402a507 100644
--- a/drivers/net/ethoc.c
+++ b/drivers/net/ethoc.c
@@ -664,7 +664,8 @@ static int ethoc_open(struct net_device *dev)
 		return ret;
=20
 	/* calculate the number of TX/RX buffers, maximum 128 supported */
-	num_bd =3D min(128, (dev->mem_end - dev->mem_start + 1) / ETHOC_BUFSI=
Z);
+	num_bd =3D min_t(unsigned int,=20
+		128, (dev->mem_end - dev->mem_start + 1) / ETHOC_BUFSIZ);
 	priv->num_tx =3D max(min_tx, num_bd / 4);
 	priv->num_rx =3D num_bd - priv->num_tx;
 	ethoc_write(priv, TX_BD_NUM, priv->num_tx);
