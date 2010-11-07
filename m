From: Dan Rosenberg <drosenberg@vsecurity.com>
Subject: [PATCH 1/9] Fix leaking of kernel heap addresses in net/
Date: Sun, 07 Nov 2010 11:31:39 -0500
Message-ID: <1289147499.3090.138.camel@Dan>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, security@kernel.org, stable@kernel.org
To: chas@cmf.nrl.navy.mil, davem@davemloft.net, kuznet@ms2.inr.ac.ru,
	pekkas@netcore.fi, jmorris@namei.org, yoshfuji@linux-ipv6.org,
	kaber@trash.net, remi.denis-courmont@nokia.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.vsecurity.com ([209.67.252.12]:53593 "EHLO
	mx1.vsecurity.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753561Ab0KGQbk (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 7 Nov 2010 11:31:40 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Signed-off-by: Dan Rosenberg <drosenberg@vsecurity.com>

diff -urp linux-2.6.37-rc1.orig/net/atm/proc.c linux-2.6.37-rc1/net/atm/proc.c
--- linux-2.6.37-rc1.orig/net/atm/proc.c	2010-11-01 07:54:12.000000000 -0400
+++ linux-2.6.37-rc1/net/atm/proc.c	2010-11-07 10:22:40.000000000 -0500
@@ -191,7 +191,7 @@ static void vcc_info(struct seq_file *se
 {
 	struct sock *sk = sk_atm(vcc);
 
-	seq_printf(seq, "%p ", vcc);
+	seq_printf(seq, "%lu ", sock_i_ino(sk));
 	if (!vcc->dev)
 		seq_printf(seq, "Unassigned    ");
 	else




