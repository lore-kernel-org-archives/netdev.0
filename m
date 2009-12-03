From: Marcel Holtmann <marcel@holtmann.org>
Subject: [PATCH 14/18] Bluetooth: Fix 'SendRRorRNR' to send the ReqSeq value
Date: Thu,  3 Dec 2009 19:45:51 +0100
Message-ID: <2ab25cdd7b54473dd42dcffc9872737de2517466.1259865280.git.marcel@holtmann.org>
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
Cc: netdev@vger.kernel.org
To: "David S. Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from senator.holtmann.net ([87.106.208.187]:37648 "EHLO
	mail.holtmann.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756541AbZLCSqC (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 3 Dec 2009 13:46:02 -0500
In-Reply-To: <4ec10d9720ef78cd81d8bcc30a3238665744569f.1259865280.git.marcel@holtmann.org>
In-Reply-To: <cover.1259865279.git.marcel@holtmann.org>
References: <cover.1259865279.git.marcel@holtmann.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Gustavo F. Padovan <gustavo@las.ic.unicamp.br>

SendRRorRNR needs to acknowledge received I-frames (actually every packet
needs to acknowledge received I-frames by sending the proper packet
sequence number), so ReqSeq is set to the next I-frame number sequence to
be pulled by the reassembly function.
SendRRorRNR tells the remote side about local busy conditions, it sends
a Receiver Ready frame if local busy is false or a Receiver Not Ready
if local busy is true.
ReqSeq is the packet's field to send the number of the acknowledged
packets.

Signed-off-by: Gustavo F. Padovan <gustavo@las.ic.unicamp.br>
Signed-off-by: Marcel Holtmann <marcel@holtmann.org>
---
 net/bluetooth/l2cap.c |    2 ++
 1 files changed, 2 insertions(+), 0 deletions(-)

diff --git a/net/bluetooth/l2cap.c b/net/bluetooth/l2cap.c
index 73bda0a..c898f34 100644
--- a/net/bluetooth/l2cap.c
+++ b/net/bluetooth/l2cap.c
@@ -373,6 +373,8 @@ static inline int l2cap_send_rr_or_rnr(struct l2cap_pinfo *pi, u16 control)
 	else
 		control |= L2CAP_SUPER_RCV_READY;
 
+	control |= pi->buffer_seq << L2CAP_CTRL_REQSEQ_SHIFT;
+
 	return l2cap_send_sframe(pi, control);
 }
 
-- 
1.6.5.2

