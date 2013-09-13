From: Prarit Bhargava <prarit@redhat.com>
Subject: [PATCH] net, mellanox mlx4 Fix compile warnings
Date: Fri, 13 Sep 2013 08:30:38 -0400
Message-ID: <1379075438-20240-1-git-send-email-prarit@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Prarit Bhargava <prarit@redhat.com>, dledford@redhat.com,
	Amir Vadai <amirv@mellanox.com>,
	Or Gerlitz <ogerlitz@mellanox.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:32543 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751904Ab3IMMaq (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 13 Sep 2013 08:30:46 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

=46ix unitialized variable warnings.

drivers/net/ethernet/mellanox/mlx4/resource_tracker.c: In function =E2=80=
=98mlx4_HW2SW_CQ_wrapper=E2=80=99:
drivers/net/ethernet/mellanox/mlx4/resource_tracker.c:2551:16: error: =E2=
=80=98cq=E2=80=99 may be used uninitialized in this function [-Werror=3D=
maybe-uninitialized]
  atomic_dec(&cq->mtt->ref_count);
                ^
drivers/net/ethernet/mellanox/mlx4/resource_tracker.c: In function =E2=80=
=98mlx4_HW2SW_SRQ_wrapper=E2=80=99:
drivers/net/ethernet/mellanox/mlx4/resource_tracker.c:2734:17: error: =E2=
=80=98srq=E2=80=99 may be used uninitialized in this function [-Werror=3D=
maybe-uninitialized]
  atomic_dec(&srq->mtt->ref_count);

Signed-off-by: Prarit Bhargava <prarit@redhat.com>
Cc: dledford@redhat.com
Cc: Amir Vadai <amirv@mellanox.com>
Cc: Or Gerlitz <ogerlitz@mellanox.com>
---
 .../net/ethernet/mellanox/mlx4/resource_tracker.c  |    4 ++--
 1 file changed, 2 insertions(+), 2 deletions(-)

diff --git a/drivers/net/ethernet/mellanox/mlx4/resource_tracker.c b/dr=
ivers/net/ethernet/mellanox/mlx4/resource_tracker.c
index dd68763..d703838 100644
--- a/drivers/net/ethernet/mellanox/mlx4/resource_tracker.c
+++ b/drivers/net/ethernet/mellanox/mlx4/resource_tracker.c
@@ -2563,7 +2563,7 @@ int mlx4_HW2SW_CQ_wrapper(struct mlx4_dev *dev, i=
nt slave,
 {
 	int err;
 	int cqn =3D vhcr->in_modifier;
-	struct res_cq *cq;
+	struct res_cq *uninitialized_var(cq);
=20
 	err =3D cq_res_start_move_to(dev, slave, cqn, RES_CQ_ALLOCATED, &cq);
 	if (err)
@@ -2746,7 +2746,7 @@ int mlx4_HW2SW_SRQ_wrapper(struct mlx4_dev *dev, =
int slave,
 {
 	int err;
 	int srqn =3D vhcr->in_modifier;
-	struct res_srq *srq;
+	struct res_srq *uninitialized_var(srq);
=20
 	err =3D srq_res_start_move_to(dev, slave, srqn, RES_SRQ_ALLOCATED, &s=
rq);
 	if (err)
--=20
1.7.9.3
