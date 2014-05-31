From: =?UTF-8?q?Manuel=20Sch=C3=B6lling?= <manuel.schoelling@gmx.de>
Subject: [PATCH v2] dns_resolver: Do not accept domain names longer than 255 chars
Date: Sat, 31 May 2014 23:37:40 +0200
Message-ID: <1401572260-18973-1-git-send-email-manuel.schoelling@gmx.de>
References: <1401554673-16311-1-git-send-email-manuel.schoelling@gmx.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: jeffrey.t.kirsher@intel.com, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org,
	=?UTF-8?q?Manuel=20Sch=C3=B6lling?= <manuel.schoelling@gmx.de>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mout.gmx.net ([212.227.15.18]:54795 "EHLO mout.gmx.net"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752202AbaEaVhs (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sat, 31 May 2014 17:37:48 -0400
In-Reply-To: <1401554673-16311-1-git-send-email-manuel.schoelling@gmx.de>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

According to RFC1035 "[...] the total length of a domain name (i.e.,
label octets and label length octets) is restricted to 255 octets or
less."

Signed-off-by: Manuel Sch=C3=B6lling <manuel.schoelling@gmx.de>
---
 net/dns_resolver/dns_query.c |    4 ++--
 1 file changed, 2 insertions(+), 2 deletions(-)

diff --git a/net/dns_resolver/dns_query.c b/net/dns_resolver/dns_query.=
c
index e7b6d53..5b49958 100644
--- a/net/dns_resolver/dns_query.c
+++ b/net/dns_resolver/dns_query.c
@@ -93,8 +93,8 @@ int dns_query(const char *type, const char *name, siz=
e_t namelen,
 	}
=20
 	if (!namelen)
-		namelen =3D strlen(name);
-	if (namelen < 3)
+		namelen =3D strnlen(name, 256);
+	if (namelen < 3 || namelen > 255)
 		return -EINVAL;
 	desclen +=3D namelen + 1;
=20
--=20
1.7.10.4
