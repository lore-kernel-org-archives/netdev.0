From: "Justin P. Mattock" <justinmattock@gmail.com>
Subject: [PATCH]net:8021q:vlan.c Fix pr_info to read on line in the syslog.
Date: Mon, 23 May 2011 09:04:58 -0700
Message-ID: <1306166698-2036-1-git-send-email-justinmattock@gmail.com>
Cc: davem@davemloft.net, linux-kernel@vger.kernel.org,
	"Justin P. Mattock" <justinmattock@gmail.com>
To: netdev@vger.kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

The patch below changes the pr_info so that it reads on one line in the syslog
rather than two.

before:

[   30.438203] 802.1Q VLAN Support v1.8 Ben Greear <greearb@candelatech.com>
[   30.441542] All bugs added by David S. Miller <davem@redhat.com>


after:
[   29.356282] 802.1Q VLAN Support v1.8 Ben Greear <greearb@candelatech.com> All bugs added by: David S. Miller <davem@redhat.com>

Signed-off-by: Justin P. Mattock <justinmattock@gmail.com>

---
 net/8021q/vlan.c |    4 ++--
 1 files changed, 2 insertions(+), 2 deletions(-)

diff --git a/net/8021q/vlan.c b/net/8021q/vlan.c
index b2274d1..02f4d8b 100644
--- a/net/8021q/vlan.c
+++ b/net/8021q/vlan.c
@@ -673,8 +673,8 @@ static int __init vlan_proto_init(void)
 {
 	int err;
 
-	pr_info("%s v%s %s\n", vlan_fullname, vlan_version, vlan_copyright);
-	pr_info("All bugs added by %s\n", vlan_buggyright);
+	pr_info("%s v%s %s All bugs added by: %s\n", vlan_fullname, vlan_version, 
+		vlan_copyright, vlan_buggyright);
 
 	err = register_pernet_subsys(&vlan_net_ops);
 	if (err < 0)
-- 
1.7.5.1
