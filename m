From: Matti Vaittinen <matti.vaittinen@nokia.com>
Subject: [PATCH v2 1/1] net: netlink: Fix multicast group storage allocation
 for families with more than one groups
Date: Wed, 13 Jan 2016 09:54:12 +0200
Message-ID: <20160113075400.GA12580@fi-ourus-dhcp00977.emea.nsn-net.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	Sverdlin Alexander <alexander.sverdlin@nokia.com>,
	Pennanen Teppo Olavi <teppo.o.pennanen@nokia.com>
To: "David S. Miller" <davem@davemloft.net>,
	Johannes Berg <johannes.berg@intel.com>,
	Jiri Benc <jbenc@redhat.com>,
	Matti Vaittinen <matti.vaittinen@nokia.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hello again,

      Second version, Fixed the 'off by one' bug spotted by David.

      Br.
        Matti Vaittinen

Multicast groups are stored in global buffer. Check for needed buffer size
incorrectly compares buffer size to first id for family. This means that
for families with more than one mcast id one may allocate too small buffer
and end up writing rest of the groups to some unallocated memory. Fix the
buffer size check to compare allocated space to last mcast id for the
family.

Tested on ARM using kernel 3.14

Signed-off-by: Matti Vaittinen <matti.vaittinen@nokia.com>
---
 net/netlink/genetlink.c | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/net/netlink/genetlink.c b/net/netlink/genetlink.c
index bc0e504..5e113ba 100644
--- a/net/netlink/genetlink.c
+++ b/net/netlink/genetlink.c
@@ -185,7 +185,7 @@ static int genl_allocate_reserve_groups(int n_groups, int *first_id)
 			}
 		}
 
-		if (id >= mc_groups_longs * BITS_PER_LONG) {
+		if (id + n_groups > mc_groups_longs * BITS_PER_LONG) {
 			unsigned long new_longs = mc_groups_longs +
 						  BITS_TO_LONGS(n_groups);
 			size_t nlen = new_longs * sizeof(unsigned long);
-- 
2.1.0
