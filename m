From: Prarit Bhargava <prarit@redhat.com>
Subject: [PATCH]: niu: fix uninitialized variable warning
Date: Thu, 27 May 2010 14:35:03 -0400
Message-ID: <20100527183100.24251.12228.sendpatchset@prarit.bos.redhat.com>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=ISO-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Prarit Bhargava <prarit@redhat.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:25872 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754941Ab0E0SfF (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 27 May 2010 14:35:05 -0400
Received: from int-mx05.intmail.prod.int.phx2.redhat.com (int-mx05.intmail.prod.int.phx2.redhat.com [10.5.11.18])
	by mx1.redhat.com (8.13.8/8.13.8) with ESMTP id o4RIZ4Nv024701
	(version=TLSv1/SSLv3 cipher=DHE-RSA-AES256-SHA bits=256 verify=OK)
	for <netdev@vger.kernel.org>; Thu, 27 May 2010 14:35:04 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

=46ixes warning:

drivers/net/niu.c: In function =E2=80=98niu_process_rx_pkt=E2=80=99:
drivers/net/niu.c:3457: error: =E2=80=98link=E2=80=99 may be used unini=
tialized in this function

Signed-off-by: Prarit Bhargava <prarit@redhat.com>

diff --git a/drivers/net/niu.c b/drivers/net/niu.c
index 30abb4e..3ace57b 100644
--- a/drivers/net/niu.c
+++ b/drivers/net/niu.c
@@ -3454,7 +3454,7 @@ static int niu_process_rx_pkt(struct napi_struct =
*napi, struct niu *np,
=20
 	num_rcr =3D 0;
 	while (1) {
-		struct page *page, **link;
+		struct page *page, **uninitialized_var(link);
 		u32 rcr_size, append_size;
 		u64 addr, val, off;
=20
