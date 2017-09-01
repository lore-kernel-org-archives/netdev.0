From: Michal Kubecek <mkubecek@suse.cz>
Subject: [PATCH iproute2 2/2] iplink: double the buffer size also in
 iplink_get()
Date: Fri,  1 Sep 2017 18:39:16 +0200 (CEST)
Message-ID: <a9d6a8d91f9b17690be6d1270f0db3def0574999.1504283683.git.mkubecek@suse.cz>
References: <cover.1504283683.git.mkubecek@suse.cz>
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org
To: Stephen Hemminger <stephen@networkplumber.org>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <cover.1504283683.git.mkubecek@suse.cz>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Commit 72b365e8e0fd ("libnetlink: Double the dump buffer size") increased
the buffer size for "ip link show" command to 32 KB to handle NICs with
large number of VFs. With "dev" filter, a different code path is taken and
iplink_get() still uses only 16 KB buffer.

The size of 32768 is not very future-proof as NICs supporting 120-128 VFs
are already in use so that single RTM_NEWLINK message in the dump can
exceed 30000 bytes. But it's what rtnl_talk() and rtnl_dump_filter_l() use
so let's be consistent. Once this proves insufficient, all three sizes
should be increased.

Signed-off-by: Michal Kubecek <mkubecek@suse.cz>
---
 ip/iplink.c | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/ip/iplink.c b/ip/iplink.c
index 790e3a138bb0..72c347932068 100644
--- a/ip/iplink.c
+++ b/ip/iplink.c
@@ -1024,7 +1024,7 @@ int iplink_get(unsigned int flags, char *name, __u32 filt_mask)
 	};
 	struct {
 		struct nlmsghdr n;
-		char buf[16384];
+		char buf[32768];
 	} answer;
 
 	if (name) {
-- 
2.14.1
