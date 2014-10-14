From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [net] genl_magic: Resolve logical-op warnings
Date: Tue, 14 Oct 2014 06:28:38 -0700
Message-ID: <1413293318-9070-1-git-send-email-jeffrey.t.kirsher@intel.com>
Cc: Mark Rustad <mark.d.rustad@intel.com>,
	linux-kernel@vger.kernel.org, johannes.berg@intel.com,
	netdev@vger.kernel.org, Jeff Kirsher <jeffrey.t.kirsher@intel.com>
To: davem@davemloft.net
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Mark Rustad <mark.d.rustad@intel.com>

Resolve "logical 'and' applied to non-boolean constant" warnings"
that appear in W=2 builds by adding !! to a bit test.

Signed-off-by: Mark Rustad <mark.d.rustad@intel.com>
Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
---
 include/linux/genl_magic_func.h | 4 ++--
 1 file changed, 2 insertions(+), 2 deletions(-)

diff --git a/include/linux/genl_magic_func.h b/include/linux/genl_magic_func.h
index c0894dd..667c311 100644
--- a/include/linux/genl_magic_func.h
+++ b/include/linux/genl_magic_func.h
@@ -178,12 +178,12 @@ static int s_name ## _from_attrs_for_change(struct s_name *s,		\
 #define __assign(attr_nr, attr_flag, name, nla_type, type, assignment...)	\
 		nla = ntb[attr_nr];						\
 		if (nla) {						\
-			if (exclude_invariants && ((attr_flag) & DRBD_F_INVARIANT)) {		\
+			if (exclude_invariants && !!((attr_flag) & DRBD_F_INVARIANT)) {		\
 				pr_info("<< must not change invariant attr: %s\n", #name);	\
 				return -EEXIST;				\
 			}						\
 			assignment;					\
-		} else if (exclude_invariants && ((attr_flag) & DRBD_F_INVARIANT)) {		\
+		} else if (exclude_invariants && !!((attr_flag) & DRBD_F_INVARIANT)) {		\
 			/* attribute missing from payload, */		\
 			/* which was expected */			\
 		} else if ((attr_flag) & DRBD_F_REQUIRED) {		\
-- 
1.9.3
