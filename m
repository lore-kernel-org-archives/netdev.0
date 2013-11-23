From: Geert Uytterhoeven <geert@linux-m68k.org>
Subject: [PATCH] genetlink: Fix uninitialized variable in genl_validate_assign_mc_groups()
Date: Sat, 23 Nov 2013 13:01:50 +0100
Message-ID: <1385208110-17120-1-git-send-email-geert@linux-m68k.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	Geert Uytterhoeven <geert@linux-m68k.org>
To: "David S. Miller" <davem@davemloft.net>,
	Johannes Berg <johannes.berg@intel.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

net/netlink/genetlink.c: In function =E2=80=98genl_validate_assign_mc_g=
roups=E2=80=99:
net/netlink/genetlink.c:217: warning: =E2=80=98err=E2=80=99 may be used=
 uninitialized in this
function

Commit 2a94fe48f32ccf7321450a2cc07f2b724a444e5b ("genetlink: make multi=
cast
groups const, prevent abuse") split genl_register_mc_group() in multipl=
e
functions, but dropped the initialization of err.

Initialize err to zero to fix this.

Signed-off-by: Geert Uytterhoeven <geert@linux-m68k.org>
---
Question: Is the for_each_net_rcu() loop in genl_validate_assign_mc_gro=
ups()
          guaranteed to loop at least once?
	  If yes, this is a false positive.

 net/netlink/genetlink.c |    2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/net/netlink/genetlink.c b/net/netlink/genetlink.c
index 4518a57aa5fe..803206e82450 100644
--- a/net/netlink/genetlink.c
+++ b/net/netlink/genetlink.c
@@ -214,7 +214,7 @@ static int genl_validate_assign_mc_groups(struct ge=
nl_family *family)
 {
 	int first_id;
 	int n_groups =3D family->n_mcgrps;
-	int err, i;
+	int err =3D 0, i;
 	bool groups_allocated =3D false;
=20
 	if (!n_groups)
--=20
1.7.9.5
