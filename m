From: Jesse Gross <jesse-l0M0P4e3n4LQT0dZR+AlfA@public.gmane.org>
Subject: [PATCH] Revert "openvswitch: potential NULL deref in
	sample()"
Date: Fri, 27 Jul 2012 13:19:40 -0700
Message-ID: <1343420380-23119-1-git-send-email-jesse@nicira.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: dev-yBygre7rU0TnMu66kgdUjQ@public.gmane.org, netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	Dan Carpenter <dan.carpenter-QHcLZuEGTsvQT0dZR+AlfA@public.gmane.org>
To: David Miller <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>
Return-path: <dev-bounces-yBygre7rU0TnMu66kgdUjQ@public.gmane.org>
List-Unsubscribe: <http://openvswitch.org/mailman/options/dev>,
	<mailto:dev-request-yBygre7rU0TnMu66kgdUjQ@public.gmane.org?subject=unsubscribe>
List-Archive: <http://openvswitch.org/pipermail/dev>
List-Post: <mailto:dev-yBygre7rU0TnMu66kgdUjQ@public.gmane.org>
List-Help: <mailto:dev-request-yBygre7rU0TnMu66kgdUjQ@public.gmane.org?subject=help>
List-Subscribe: <http://openvswitch.org/mailman/listinfo/dev>,
	<mailto:dev-request-yBygre7rU0TnMu66kgdUjQ@public.gmane.org?subject=subscribe>
Sender: dev-bounces-yBygre7rU0TnMu66kgdUjQ@public.gmane.org
Errors-To: dev-bounces-yBygre7rU0TnMu66kgdUjQ@public.gmane.org
List-Id: netdev.vger.kernel.org

This reverts commit 5b3e7e6cb5771bedda51cdb6f715d1da8cd9e644.

The problem that the original commit was attempting to fix can
never happen in practice because validation is done one a per-flow
basis rather than a per-packet basis.  Adding additional checks at
runtime is unnecessary and inconsistent with the rest of the code.

CC: Dan Carpenter <dan.carpenter-QHcLZuEGTsvQT0dZR+AlfA@public.gmane.org>
Signed-off-by: Jesse Gross <jesse-l0M0P4e3n4LQT0dZR+AlfA@public.gmane.org>
---
 net/openvswitch/actions.c |    3 ---
 1 file changed, 3 deletions(-)

diff --git a/net/openvswitch/actions.c b/net/openvswitch/actions.c
index 320fa0e..f3f96ba 100644
--- a/net/openvswitch/actions.c
+++ b/net/openvswitch/actions.c
@@ -325,9 +325,6 @@ static int sample(struct datapath *dp, struct sk_buff *skb,
 		}
 	}
 
-	if (!acts_list)
-		return 0;
-
 	return do_execute_actions(dp, skb, nla_data(acts_list),
 						 nla_len(acts_list), true);
 }
-- 
1.7.9.5
