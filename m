From: Jaswinder Singh Rajput <jaswinder@kernel.org>
Subject: [PATCH] ppp: ppp_generic.c initialize flen before it get used
Date: Sat, 12 Sep 2009 22:11:31 +0530
Message-ID: <1252773691.3687.5.camel@ht.satnam>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
To: David Miller <davem@davemloft.net>,
	Gabriele Paoloni <gabriele.paoloni@intel.com>,
	Paul Mackerras <paulus@samba.org>, linux-ppp@vger.kernel.org,
	netdev <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from hera.kernel.org ([140.211.167.34]:53512 "EHLO hera.kernel.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754836AbZILQlf (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sat, 12 Sep 2009 12:41:35 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


When while loop runs first time flen is used uninitialized for nfree <=3D=
 0

This also fixed compilation warning :
  CC [M]  drivers/net/ppp_generic.o
drivers/net/ppp_generic.c: In function =E2=80=98ppp_mp_explode=E2=80=99=
:
drivers/net/ppp_generic.c:1314: warning: =E2=80=98flen=E2=80=99 may be =
used uninitialized in this function

Signed-off-by: Jaswinder Singh Rajput <jaswinderrajput@gmail.com>
---
 drivers/net/ppp_generic.c |    2 +-
 1 files changed, 1 insertions(+), 1 deletions(-)

diff --git a/drivers/net/ppp_generic.c b/drivers/net/ppp_generic.c
index cd37d73..b1a1a06 100644
--- a/drivers/net/ppp_generic.c
+++ b/drivers/net/ppp_generic.c
@@ -1311,7 +1311,7 @@ static int ppp_mp_explode(struct ppp *ppp, struct=
 sk_buff *skb)
 {
 	int	len, totlen;
 	int	i, bits, hdrlen, mtu;
-	int	flen;
+	int	flen =3D 0;
 	int	navail,	nfree, nzero;
 	int	nbigger;
 	int	totspeed;
--=20
1.6.4.2


