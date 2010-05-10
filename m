From: Marcel Holtmann <marcel@holtmann.org>
Subject: [PATCH 09/64] Bluetooth: Fix ACL MTU issue
Date: Mon, 10 May 2010 11:36:59 +0200
Message-ID: <d1daa091e8612f3aab14d28b5836375fafe155e1.1273484096.git.marcel@holtmann.org>
References: <cover.1273484094.git.marcel@holtmann.org>
 <fe1aff710756ac73c455d214845c74e304d0e966.1273484095.git.marcel@holtmann.org>
 <acce90d6a957812081b83ac4d1133e93a43569c6.1273484095.git.marcel@holtmann.org>
 <4f7ac1814ef6f0773e57ffd159a1dd57a3c80521.1273484095.git.marcel@holtmann.org>
 <0d861d8b8edd139a9b291cb262d08dec8dc3922d.1273484095.git.marcel@holtmann.org>
 <b9dbdbc1f4404cba2e64939c30c87d59c9796e4e.1273484095.git.marcel@holtmann.org>
 <c69163e9ed5048407cc84f439cbfecc53f6f7131.1273484095.git.marcel@holtmann.org>
 <faaebd192ec9c3febcab98149d1309199a5b886c.1273484095.git.marcel@holtmann.org>
 <7dffe4210233a2860c3f41477c40b3252edf2b7d.1273484095.git.marcel@holtmann.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from senator.holtmann.net ([87.106.208.187]:53441 "EHLO
	mail.holtmann.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755715Ab0EJJin (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 10 May 2010 05:38:43 -0400
In-Reply-To: <7dffe4210233a2860c3f41477c40b3252edf2b7d.1273484095.git.marcel@holtmann.org>
In-Reply-To: <cover.1273484094.git.marcel@holtmann.org>
References: <cover.1273484094.git.marcel@holtmann.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

=46rom: Gustavo F. Padovan <padovan@profusion.mobi>

ERTM and Streaming Modes was having problems when the ACL MTU is lower
than MPS. The 'minus 10' is to take in account the header and fcs
lenghts.

Signed-off-by: Gustavo F. Padovan <padovan@profusion.mobi>
Reviewed-by: Jo=C3=A3o Paulo Rechi Vita <jprvita@profusion.mobi>
Signed-off-by: Marcel Holtmann <marcel@holtmann.org>
---
 net/bluetooth/l2cap.c |    4 ++++
 1 files changed, 4 insertions(+), 0 deletions(-)

diff --git a/net/bluetooth/l2cap.c b/net/bluetooth/l2cap.c
index 401011a..99cf177 100644
--- a/net/bluetooth/l2cap.c
+++ b/net/bluetooth/l2cap.c
@@ -2267,6 +2267,8 @@ done:
 		rfc.retrans_timeout =3D 0;
 		rfc.monitor_timeout =3D 0;
 		rfc.max_pdu_size    =3D cpu_to_le16(L2CAP_DEFAULT_MAX_PDU_SIZE);
+		if (L2CAP_DEFAULT_MAX_PDU_SIZE > pi->conn->mtu - 10)
+			rfc.max_pdu_size =3D pi->conn->mtu - 10;
=20
 		l2cap_add_conf_opt(&ptr, L2CAP_CONF_RFC,
 					sizeof(rfc), (unsigned long) &rfc);
@@ -2288,6 +2290,8 @@ done:
 		rfc.retrans_timeout =3D 0;
 		rfc.monitor_timeout =3D 0;
 		rfc.max_pdu_size    =3D cpu_to_le16(L2CAP_DEFAULT_MAX_PDU_SIZE);
+		if (L2CAP_DEFAULT_MAX_PDU_SIZE > pi->conn->mtu - 10)
+			rfc.max_pdu_size =3D pi->conn->mtu - 10;
=20
 		l2cap_add_conf_opt(&ptr, L2CAP_CONF_RFC,
 					sizeof(rfc), (unsigned long) &rfc);
--=20
1.6.6.1

