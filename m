From: Marcel Holtmann <marcel@holtmann.org>
Subject: [PATCH 4/5] Bluetooth: Fix L2CAP locking scheme regression
Date: Thu, 17 Dec 2009 12:22:46 -0800
Message-ID: <b13f5860447a98daf0358a51fbff66154ac0663a.1261080894.git.marcel@holtmann.org>
References: <cover.1261080894.git.marcel@holtmann.org>
 <971beb83aeb2a309175682cf5683d64fd4591841.1261080894.git.marcel@holtmann.org>
 <186de9a33803c7ee20d9af75c9049b50e68a3a08.1261080894.git.marcel@holtmann.org>
 <186ee8cf0130993dea8ab8867ff1af8a148f9ae6.1261080894.git.marcel@holtmann.org>
Cc: netdev@vger.kernel.org
To: "David S. Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from senator.holtmann.net ([87.106.208.187]:33952 "EHLO
	mail.holtmann.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S936890AbZLQUXX (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 17 Dec 2009 15:23:23 -0500
In-Reply-To: <186ee8cf0130993dea8ab8867ff1af8a148f9ae6.1261080894.git.marcel@holtmann.org>
In-Reply-To: <cover.1261080894.git.marcel@holtmann.org>
References: <cover.1261080894.git.marcel@holtmann.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Andrei Emeltchenko <andrei.emeltchenko@nokia.com>

When locking was introduced the error path branch was not taken
into account. Error was found in sparse code checking. Kudos to
Jani Nikula.

Signed-off-by: Andrei Emeltchenko <andrei.emeltchenko@nokia.com>
Acked-by: Gustavo F. Padovan <gustavo@las.ic.unicamp.br>
Signed-off-by: Marcel Holtmann <marcel@holtmann.org>
---
 net/bluetooth/l2cap.c |    1 +
 1 files changed, 1 insertions(+), 0 deletions(-)

diff --git a/net/bluetooth/l2cap.c b/net/bluetooth/l2cap.c
index fb0f81d..1120cf1 100644
--- a/net/bluetooth/l2cap.c
+++ b/net/bluetooth/l2cap.c
@@ -1212,6 +1212,7 @@ static void l2cap_monitor_timeout(unsigned long arg)
 	bh_lock_sock(sk);
 	if (l2cap_pi(sk)->retry_count >= l2cap_pi(sk)->remote_max_tx) {
 		l2cap_send_disconn_req(l2cap_pi(sk)->conn, sk);
+		bh_unlock_sock(sk);
 		return;
 	}
 
-- 
1.6.5.2

