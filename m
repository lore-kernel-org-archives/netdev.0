From: =?UTF-8?q?Salva=20Peir=C3=B3?= <speiro@ai2.upv.es>
Subject: =?UTF-8?q?=5BPATCH=20v2=5D=20hamradio/yam=3A=20fix=20info=20leak=20in=20ioctl?=
Date: Tue, 17 Dec 2013 10:06:30 +0100
Message-ID: <1387271191-10355-1-git-send-email-speiro@ai2.upv.es>
References: <1386920767-27962-1-git-send-email-speiro@ai2.upv.es>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: =?UTF-8?q?Salva=20Peir=C3=B3?= <speiro@ai2.upv.es>,
	security@kernel.org, linux-hams@vger.kernel.org,
	netdev@vger.kernel.org, Jean-Paul Roubelat <jpr@f6fbb.org>,
	stable@vger.kernel.org
To: linux-kernel@vger.kernel.org
Return-path: <linux-hams-owner@vger.kernel.org>
In-Reply-To: <1386920767-27962-1-git-send-email-speiro@ai2.upv.es>
Sender: linux-hams-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

The yam_ioctl() code fails to initialise the cmd field
of the struct yamdrv_ioctl_cfg. Add an explicit memset(0)
before filling the structure to avoid the 4-byte info leak.

Signed-off-by: Salva Peir=C3=B3 <speiro@ai2.upv.es>
CC: <stable@vger.kernel.org>
---
 drivers/net/hamradio/yam.c |    1 +
 1 file changed, 1 insertion(+)

diff --git a/drivers/net/hamradio/yam.c b/drivers/net/hamradio/yam.c
index 1971411..61dd244 100644
--- a/drivers/net/hamradio/yam.c
+++ b/drivers/net/hamradio/yam.c
@@ -1057,6 +1057,7 @@ static int yam_ioctl(struct net_device *dev, stru=
ct ifreq *ifr, int cmd)
 		break;
=20
 	case SIOCYAMGCFG:
+		memset(&yi, 0, sizeof(yi));
 		yi.cfg.mask =3D 0xffffffff;
 		yi.cfg.iobase =3D yp->iobase;
 		yi.cfg.irq =3D yp->irq;
--=20
1.7.10.4

--
To unsubscribe from this list: send the line "unsubscribe linux-hams" i=
n
the body of a message to majordomo@vger.kernel.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
