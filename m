From: David Decotigny <ddecotig@gmail.com>
Subject: [ethtool PATCH v4 06/11] test-common.c: fix test_realloc(NULL, ...)
Date: Mon,  7 Mar 2016 19:34:57 -0800
Message-ID: <1457408102-46662-7-git-send-email-ddecotig@gmail.com>
References: <1457408102-46662-1-git-send-email-ddecotig@gmail.com>
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
Received: from mail-pf0-f196.google.com ([209.85.192.196]:34699 "EHLO
	mail-pf0-f196.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753455AbcCHDfT (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 7 Mar 2016 22:35:19 -0500
Received: by mail-pf0-f196.google.com with SMTP id 184so353397pff.1
        for <netdev@vger.kernel.org>; Mon, 07 Mar 2016 19:35:19 -0800 (PST)
In-Reply-To: <1457408102-46662-1-git-send-email-ddecotig@gmail.com>
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
