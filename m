From: Marcel Holtmann <marcel@holtmann.org>
Subject: [PATCH 3/3] Bluetooth: Fix regression with L2CAP configuration in Basic Mode
Date: Mon, 16 Nov 2009 01:48:23 +0100
Message-ID: <68ae6639b6dff117ba37f648f1611a4629abadf0.1258331614.git.marcel@holtmann.org>
References: <cover.1258331614.git.marcel@holtmann.org>
 <93f19c9fc8c98bb6d2e9825115989603ffd5cd1f.1258331614.git.marcel@holtmann.org>
 <a0e55a32afc2130e5ae506755e4b8eb42a23b568.1258331614.git.marcel@holtmann.org>
Cc: netdev@vger.kernel.org
To: "David S. Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from senator.holtmann.net ([87.106.208.187]:46542 "EHLO
	mail.holtmann.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752579AbZKPAs1 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 15 Nov 2009 19:48:27 -0500
In-Reply-To: <a0e55a32afc2130e5ae506755e4b8eb42a23b568.1258331614.git.marcel@holtmann.org>
In-Reply-To: <cover.1258331614.git.marcel@holtmann.org>
References: <cover.1258331614.git.marcel@holtmann.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Gustavo F. Padovan <gustavo@las.ic.unicamp.br>

Basic Mode is the default mode of operation of a L2CAP entity. In
this case the RFC (Retransmission and Flow Control) configuration
option should not be used at all.

Normally remote L2CAP implementation should just ignore this option,
but it can cause various side effects with other Bluetooth stacks
that are not capable of handling unknown options.

Signed-off-by: Gustavo F. Padovan <gustavo@las.ic.unicamp.br>
Signed-off-by: Marcel Holtmann <marcel@holtmann.org>
---
 net/bluetooth/l2cap.c |   11 ++++++++---
 1 files changed, 8 insertions(+), 3 deletions(-)

diff --git a/net/bluetooth/l2cap.c b/net/bluetooth/l2cap.c
index 076caa1..947f8bb 100644
--- a/net/bluetooth/l2cap.c
+++ b/net/bluetooth/l2cap.c
@@ -2394,6 +2394,10 @@ done:
 			rfc.monitor_timeout = L2CAP_DEFAULT_MONITOR_TO;
 
 			pi->conf_state |= L2CAP_CONF_MODE_DONE;
+
+			l2cap_add_conf_opt(&ptr, L2CAP_CONF_RFC,
+					sizeof(rfc), (unsigned long) &rfc);
+
 			break;
 
 		case L2CAP_MODE_STREAMING:
@@ -2401,6 +2405,10 @@ done:
 			pi->max_pdu_size = rfc.max_pdu_size;
 
 			pi->conf_state |= L2CAP_CONF_MODE_DONE;
+
+			l2cap_add_conf_opt(&ptr, L2CAP_CONF_RFC,
+					sizeof(rfc), (unsigned long) &rfc);
+
 			break;
 
 		default:
@@ -2410,9 +2418,6 @@ done:
 			rfc.mode = pi->mode;
 		}
 
-		l2cap_add_conf_opt(&ptr, L2CAP_CONF_RFC,
-					sizeof(rfc), (unsigned long) &rfc);
-
 		if (result == L2CAP_CONF_SUCCESS)
 			pi->conf_state |= L2CAP_CONF_OUTPUT_DONE;
 	}
-- 
1.6.2.5

