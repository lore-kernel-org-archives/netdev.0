From: Adrian Bunk <bunk@kernel.org>
Subject: [2.6 patch] irnet_irda.c must #include <asm/unaligned.h>
Date: Wed, 14 May 2008 23:27:09 +0300
Message-ID: <20080514202709.GB21795@cs181133002.pp.htv.fi>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: linux-kernel@vger.kernel.org, netdev@vger.kernel.org
To: Graf Yang <graf.yang@analog.com>, Bryan Wu <cooloney@kernel.org>,
	"David S. Miller" <davem@davemloft.net>,
	Linus Torvalds <torvalds@linux-foundation.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp5.pp.htv.fi ([213.243.153.39]:38361 "EHLO smtp5.pp.htv.fi"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1750862AbYENU2s (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 14 May 2008 16:28:48 -0400
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This patch fixes the following compile error caused by
commit 332223831e86b2e17b48b4afafad07d8e3b73861
(irda: Fix a misalign access issue. (v2)):

<--  snip  -->

=2E..
  CC      net/irda/irnet/irnet_irda.o
/home/bunk/linux/kernel-2.6/git/linux-2.6/net/irda/irnet/irnet_irda.c: =
In function =E2=80=98irnet_discovery_indication=E2=80=99:
/home/bunk/linux/kernel-2.6/git/linux-2.6/net/irda/irnet/irnet_irda.c:1=
676: error: implicit declaration of function =E2=80=98get_unaligned=E2=80=
=99
make[4]: *** [net/irda/irnet/irnet_irda.o] Error 1

<--  snip  -->

Reported-by: Adrian Bunk <bunk@kernel.org>
Signed-off-by: Adrian Bunk <bunk@kernel.org>

---
41881ccc5581fe2e27ca15b942c9f79e28b45276 diff --git a/net/irda/irnet/ir=
net_irda.c b/net/irda/irnet/irnet_irda.c
index a3ec002..cf9a4b5 100644
--- a/net/irda/irnet/irnet_irda.c
+++ b/net/irda/irnet/irnet_irda.c
@@ -10,6 +10,7 @@
=20
 #include "irnet_irda.h"		/* Private header */
 #include <linux/seq_file.h>
+#include <asm/unaligned.h>
=20
 /*
  * PPP disconnect work: we need to make sure we're in

