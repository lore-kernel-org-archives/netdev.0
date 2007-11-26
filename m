From: "=?ISO-8859-1?Q?Ilpo_J=E4rvinen?=" <ilpo.jarvinen@helsinki.fi>
Subject: [PATCH net-2.6.25] Fix pcounter build error without CONFIG_SMP
Date: Mon, 26 Nov 2007 16:35:38 +0200 (EET)
Message-ID: <Pine.LNX.4.64.0711261630020.18529@kivilampi-30.cs.helsinki.fi>
Mime-Version: 1.0
Content-Type: MULTIPART/MIXED; BOUNDARY="-696243703-1289721590-1196087738=:18529"
Cc: Netdev <netdev@vger.kernel.org>
To: Herbert Xu <herbert@gondor.apana.org.au>,
	Arnaldo Carvalho de Melo <acme@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from courier.cs.helsinki.fi ([128.214.9.1]:49947 "EHLO
	mail.cs.helsinki.fi" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753033AbXKZOfk (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 26 Nov 2007 09:35:40 -0500
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

  This message is in MIME format.  The first part should be readable text,
  while the remaining parts are likely unreadable without MIME-aware tools.

---696243703-1289721590-1196087738=:18529
Content-Type: TEXT/PLAIN; charset=ISO-8859-1
Content-Transfer-Encoding: 8BIT


I keep getting this build error and couldn't find anyone fixing
it in archives. ...Maybe all net developers except me build
just SMP kernels :-).

In file included from include/net/sock.h:50,
                 from ipc/mqueue.c:35:
include/linux/pcounter.h: In function 'pcounter_add':
include/linux/pcounter.h:87: error: 'struct pcounter' has no
member named 'value'
make[1]: *** [ipc/mqueue.o] Error 1
make: *** [ipc] Error 2

Signed-off-by: Ilpo Järvinen <ilpo.jarvinen@helsinki.fi>
---
 include/linux/pcounter.h |    2 +-
 1 files changed, 1 insertions(+), 1 deletions(-)

diff --git a/include/linux/pcounter.h b/include/linux/pcounter.h
index 620aade..9c4760a 100644
--- a/include/linux/pcounter.h
+++ b/include/linux/pcounter.h
@@ -84,7 +84,7 @@ static inline int pcounter_getval(const struct pcounter *self)
 
 static inline void pcounter_add(struct pcounter *self, int inc)
 {
-	self->value += inc;
+	self->val += inc;
 }
 
 static inline int pcounter_getval(const struct pcounter *self)
-- 
1.5.0.6

---696243703-1289721590-1196087738=:18529--
