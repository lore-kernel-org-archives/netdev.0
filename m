From: =?UTF-8?q?Manuel=20Sch=C3=B6lling?= <manuel.schoelling@gmx.de>
Subject: [PATCH] dns_resolver: Do not accept domain names longer than 255 chars
Date: Sat, 31 May 2014 18:44:33 +0200
Message-ID: <1401554673-16311-1-git-send-email-manuel.schoelling@gmx.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: jeffrey.t.kirsher@intel.com, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org,
	=?UTF-8?q?Manuel=20Sch=C3=B6lling?= <manuel.schoelling@gmx.de>
To: davem@davemloft.net
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

According to RFC1035 "[...] the total length of a domain name (i.e.,
label octets and label length octets) is restricted to 255 octets or
less."

Signed-off-by: Manuel Sch=C3=B6lling <manuel.schoelling@gmx.de>
---
 net/dns_resolver/dns_query.c |    2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/net/dns_resolver/dns_query.c b/net/dns_resolver/dns_query.=
c
index e7b6d53..e0fde29 100644
--- a/net/dns_resolver/dns_query.c
+++ b/net/dns_resolver/dns_query.c
@@ -94,7 +94,7 @@ int dns_query(const char *type, const char *name, siz=
e_t namelen,
=20
 	if (!namelen)
 		namelen =3D strlen(name);
-	if (namelen < 3)
+	if (namelen < 3 || namelen > 255)
 		return -EINVAL;
 	desclen +=3D namelen + 1;
=20
--=20
1.7.10.4
