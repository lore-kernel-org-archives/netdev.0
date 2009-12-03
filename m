From: Marcel Holtmann <marcel@holtmann.org>
Subject: [PATCH 17/18] Bluetooth: Add RFCOMM option to use L2CAP ERTM mode
Date: Thu,  3 Dec 2009 19:45:54 +0100
Message-ID: <eae38eede2e5f70d65f09327297bd698b0d3ea7e.1259865280.git.marcel@holtmann.org>
References: <cover.1259865279.git.marcel@holtmann.org>
 <b3cf652afb5404685e3d7ed6780a8d1fa10e21da.1259865280.git.marcel@holtmann.org>
 <5990108cfcd3eb2d365c9ea6f82318be80c4e9d3.1259865280.git.marcel@holtmann.org>
 <329ab1b3e6ceac3f77ab400206a97cc402624259.1259865280.git.marcel@holtmann.org>
 <fed4c2508b7419d0a55958fead6151b32def1683.1259865280.git.marcel@holtmann.org>
 <2da31939a42f7a676a0bc5155d6a0a39ed8451f2.1259865280.git.marcel@holtmann.org>
 <7e21addcd0ad87696c17409399e56e874931da57.1259865280.git.marcel@holtmann.org>
 <76bca88012e1d27de794f32cc551d6314d38b6d9.1259865280.git.marcel@holtmann.org>
 <c78ae283145d3a8799b2fb01650166a66af3bff8.1259865280.git.marcel@holtmann.org>
 <cde9f807f003676862178a6f28b52c7d431511ed.1259865280.git.marcel@holtmann.org>
 <0565c1c24af94130b891f989fa608faddfadc52c.1259865280.git.marcel@holtmann.org>
 <889a3ca466018ab68363c3168993793bc2d984f1.1259865280.git.marcel@holtmann.org>
 <9f121a5a80b4417c6db5a35e26d2e79c29c3fc0d.1259865280.git.marcel@holtmann.org>
 <4ec10d9720ef78cd81d8bcc30a3238665744569f.1259865280.git.marcel@holtmann.org>
 <2ab25cdd7b54473dd42dcffc9872737de2517466.1259865280.git.marcel@holtmann.org>
 <32fd63981ed453bd882f22e3e9b0ccbc11fb47e5.1259865280.git.marcel@holtmann.org>
 <5fbcd3d1a07e234583e17830e8aef47282c22141.1259865280.git.marcel@holtmann.org>
Cc: netdev@vger.kernel.org
To: "David S. Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from senator.holtmann.net ([87.106.208.187]:37648 "EHLO
	mail.holtmann.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756539AbZLCSqE (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 3 Dec 2009 13:46:04 -0500
In-Reply-To: <5fbcd3d1a07e234583e17830e8aef47282c22141.1259865280.git.marcel@holtmann.org>
In-Reply-To: <cover.1259865279.git.marcel@holtmann.org>
References: <cover.1259865279.git.marcel@holtmann.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

By default the RFCOMM layer would still use L2CAP basic mode. For testing
purposes this option enables RFCOMM to select enhanced retransmission
mode.

Signed-off-by: Marcel Holtmann <marcel@holtmann.org>
---
 net/bluetooth/rfcomm/core.c |    6 ++++++
 1 files changed, 6 insertions(+), 0 deletions(-)

diff --git a/net/bluetooth/rfcomm/core.c b/net/bluetooth/rfcomm/core.c
index 25692bc..fc5ee32 100644
--- a/net/bluetooth/rfcomm/core.c
+++ b/net/bluetooth/rfcomm/core.c
@@ -51,6 +51,7 @@
 static int disable_cfc = 0;
 static int channel_mtu = -1;
 static unsigned int l2cap_mtu = RFCOMM_MAX_L2CAP_MTU;
+static int l2cap_ertm = 0;
 
 static struct task_struct *rfcomm_thread;
 
@@ -702,6 +703,8 @@ static struct rfcomm_session *rfcomm_session_create(bdaddr_t *src, bdaddr_t *dst
 	sk = sock->sk;
 	lock_sock(sk);
 	l2cap_pi(sk)->imtu = l2cap_mtu;
+	if (l2cap_ertm)
+		l2cap_pi(sk)->mode = L2CAP_MODE_ERTM;
 	release_sock(sk);
 
 	s = rfcomm_session_add(sock, BT_BOUND);
@@ -2185,6 +2188,9 @@ MODULE_PARM_DESC(channel_mtu, "Default MTU for the RFCOMM channel");
 module_param(l2cap_mtu, uint, 0644);
 MODULE_PARM_DESC(l2cap_mtu, "Default MTU for the L2CAP connection");
 
+module_param(l2cap_ertm, bool, 0644);
+MODULE_PARM_DESC(l2cap_ertm, "Use L2CAP ERTM mode for connection");
+
 MODULE_AUTHOR("Marcel Holtmann <marcel@holtmann.org>");
 MODULE_DESCRIPTION("Bluetooth RFCOMM ver " VERSION);
 MODULE_VERSION(VERSION);
-- 
1.6.5.2

