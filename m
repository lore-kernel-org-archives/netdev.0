From: =?utf-8?q?Nicolas=20de=20Peslo=C3=BCan?=
	<nicolas.2p.debian@free.fr>
Subject: [PATCH netnext-2.6] bonding: change bond_create_proc_entry() to return void
Date: Sat, 10 Oct 2009 22:41:47 +0200
Message-ID: <1255207307-5976-1-git-send-email-nicolas.2p.debian@free.fr>
References: <b9df5fa10910091910u1b6bf14bg2781cb12c58b21f9@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: =?utf-8?q?Nicolas=20de=20Peslo=C3=BCan?=
	<nicolas.2p.debian@free.fr>
To: fubar@us.ibm.com, davem@davemloft.net, netdev@vger.kernel.org,
	bonding-devel@lists.sourceforge.net, rakib.mullick@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp6-g21.free.fr ([212.27.42.6]:58791 "EHLO smtp6-g21.free.fr"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S934798AbZJJUmo (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sat, 10 Oct 2009 16:42:44 -0400
In-Reply-To: <b9df5fa10910091910u1b6bf14bg2781cb12c58b21f9@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The function bond_create_proc_entry is currently of type int.

Two versions of this function exist:

The one in the ifdef CONFIG_PROC_FS branch always return 0.
The one in the else branch (which is empty) return nothing.

When CONFIG_PROC_FS is undef, this cause the following warning:

drivers/net/bonding/bond_main.c: In function `bond_create_proc_entry':
drivers/net/bonding/bond_main.c:3393: warning: control reaches end of
non-void function

No caller of this function use the returned value.

So change the returned type from int to void and remove the
useless return 0; .

Signed-off-by: Nicolas de Peslo=C3=BCan <nicolas.2p.debian@free.fr>
Reported-by: Rakib Mullick <rakib.mullick@gmail.com>
---
 drivers/net/bonding/bond_main.c |    6 ++----
 1 files changed, 2 insertions(+), 4 deletions(-)

diff --git a/drivers/net/bonding/bond_main.c b/drivers/net/bonding/bond=
_main.c
index ef6af1c..feb03ad 100644
--- a/drivers/net/bonding/bond_main.c
+++ b/drivers/net/bonding/bond_main.c
@@ -3375,7 +3375,7 @@ static const struct file_operations bond_info_fop=
s =3D {
 	.release =3D seq_release,
 };
=20
-static int bond_create_proc_entry(struct bonding *bond)
+static void bond_create_proc_entry(struct bonding *bond)
 {
 	struct net_device *bond_dev =3D bond->dev;
=20
@@ -3390,8 +3390,6 @@ static int bond_create_proc_entry(struct bonding =
*bond)
 		else
 			memcpy(bond->proc_file_name, bond_dev->name, IFNAMSIZ);
 	}
-
-	return 0;
 }
=20
 static void bond_remove_proc_entry(struct bonding *bond)
@@ -3430,7 +3428,7 @@ static void bond_destroy_proc_dir(void)
=20
 #else /* !CONFIG_PROC_FS */
=20
-static int bond_create_proc_entry(struct bonding *bond)
+static void bond_create_proc_entry(struct bonding *bond)
 {
 }
=20
--=20
1.6.3.3

