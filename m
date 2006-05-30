From: Andreas Schwab <schwab@suse.de>
Subject: drivers/connector/cn_queue.c:130: warning: value computed is not used
Date: Tue, 30 May 2006 13:34:02 +0200
Message-ID: <jeac8zg311.fsf@sykes.suse.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Return-path: <netdev-owner@vger.kernel.org>
Received: from ns2.suse.de ([195.135.220.15]:26273 "EHLO mx2.suse.de")
	by vger.kernel.org with ESMTP id S1750871AbWE3LeE (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 30 May 2006 07:34:04 -0400
Received: from Relay1.suse.de (mail2.suse.de [195.135.221.8])
	(using TLSv1 with cipher DHE-RSA-AES256-SHA (256/256 bits))
	(No client certificate requested)
	by mx2.suse.de (Postfix) with ESMTP id 37CE91EBEF
	for <netdev@vger.kernel.org>; Tue, 30 May 2006 13:34:03 +0200 (CEST)
To: netdev@vger.kernel.org
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

There is no point in testing the atomic value if the result is thrown
away.

Signed-off-by: Andreas Schwab <schwab@suse.de>

diff --git a/drivers/connector/cn_queue.c b/drivers/connector/cn_queue.=
c
index 9f2f00d..05f8ce2 100644
--- a/drivers/connector/cn_queue.c
+++ b/drivers/connector/cn_queue.c
@@ -127,7 +127,7 @@ void cn_queue_del_callback(struct cn_que
=20
 	if (found) {
 		cn_queue_free_callback(cbq);
-		atomic_dec_and_test(&dev->refcnt);
+		atomic_dec(&dev->refcnt);
 	}
 }
=20

Andreas.

--=20
Andreas Schwab, SuSE Labs, schwab@suse.de
SuSE Linux Products GmbH, Maxfeldstra=DFe 5, 90409 N=FCrnberg, Germany
PGP key fingerprint =3D 58CA 54C7 6D53 942B 1756  01D3 44D5 214B 8276 4=
ED5
"And now for something completely different."
