From: Cong Wang <xiyou.wangcong@gmail.com>
Subject: [Patch net-next] net: revert "sched classifier: make cgroup table local"
Date: Thu,  2 Jan 2014 14:58:41 -0800
Message-ID: <1388703521-5535-1-git-send-email-xiyou.wangcong@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Cong Wang <xiyou.wangcong@gmail.com>,
	Stephen Hemminger <stephen@networkplumber.org>,
	"David S. Miller" <davem@davemloft.net>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pb0-f51.google.com ([209.85.160.51]:36227 "EHLO
	mail-pb0-f51.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750782AbaABW6v (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 2 Jan 2014 17:58:51 -0500
Received: by mail-pb0-f51.google.com with SMTP id up15so14884833pbc.24
        for <netdev@vger.kernel.org>; Thu, 02 Jan 2014 14:58:51 -0800 (PST)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This reverts commit de6fb288b1246a5c4e00c0cdbfe3a838a360b3f4.
Otherwise we got:

net/sched/cls_cgroup.c:106:29: error: static declaration of =E2=80=98ne=
t_cls_subsys=E2=80=99 follows non-static declaration
 static struct cgroup_subsys net_cls_subsys =3D {
                             ^
In file included from include/linux/cgroup.h:654:0,
                 from net/sched/cls_cgroup.c:18:
include/linux/cgroup_subsys.h:35:29: note: previous declaration of =E2=80=
=98net_cls_subsys=E2=80=99 was here
 SUBSYS(net_cls)
                             ^
make[2]: *** [net/sched/cls_cgroup.o] Error 1

Cc: Stephen Hemminger <stephen@networkplumber.org>
Cc: David S. Miller <davem@davemloft.net>
Signed-off-by: Cong Wang <xiyou.wangcong@gmail.com>
---
 net/sched/cls_cgroup.c | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/net/sched/cls_cgroup.c b/net/sched/cls_cgroup.c
index 161a03e..f9d21258 100644
--- a/net/sched/cls_cgroup.c
+++ b/net/sched/cls_cgroup.c
@@ -103,7 +103,7 @@ static struct cftype ss_files[] =3D {
 	{ }	/* terminate */
 };
=20
-static struct cgroup_subsys net_cls_subsys =3D {
+struct cgroup_subsys net_cls_subsys =3D {
 	.name		=3D "net_cls",
 	.css_alloc	=3D cgrp_css_alloc,
 	.css_online	=3D cgrp_css_online,
--=20
1.8.3.1
