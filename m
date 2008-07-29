From: Andreas Schwab <schwab@suse.de>
Subject: Fix error checking in niu driver
Date: Tue, 29 Jul 2008 20:58:14 +0200
Message-ID: <jefxps8qm1.fsf@sykes.suse.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from ns1.suse.de ([195.135.220.2]:53938 "EHLO mx1.suse.de"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751035AbYG2S6P (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 29 Jul 2008 14:58:15 -0400
Received: from Relay1.suse.de (mail2.suse.de [195.135.221.8])
	(using TLSv1 with cipher DHE-RSA-AES256-SHA (256/256 bits))
	(No client certificate requested)
	by mx1.suse.de (Postfix) with ESMTP id 8EF9941A87
	for <netdev@vger.kernel.org>; Tue, 29 Jul 2008 20:58:14 +0200 (CEST)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The callers of niu_ethflow_to_class expect zero as error, but it return=
s
-1 instead.

Signed-off-by: Andreas Schwab <schwab@suse.de>
---

diff --git a/drivers/net/niu.c b/drivers/net/niu.c
index 8ee7d7b..e4765b7 100644
--- a/drivers/net/niu.c
+++ b/drivers/net/niu.c
@@ -6417,7 +6417,7 @@ static int niu_ethflow_to_class(int flow_type, u6=
4 *class)
 		*class =3D CLASS_CODE_SCTP_IPV6;
 		break;
 	default:
-		return -1;
+		return 0;
 	}
=20
 	return 1;

--=20
Andreas Schwab, SuSE Labs, schwab@suse.de
SuSE Linux Products GmbH, Maxfeldstra=DFe 5, 90409 N=FCrnberg, Germany
PGP key fingerprint =3D 58CA 54C7 6D53 942B 1756  01D3 44D5 214B 8276 4=
ED5
"And now for something completely different."
