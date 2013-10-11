From: Dan Carpenter <dan.carpenter@oracle.com>
Subject: [patch] farsync: fix info leak in ioctl
Date: Fri, 11 Oct 2013 12:50:03 +0300
Message-ID: <20131011095003.GD6247@mwanda>
References: <5257BFBA.7030405@ai2.upv.es>
Mime-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Salva =?iso-8859-1?Q?Peir=F3?= <speiro@ai2.upv.es>,
	security@kernel.org, netdev@vger.kernel.org
To: Kevin Curtis <kevin.curtis@farsite.co.uk>
Return-path: <netdev-owner@vger.kernel.org>
Received: from aserp1040.oracle.com ([141.146.126.69]:42400 "EHLO
	aserp1040.oracle.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1757327Ab3JKJuT (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 11 Oct 2013 05:50:19 -0400
Content-Disposition: inline
In-Reply-To: <5257BFBA.7030405@ai2.upv.es>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

=46rom: Salva Peir=F3 <speiro@ai2.upv.es>

The fst_get_iface() code fails to initialize the two padding bytes of
struct sync_serial_settings after the ->loopback member. Add an explici=
t
memset(0) before filling the structure to avoid the info leak.

Signed-off-by: Dan Carpenter <dan.carpenter@oracle.com>

---
 linux-3.4-xm/drivers/net/wan/farsync.c |    1 +
 1 file changed, 1 insertion(+)

diff --git a/linux-3.4-xm/drivers/net/wan/farsync.c b/linux-3.4-xm/driv=
ers/net/wan/farsync.c
index 1a62318..3710427 100644
--- a/drivers/net/wan/farsync.c
+++ b/drivers/net/wan/farsync.c
@@ -1972,6 +1972,7 @@ fst_get_iface(struct fst_card_info *card, struct =
fst_port_info *port,
 	}
=20
 	i =3D port->index;
+	memset(&sync, 0, sizeof(sync));
 	sync.clock_rate =3D FST_RDL(card, portConfig[i].lineSpeed);
 	/* Lucky card and linux use same encoding here */
 	sync.clock_type =3D FST_RDB(card, portConfig[i].internalClock) =3D=3D
--=20
1.7.10.4
