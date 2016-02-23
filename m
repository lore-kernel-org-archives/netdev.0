From: Sudip Mukherjee <sudipm.mukherjee@gmail.com>
Subject: [PATCH] netfilter: xt_osf: remove unused variable
Date: Tue, 23 Feb 2016 13:40:10 +0530
Message-ID: <1456215010-14878-1-git-send-email-sudipm.mukherjee@gmail.com>
Cc: linux-kernel@vger.kernel.org, netfilter-devel@vger.kernel.org,
	coreteam@netfilter.org, netdev@vger.kernel.org,
	Sudip Mukherjee <sudipm.mukherjee@gmail.com>
To: Pablo Neira Ayuso <pablo@netfilter.org>,
	Patrick McHardy <kaber@trash.net>,
	Jozsef Kadlecsik <kadlec@blackhole.kfki.hu>,
	"David S. Miller" <davem@davemloft.net>
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

While building with W=1 we got the warning:
net/netfilter/xt_osf.c:265:9: warning: variable 'loop_cont' set but not used

The local variable loop_cont was only initialized and then assigned a
value but was never used or checked after that.
While removing the variable, the case of OSFOPT_TS was not removed so
that it will serve as a reminder to us that we can do something in that
particular case.

Signed-off-by: Sudip Mukherjee <sudip.mukherjee@codethink.co.uk>
---
 net/netfilter/xt_osf.c | 2 --
 1 file changed, 2 deletions(-)

diff --git a/net/netfilter/xt_osf.c b/net/netfilter/xt_osf.c
index 4e3c3af..2455b69 100644
--- a/net/netfilter/xt_osf.c
+++ b/net/netfilter/xt_osf.c
@@ -262,7 +262,6 @@ xt_osf_match_packet(const struct sk_buff *skb, struct xt_action_param *p)
 			if (f->opt[optnum].kind == (*optp)) {
 				__u32 len = f->opt[optnum].length;
 				const __u8 *optend = optp + len;
-				int loop_cont = 0;
 
 				fmatch = FMATCH_OK;
 
@@ -275,7 +274,6 @@ xt_osf_match_packet(const struct sk_buff *skb, struct xt_action_param *p)
 					mss = ntohs((__force __be16)mss);
 					break;
 				case OSFOPT_TS:
-					loop_cont = 1;
 					break;
 				}
 
-- 
1.9.1
