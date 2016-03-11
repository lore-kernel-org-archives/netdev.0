From: David Decotigny <ddecotig@gmail.com>
Subject: [ethtool PATCH v4 06/11] test-common.c: fix test_realloc(NULL, ...)
Date: Fri, 11 Mar 2016 09:58:19 -0800
Message-ID: <1457719104-39188-7-git-send-email-ddecotig@gmail.com>
References: <1457719104-39188-1-git-send-email-ddecotig@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Jeff Garzik <jgarzik@pobox.com>,
	Ben Hutchings <ben@decadent.org.uk>,
	David Miller <davem@redhat.com>,
	Vidya Sagar Ravipati <vidya@cumulusnetworks.com>,
	Joe Perches <joe@perches.com>,
	=?UTF-8?q?Maciej=20=C5=BBenczykowski?= <maze@google.com>,
	David Decotigny <decot@googlers.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f68.google.com ([209.85.220.68]:34497 "EHLO
	mail-pa0-f68.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750912AbcCKR6l (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 11 Mar 2016 12:58:41 -0500
Received: by mail-pa0-f68.google.com with SMTP id hj7so9037628pac.1
        for <netdev@vger.kernel.org>; Fri, 11 Mar 2016 09:58:41 -0800 (PST)
In-Reply-To: <1457719104-39188-1-git-send-email-ddecotig@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

=46rom: Maciej =C5=BBenczykowski <maze@google.com>

This fixes:
  test-common.c: In function 'test_realloc':
  test-common.c:109:8: error: 'block' may be used uninitialized in this=
 function [-Werror=3Dmaybe-uninitialized]
    block =3D realloc(block, sizeof(*block) + size);
          ^


Signed-off-by: Maciej =C5=BBenczykowski <maze@google.com>
Signed-off-by: David Decotigny <decot@googlers.com>
---
 test-common.c | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/test-common.c b/test-common.c
index adc3cd4..cd63d1d 100644
--- a/test-common.c
+++ b/test-common.c
@@ -100,7 +100,7 @@ void test_free(void *ptr)
=20
 void *test_realloc(void *ptr, size_t size)
 {
-	struct list_head *block;
+	struct list_head *block =3D NULL;
=20
 	if (ptr) {
 		block =3D (struct list_head *)ptr - 1;
--=20
2.7.0.rc3.207.g0ac5344
