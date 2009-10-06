From: Stephen Boyd <bebarino@gmail.com>
Subject: [PATCH] connector: Fix incompatible pointer type warning
Date: Tue,  6 Oct 2009 01:23:37 -0700
Message-ID: <1254817417-16157-1-git-send-email-bebarino@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: linux-kernel@vger.kernel.org, Evgeniy Polyakov <zbr@ioremap.net>,
	Philipp Reisner <philipp.reisner@linbit.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from qw-out-2122.google.com ([74.125.92.25]:18214 "EHLO
	qw-out-2122.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755317AbZJFIWj (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 6 Oct 2009 04:22:39 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Commit 7069331 (connector: Provide the sender's credentials to the
callback, 2009-10-02) changed callbacks to take two arguments but misse=
d
this one.

drivers/connector/cn_proc.c: In function =E2=80=98cn_proc_init=E2=80=99=
:
drivers/connector/cn_proc.c:263: warning: passing argument 3 of
=E2=80=98cn_add_callback=E2=80=99 from incompatible pointer type

Signed-off-by: Stephen Boyd <bebarino@gmail.com>
---
 drivers/connector/cn_proc.c |    3 ++-
 1 files changed, 2 insertions(+), 1 deletions(-)

diff --git a/drivers/connector/cn_proc.c b/drivers/connector/cn_proc.c
index abf4a25..6069790 100644
--- a/drivers/connector/cn_proc.c
+++ b/drivers/connector/cn_proc.c
@@ -227,7 +227,8 @@ static void cn_proc_ack(int err, int rcvd_seq, int =
rcvd_ack)
  * cn_proc_mcast_ctl
  * @data: message sent from userspace via the connector
  */
-static void cn_proc_mcast_ctl(struct cn_msg *msg)
+static void cn_proc_mcast_ctl(struct cn_msg *msg,
+			      struct netlink_skb_parms *nsp)
 {
 	enum proc_cn_mcast_op *mc_op =3D NULL;
 	int err =3D 0;
--=20
1.6.5.rc1.44.ga1675

