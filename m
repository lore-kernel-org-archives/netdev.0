From: Pravin B Shelar <pshelar@ovn.org>
Subject: [PATCH net-next] genetlink: Fix generic netlink family unregister
Date: Fri, 28 Oct 2016 16:01:41 -0700
Message-ID: <1477695701-1147-1-git-send-email-pshelar@ovn.org>
Cc: Pravin B Shelar <pshelar@ovn.org>,
        Johannes Berg <johannes@sipsolutions.net>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from relay5-d.mail.gandi.net ([217.70.183.197]:48917 "EHLO
        relay5-d.mail.gandi.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1753245AbcJ1XBv (ORCPT
        <rfc822;netdev@vger.kernel.org>); Fri, 28 Oct 2016 19:01:51 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This patch fixes a typo in unregister operation.

Following crash is fixed by this patch. It can be easily reproduced
by repeating modprobe and rmmod module that uses genetlink.

[  261.446686] BUG: unable to handle kernel paging request at ffffffffa0264088
[  261.448921] IP: [<ffffffff813cb70e>] strcmp+0xe/0x30
[  261.450494] PGD 1c09067
[  261.451266] PUD 1c0a063
[  261.452091] PMD 8068d5067
[  261.452525] PTE 0
[  261.453164]
[  261.453618] Oops: 0000 [#1] SMP
[  261.454577] Modules linked in: openvswitch(+) ...
[  261.480753] RIP: 0010:[<ffffffff813cb70e>]  [<ffffffff813cb70e>] strcmp+0xe/0x30
[  261.483069] RSP: 0018:ffffc90003c0bc28  EFLAGS: 00010282
[  261.510145] Call Trace:
[  261.510896]  [<ffffffff816f10ca>] genl_family_find_byname+0x5a/0x70
[  261.512819]  [<ffffffff816f2319>] genl_register_family+0xb9/0x630
[  261.514805]  [<ffffffffa02840bc>] dp_init+0xbc/0x120 [openvswitch]
[  261.518268]  [<ffffffff8100217d>] do_one_initcall+0x3d/0x160
[  261.525041]  [<ffffffff811808a9>] do_init_module+0x60/0x1f1
[  261.526754]  [<ffffffff8110687f>] load_module+0x22af/0x2860
[  261.530144]  [<ffffffff81107026>] SYSC_finit_module+0x96/0xd0
[  261.531901]  [<ffffffff8110707e>] SyS_finit_module+0xe/0x10
[  261.533605]  [<ffffffff8100391e>] do_syscall_64+0x6e/0x180
[  261.535284]  [<ffffffff817c2faf>] entry_SYSCALL64_slow_path+0x25/0x25
[  261.546512] RIP  [<ffffffff813cb70e>] strcmp+0xe/0x30
[  261.550198] ---[ end trace 76505a814dd68770 ]---

Fixes: 2ae0f17df1c ("genetlink: use idr to track families").

Reported-by: Jarno Rajahalme <jarno@ovn.org>
CC: Johannes Berg <johannes@sipsolutions.net>
Signed-off-by: Pravin B Shelar <pshelar@ovn.org>
---
 net/netlink/genetlink.c | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/net/netlink/genetlink.c b/net/netlink/genetlink.c
index df0cbcd..caf04d7 100644
--- a/net/netlink/genetlink.c
+++ b/net/netlink/genetlink.c
@@ -399,7 +399,7 @@ int genl_unregister_family(const struct genl_family *family)
 {
 	genl_lock_all();
 
-	if (genl_family_find_byid(family->id)) {
+	if (!genl_family_find_byid(family->id)) {
 		genl_unlock_all();
 		return -ENOENT;
 	}
-- 
1.9.1
