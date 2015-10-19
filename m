From: Dan Carpenter <dan.carpenter@oracle.com>
Subject: [patch] irda: precedence bug in irlmp_seq_hb_idx()
Date: Mon, 19 Oct 2015 13:16:49 +0300
Message-ID: <20151019101649.GC26688@mwanda>
References: <----An------QYmAn$4202951b-482d-4d92-98c2-3466de737b40@alibaba-inc.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: "David S. Miller" <davem@davemloft.net>, netdev@vger.kernel.org,
	security@kernel.org, throber3 <throber3@gmail.com>,
	=?utf-8?B?56iL5ZCbKOaIkOa3vCk=?= <chengmiao.cj@alibaba-inc.com>
To: Samuel Ortiz <samuel@sortiz.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from userp1040.oracle.com ([156.151.31.81]:20134 "EHLO
	userp1040.oracle.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751424AbbJSKRh (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 19 Oct 2015 06:17:37 -0400
Content-Disposition: inline
In-Reply-To: <----An------QYmAn$4202951b-482d-4d92-98c2-3466de737b40@alibaba-inc.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This is decrementing the pointer, instead of the value stored in the
pointer.  KASan detects it as an out of bounds reference.

Reported-by: "Berry=C2=A0Cheng =E7=A8=8B=E5=90=9B(=E6=88=90=E6=B7=BC)" =
<chengmiao.cj@alibaba-inc.com>
Signed-off-by: Dan Carpenter <dan.carpenter@oracle.com>
---
This bug predates the start of git.  You would think it would have been
reported earlier since it looks like a serious bug.  I cannot test this
so please review carefully.

diff --git a/net/irda/irlmp.c b/net/irda/irlmp.c
index a26c401..4396459 100644
--- a/net/irda/irlmp.c
+++ b/net/irda/irlmp.c
@@ -1839,7 +1839,7 @@ static void *irlmp_seq_hb_idx(struct irlmp_iter_s=
tate *iter, loff_t *off)
 	for (element =3D hashbin_get_first(iter->hashbin);
 	     element !=3D NULL;
 	     element =3D hashbin_get_next(iter->hashbin)) {
-		if (!off || *off-- =3D=3D 0) {
+		if (!off || (*off)-- =3D=3D 0) {
 			/* NB: hashbin left locked */
 			return element;
 		}
