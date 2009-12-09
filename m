From: Anton Vorontsov <avorontsov@ru.mvista.com>
Subject: [PATCH] gianfar: Fix build with CONFIG_NET_POLL_CONTROLLER=y
Date: Wed, 9 Dec 2009 13:44:27 +0300
Message-ID: <20091209104427.GA25526@oksana.dev.rtsoft.ru>
References: <1260341804.16132.22.camel@pasglop>
Reply-To: avorontsov@ru.mvista.com
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Kumar Gala <galak@kernel.crashing.org>,
	linuxppc-dev <linuxppc-dev@lists.ozlabs.org>,
	David Miller <davem@davemloft.net>, netdev@vger.kernel.org,
	Sandeep Gopalpet <Sandeep.Kumar@freescale.com>
To: Benjamin Herrenschmidt <benh@kernel.crashing.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from imap.ru.mvista.com ([213.79.90.228]:50194 "EHLO
	buildserver.ru.mvista.com" rhost-flags-OK-FAIL-OK-FAIL)
	by vger.kernel.org with ESMTP id S1754155AbZLIKoV (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 9 Dec 2009 05:44:21 -0500
Content-Disposition: inline
In-Reply-To: <1260341804.16132.22.camel@pasglop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

commit 46ceb60ca80fa07703bc6eb8f4651f900dff5a82 ("gianfar: Add
Multiple group Support") introduced the following build error
with CONFIG_NET_POLL_CONTROLLER=3Dy:

  CC      ggianfar.o
ggianfar.c: In function 'gfar_netpoll':
ggianfar.c:2653: error: invalid storage class for function 'gfar_interr=
upt'
ggianfar.c:2652: warning: ISO C90 forbids mixed declarations and code
ggianfar.c:2681: error: invalid storage class for function 'adjust_link=
'
ggianfar.c:2764: error: invalid storage class for function 'gfar_set_mu=
lti'
ggianfar.c:2855: error: invalid storage class for function 'gfar_clear_=
exact_match'
ggianfar.c:2877: error: invalid storage class for function 'gfar_set_ha=
sh_for_addr'
ggianfar.c:2898: error: invalid storage class for function 'gfar_set_ma=
c_for_addr'
ggianfar.c:2922: error: invalid storage class for function 'gfar_error'
ggianfar.c:3020: warning: ISO C90 forbids mixed declarations and code
ggianfar.c:3032: error: invalid storage class for function 'gfar_init'
ggianfar.c:3037: error: invalid storage class for function 'gfar_exit'
ggianfar.c:3041: error: initializer element is not constant
ggianfar.c:3042: error: initializer element is not constant
ggianfar.c:3042: warning: ISO C90 forbids mixed declarations and code
ggianfar.c:3042: error: expected declaration or statement at end of inp=
ut
make[1]: *** [ggianfar.o] Error 1

This patch fixes the issue.

Reported-by: Benjamin Herrenschmidt <benh@kernel.crashing.org>
Signed-off-by: Anton Vorontsov <avorontsov@ru.mvista.com>
---

On Wed, Dec 09, 2009 at 05:56:44PM +1100, Benjamin Herrenschmidt wrote:
> In my next (not pushed out yet as I'm writing this but will be by the
> time you read it hopefully), I get a build failure:
>=20
> /home/benh/linux-powerpc-test/drivers/net/gianfar.c: In function =E2=80=
=98gfar_netpoll=E2=80=99:
> /home/benh/linux-powerpc-test/drivers/net/gianfar.c:2653: error: inva=
lid storage class for function =E2=80=98gfar_interrupt=E2=80=99
[...]
> make[3]: *** [drivers/net/gianfar.o] Error 1
>=20
> Stephen says that breakage has been in -next for some time...
>=20
> Can you guys sort it out ?

 drivers/net/gianfar.c |    1 +
 1 files changed, 1 insertions(+), 0 deletions(-)

diff --git a/drivers/net/gianfar.c b/drivers/net/gianfar.c
index 16def13..6850dc0 100644
--- a/drivers/net/gianfar.c
+++ b/drivers/net/gianfar.c
@@ -2644,6 +2644,7 @@ static void gfar_netpoll(struct net_device *dev)
 			gfar_interrupt(priv->gfargrp[i].interruptTransmit,
 						&priv->gfargrp[i]);
 			enable_irq(priv->gfargrp[i].interruptTransmit);
+		}
 	}
 }
 #endif
--=20
1.6.3.3

