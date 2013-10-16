From: =?UTF-8?q?Salva=20Peir=C3=B3?= <speiro@ai2.upv.es>
Subject: =?UTF-8?q?=5BPATCH=5D=20wanxl=3A=20fix=20info=20leak=20in=20ioctl?=
Date: Wed, 16 Oct 2013 12:46:50 +0200
Message-ID: <1381920411-16981-1-git-send-email-speiro@ai2.upv.es>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: =?UTF-8?q?Salva=20Peir=C3=B3?= <speiro@ai2.upv.es>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtpsalv.cc.upv.es ([158.42.249.11]:55444 "EHLO smtpsalv.upv.es"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1760680Ab3JPKyP (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 16 Oct 2013 06:54:15 -0400
CC: Krzysztof Halasa <khc@pm.waw.pl>
CC: security@kernel.org
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The wanxl_ioctl() code fails to initialize the two padding bytes of
struct sync_serial_settings after the ->loopback member. Add an explici=
t
memset(0) before filling the structure to avoid the info leak.

Signed-off-by: Salva Peir=C3=B3 <speiro@ai2.upv.es>
---
 drivers/net/wan/wanxl.c |    1 +
 1 file changed, 1 insertion(+)

diff --git a/drivers/net/wan/wanxl.c b/drivers/net/wan/wanxl.c
index 6a24a5a..4c0a697 100644
--- a/drivers/net/wan/wanxl.c
+++ b/drivers/net/wan/wanxl.c
@@ -355,6 +355,7 @@ static int wanxl_ioctl(struct net_device *dev, stru=
ct ifreq *ifr, int cmd)
 			ifr->ifr_settings.size =3D size; /* data size wanted */
 			return -ENOBUFS;
 		}
+		memset(&line, 0, sizeof(line));
 		line.clock_type =3D get_status(port)->clocking;
 		line.clock_rate =3D 0;
 		line.loopback =3D 0;
--
1.7.10.4
