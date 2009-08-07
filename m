From: =?utf-8?q?Uwe=20Kleine-K=C3=B6nig?=
	<u.kleine-koenig@pengutronix.de>
Subject: [PATCH 5/6] [NET] ixp2000/enp2611: don't set non-existent member get_stats
Date: Fri,  7 Aug 2009 22:42:40 +0200
Message-ID: <1249677761-19470-5-git-send-email-u.kleine-koenig@pengutronix.de>
References: <20090807203939.GA19374@pengutronix.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: LKML <linux-kernel@vger.kernel.org>,
	rt-users <linux-rt-users@vger.kernel.org>,
	Russell King <linux@arm.linux.org.uk>,
	Dmitry Baryshkov <dbaryshkov@gmail.com>,
	Lennert Buytenhek <kernel@wantstofly.org>,
	netdev@vger.kernel.org
To: Thomas Gleixner <tglx@linutronix.de>
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S933984AbZHGUnR@vger.kernel.org>
In-Reply-To: <20090807203939.GA19374@pengutronix.de>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

This fixes a build failure for 2.6.31-rc5 (ARCH=3Darm, ixp2000_defconfi=
g):

	  CC      drivers/net/ixp2000/enp2611.o
	drivers/net/ixp2000/enp2611.c: In function 'enp2611_init_module':
	drivers/net/ixp2000/enp2611.c:213: error: 'struct net_device' has no m=
ember named 'get_stats'

Signed-off-by: Uwe Kleine-K=C3=B6nig <u.kleine-koenig@pengutronix.de>
Cc: Russell King <linux@arm.linux.org.uk>
Cc: Dmitry Baryshkov <dbaryshkov@gmail.com>
Cc: Lennert Buytenhek <kernel@wantstofly.org>
Cc: netdev@vger.kernel.org
---
Hello,

obviously this has the downside that the stats won't work, I let the fi=
x
for someone else :-)

Best regards
Uwe
---
 drivers/net/ixp2000/enp2611.c |    2 +-
 1 files changed, 1 insertions(+), 1 deletions(-)

diff --git a/drivers/net/ixp2000/enp2611.c b/drivers/net/ixp2000/enp261=
1.c
index b02a981..d6ef176 100644
--- a/drivers/net/ixp2000/enp2611.c
+++ b/drivers/net/ixp2000/enp2611.c
@@ -210,7 +210,7 @@ static int __init enp2611_init_module(void)
 			return -ENOMEM;
 		}
=20
-		nds[i]->get_stats =3D enp2611_get_stats;
+		/* nds[i]->get_stats =3D enp2611_get_stats; */
 		pm3386_init_port(i);
 		pm3386_get_mac(i, nds[i]->dev_addr);
 	}
--=20
1.6.3.3
