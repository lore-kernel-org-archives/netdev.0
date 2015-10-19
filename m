From: Sowmini Varadhan <sowmini.varadhan@oracle.com>
Subject: [PATCH net-next 2/2] xfrm: Fix unaligned access in xfrm_notify_sa() for DELSA
Date: Mon, 19 Oct 2015 17:23:29 -0400
Message-ID: <65f37efeff5af105c89493dda4f38c61e4cd495f.1445286755.git.sowmini.varadhan@oracle.com>
References: <cover.1445286755.git.sowmini.varadhan@oracle.com>
Cc: herbert@gondor.apana.org.au, dhowells@redhat.com,
	davem@davemloft.net, zohar@linux.vnet.ibm.com,
	David.Woodhouse@intel.com, sowmini.varadhan@oracle.com,
	steffen.klassert@secunet.com
To: linux-crypto@vger.kernel.org, linux-kernel@vger.kernel.org,
	netdev@vger.kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <cover.1445286755.git.sowmini.varadhan@oracle.com>
In-Reply-To: <cover.1445286755.git.sowmini.varadhan@oracle.com>
References: <cover.1445286755.git.sowmini.varadhan@oracle.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On sparc, deleting established SAs (e.g., by restarting ipsec
at the peer) results in unaligned access messages via
xfrm_del_sa -> km_state_notify -> xfrm_send_state_notify().
Use an aligned pointer to xfrm_usersa_info for this case.

Signed-off-by: Sowmini Varadhan <sowmini.varadhan@oracle.com>
---
 net/xfrm/xfrm_user.c |    2 +-
 1 files changed, 1 insertions(+), 1 deletions(-)

diff --git a/net/xfrm/xfrm_user.c b/net/xfrm/xfrm_user.c
index a8de9e3..158ef4a 100644
--- a/net/xfrm/xfrm_user.c
+++ b/net/xfrm/xfrm_user.c
@@ -2659,7 +2659,7 @@ static int xfrm_notify_sa(struct xfrm_state *x, const struct km_event *c)
 		if (attr == NULL)
 			goto out_free_skb;
 
-		p = nla_data(attr);
+		p = PTR_ALIGN(nla_data(attr), __alignof__(*p));
 	}
 	err = copy_to_user_state_extra(x, p, skb);
 	if (err)
-- 
1.7.1
