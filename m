From: Marcel Holtmann <marcel@holtmann.org>
Subject: [PATCH 2/2] Bluetooth: Fix issue with uninitialized nsh.type in DTL-1 driver
Date: Sun, 14 Jun 2009 15:39:11 +0200
Message-ID: <b0965c8c0fb8eb62f3ba50179f7d060c60ce475e.1244986258.git.marcel@holtmann.org>
References: <cover.1244986258.git.marcel@holtmann.org>
 <1a097181ee8b0c492c021eb3dbaa5f9cd813ad0e.1244986258.git.marcel@holtmann.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from senator.holtmann.net ([87.106.208.187]:55478 "EHLO
	mail.holtmann.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756032AbZFNNjQ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 14 Jun 2009 09:39:16 -0400
In-Reply-To: <1a097181ee8b0c492c021eb3dbaa5f9cd813ad0e.1244986258.git.marcel@holtmann.org>
In-Reply-To: <cover.1244986258.git.marcel@holtmann.org>
References: <cover.1244986258.git.marcel@holtmann.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The current build shows a warning with the DTL-1 driver:

  CC [M]  drivers/bluetooth/dtl1_cs.o
drivers/bluetooth/dtl1_cs.c: In function =E2=80=98dtl1_hci_send_frame=E2=
=80=99:
drivers/bluetooth/dtl1_cs.c:396: warning: =E2=80=98nsh.type=E2=80=99 ma=
y be used uninitialized i
n this function

=46ix this by adding a proper error for unknown packet types.

Signed-off-by: Marcel Holtmann <marcel@holtmann.org>
---
 drivers/bluetooth/dtl1_cs.c |    2 ++
 1 files changed, 2 insertions(+), 0 deletions(-)

diff --git a/drivers/bluetooth/dtl1_cs.c b/drivers/bluetooth/dtl1_cs.c
index 901bdd9..2cc7b32 100644
--- a/drivers/bluetooth/dtl1_cs.c
+++ b/drivers/bluetooth/dtl1_cs.c
@@ -415,6 +415,8 @@ static int dtl1_hci_send_frame(struct sk_buff *skb)
 		hdev->stat.sco_tx++;
 		nsh.type =3D 0x83;
 		break;
+	default:
+		return -EILSEQ;
 	};
=20
 	nsh.zero =3D 0;
--=20
1.6.2.2

