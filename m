From: Dan Carpenter <dan.carpenter-QHcLZuEGTsvQT0dZR+AlfA@public.gmane.org>
Subject: [patch] openvswitch: potential NULL deref in sample()
Date: Mon, 23 Jul 2012 10:46:28 +0300
Message-ID: <20120723074628.GA30892@elgon.mountain>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: dev-yBygre7rU0TnMu66kgdUjQ@public.gmane.org, netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	kernel-janitors-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, "David S. Miller" <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>
To: Jesse Gross <jesse-l0M0P4e3n4LQT0dZR+AlfA@public.gmane.org>
Return-path: <dev-bounces-yBygre7rU0TnMu66kgdUjQ@public.gmane.org>
Content-Disposition: inline
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

If there is no OVS_SAMPLE_ATTR_ACTIONS set then "acts_list" is NULL and
it leads to a NULL dereference when we call nla_len(acts_list).  This
is a static checker fix, not something I have seen in testing.

Signed-off-by: Dan Carpenter <dan.carpenter-QHcLZuEGTsvQT0dZR+AlfA@public.gmane.org>
---
This applies to Linus's tree.

diff --git a/net/openvswitch/actions.c b/net/openvswitch/actions.c
index 48badff..c2351d6 100644
--- a/net/openvswitch/actions.c
+++ b/net/openvswitch/actions.c
@@ -325,6 +325,9 @@ static int sample(struct datapath *dp, struct sk_buff *skb,
 		}
 	}
 
+	if (!acts_list)
+		return 0;
+
 	return do_execute_actions(dp, skb, nla_data(acts_list),
 						 nla_len(acts_list), true);
 }
