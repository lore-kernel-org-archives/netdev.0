From: Dave Jones <davej@redhat.com>
Subject: Add missing socket check in can/bcm release.
Date: Tue, 19 Apr 2011 23:30:01 -0400
Message-ID: <20110420033001.GA32635@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:12379 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753430Ab1DTDaF (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 19 Apr 2011 23:30:05 -0400
Received: from int-mx09.intmail.prod.int.phx2.redhat.com (int-mx09.intmail.prod.int.phx2.redhat.com [10.5.11.22])
	by mx1.redhat.com (8.14.4/8.14.4) with ESMTP id p3K3U3sf022369
	(version=TLSv1/SSLv3 cipher=DHE-RSA-AES256-SHA bits=256 verify=OK)
	for <netdev@vger.kernel.org>; Tue, 19 Apr 2011 23:30:04 -0400
Received: from gelk.kernelslacker.org (ovpn-113-123.phx2.redhat.com [10.3.113.123])
	by int-mx09.intmail.prod.int.phx2.redhat.com (8.14.4/8.14.4) with ESMTP id p3K3U2DS022364
	(version=TLSv1/SSLv3 cipher=DHE-RSA-AES256-SHA bits=256 verify=NO)
	for <netdev@vger.kernel.org>; Tue, 19 Apr 2011 23:30:03 -0400
Received: from gelk.kernelslacker.org (gelk [127.0.0.1])
	by gelk.kernelslacker.org (8.14.4/8.14.4) with ESMTP id p3K3U18M000421
	for <netdev@vger.kernel.org>; Tue, 19 Apr 2011 23:30:01 -0400
Received: (from davej@localhost)
	by gelk.kernelslacker.org (8.14.4/8.14.4/Submit) id p3K3U1p6000420
	for netdev@vger.kernel.org; Tue, 19 Apr 2011 23:30:01 -0400
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

We can get here with a NULL socket argument passed from userspace,
so we need to handle it accordingly.

Signed-off-by: Dave Jones <davej@redhat.com>

diff --git a/net/can/bcm.c b/net/can/bcm.c
index 57b1aed..8a6a05e 100644
--- a/net/can/bcm.c
+++ b/net/can/bcm.c
@@ -1427,9 +1427,14 @@ static int bcm_init(struct sock *sk)
 static int bcm_release(struct socket *sock)
 {
 	struct sock *sk = sock->sk;
-	struct bcm_sock *bo = bcm_sk(sk);
+	struct bcm_sock *bo;
 	struct bcm_op *op, *next;
 
+	if (sk == NULL)
+		return 0;
+
+	bo = bcm_sk(sk);
+
 	/* remove bcm_ops, timer, rx_unregister(), etc. */
 
 	unregister_netdevice_notifier(&bo->notifier);
