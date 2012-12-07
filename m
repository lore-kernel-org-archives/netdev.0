From: Jan Synacek <jsynacek@redhat.com>
Subject: [PATCH 1/2] ninfod: Fix more unused variables.
Date: Fri,  7 Dec 2012 09:25:23 +0100
Message-ID: <1354868724-15549-2-git-send-email-jsynacek@redhat.com>
References: <1354868724-15549-1-git-send-email-jsynacek@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org, Jan Synacek <jsynacek@redhat.com>
To: yoshfuji@linux-ipv6.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:65412 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753926Ab2LGIZp (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 7 Dec 2012 03:25:45 -0500
In-Reply-To: <1354868724-15549-1-git-send-email-jsynacek@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

| ni_ifaddrs.c: In function =E2=80=98ni_ifaddrs=E2=80=99:
| ni_ifaddrs.c:389:14: warning: variable =E2=80=98nlm_scope=E2=80=99 se=
t but not used [-Wunused-but-set-variable]
| ni_ifaddrs.c:353:13: warning: variable =E2=80=98ifflist=E2=80=99 set =
but not used [-Wunused-but-set-variable]
| ni_ifaddrs.c:322:6: warning: variable =E2=80=98result=E2=80=99 set bu=
t not used [-Wunused-but-set-variable]

Signed-off-by: Jan Synacek <jsynacek@redhat.com>
---
 ninfod/ni_ifaddrs.c | 8 +-------
 1 file changed, 1 insertion(+), 7 deletions(-)

diff --git a/ninfod/ni_ifaddrs.c b/ninfod/ni_ifaddrs.c
index 4225a5a..0820497 100644
--- a/ninfod/ni_ifaddrs.c
+++ b/ninfod/ni_ifaddrs.c
@@ -319,7 +319,6 @@ int ni_ifaddrs(struct ni_ifaddrs **ifap, sa_family_=
t family)
=20
 	pid_t pid =3D getpid();
 	int seq =3D 0;
-	int result;
 	int build;		/* 0 or 1 */
=20
 /* ---------------------------------- */
@@ -350,7 +349,6 @@ int ni_ifaddrs(struct ni_ifaddrs **ifap, sa_family_=
t family)
 		struct ni_ifaddrs *ifl =3D NULL, *ifa =3D NULL;
 		struct nlmsghdr *nlh, *nlh0;
 		void *data =3D NULL, *xdata =3D NULL;
-		uint16_t *ifflist =3D NULL;
 #ifndef IFA_LOCAL
 		struct rtmaddr_ifamap ifamap;
 #endif
@@ -362,18 +360,15 @@ int ni_ifaddrs(struct ni_ifaddrs **ifap, sa_famil=
y_t family)
 				*ifap =3D ifa;
 			else {
 				free_data(data);
-				result =3D 0;
 				break;
 			}
 			if (data =3D=3D NULL) {
 				free_data(data);
-				result =3D -1;
 				break;
 			}
 			ifl =3D NULL;
 			data +=3D NLMSG_ALIGN(sizeof(struct ni_ifaddrs)) * icnt;
 			xdata =3D data + dlen;
-			ifflist =3D xdata + xlen;
 		}
=20
 		for (nlm =3D nlmsg_list; nlm; nlm =3D nlm->nlm_next) {
@@ -386,7 +381,7 @@ int ni_ifaddrs(struct ni_ifaddrs **ifap, sa_family_=
t family)
=20
 				size_t nlm_struct_size =3D 0;
 				sa_family_t nlm_family =3D 0;
-				uint32_t nlm_scope =3D 0, nlm_index =3D 0;
+				uint32_t nlm_index =3D 0;
 				unsigned int nlm_flags;
 				size_t rtasize;
=20
@@ -405,7 +400,6 @@ int ni_ifaddrs(struct ni_ifaddrs **ifap, sa_family_=
t family)
 					ifam =3D (struct ifaddrmsg *) NLMSG_DATA(nlh);
 					nlm_struct_size =3D sizeof(*ifam);
 					nlm_family =3D ifam->ifa_family;
-					nlm_scope =3D ifam->ifa_scope;
 					nlm_index =3D ifam->ifa_index;
 					nlm_flags =3D ifam->ifa_flags;
 					if (family && nlm_family !=3D family)
--=20
1.8.0.1
