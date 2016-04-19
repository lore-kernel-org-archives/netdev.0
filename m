From: Dan Carpenter <dan.carpenter@oracle.com>
Subject: [patch -next] geneve: testing the wrong variable in
 geneve6_build_skb()
Date: Tue, 19 Apr 2016 17:30:56 +0300
Message-ID: <20160419143056.GD4876@mwanda>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Jesse Gross <jesse@kernel.org>,
	"John W. Linville" <linville@tuxdriver.com>,
	Pravin B Shelar <pshelar@nicira.com>,
	Jiri Benc <jbenc@redhat.com>,
	Daniel Borkmann <daniel@iogearbox.net>,
	Tom Herbert <tom@herbertland.com>, netdev@vger.kernel.org,
	kernel-janitors@vger.kernel.org
To: "David S. Miller" <davem@davemloft.net>,
	Alexander Duyck <aduyck@mirantis.com>
Return-path: <kernel-janitors-owner@vger.kernel.org>
Content-Disposition: inline
Sender: kernel-janitors-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

We intended to test "err" and not "skb".

Fixes: aed069df099c ('ip_tunnel_core: iptunnel_handle_offloads returns int and doesn't free skb')
Signed-off-by: Dan Carpenter <dan.carpenter@oracle.com>

diff --git a/drivers/net/geneve.c b/drivers/net/geneve.c
index efbc7ce..512dbe0 100644
--- a/drivers/net/geneve.c
+++ b/drivers/net/geneve.c
@@ -733,7 +733,7 @@ static int geneve6_build_skb(struct dst_entry *dst, struct sk_buff *skb,
 		goto free_dst;
 
 	err = udp_tunnel_handle_offloads(skb, udp_sum);
-	if (IS_ERR(skb))
+	if (err)
 		goto free_dst;
 
 	gnvh = (struct genevehdr *)__skb_push(skb, sizeof(*gnvh) + opt_len);
