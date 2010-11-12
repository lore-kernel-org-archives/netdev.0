From: Dan Rosenberg <drosenberg@vsecurity.com>
Subject: [PATCH 1/10] Fix leaking of kernel heap addresses in net/
Date: Thu, 11 Nov 2010 20:06:55 -0500
Message-ID: <1289524015.5167.65.camel@dan>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
To: "David S. Miller" <davem@davemloft.net>,
	Oliver Hartkopp <socketcan@hartkopp.net>,
	Alexey Kuznetsov <kuznet@ms2.inr.ac.ru>,
	Urs Thuermann <urs.thuermann@volkswagen.de>,
	Hideaki YOSHI
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.vsecurity.com ([209.67.252.12]:60617 "EHLO
	mx1.vsecurity.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755575Ab0KLBHN (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 11 Nov 2010 20:07:13 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

diff --git a/net/atm/proc.c b/net/atm/proc.c
index f85da07..21ec2ba 100644
--- a/net/atm/proc.c
+++ b/net/atm/proc.c
@@ -191,7 +191,7 @@ static void vcc_info(struct seq_file *seq, struct atm_vcc *vcc)
 {
 	struct sock *sk = sk_atm(vcc);
 
-	seq_printf(seq, "%p ", vcc);
+	seq_printf(seq, "%lu ", sock_i_ino(sk));
 	if (!vcc->dev)
 		seq_printf(seq, "Unassigned    ");
 	else



