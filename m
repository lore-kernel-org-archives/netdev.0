From: Patrick McHardy <kaber@trash.net>
Subject: netfilter 10/29: netns ebtables: br_nf_pre_routing_finish() fixup
Date: Thu, 27 Nov 2008 17:15:16 +0100 (MET)
Message-ID: <20081127161516.13891.68132.sendpatchset@x2.localnet>
References: <20081127161503.13891.62766.sendpatchset@x2.localnet>
Cc: netdev@vger.kernel.org, Patrick McHardy <kaber@trash.net>,
	netfilter-devel@vger.kernel.org
To: davem@davemloft.net
Return-path: <netfilter-devel-owner@vger.kernel.org>
In-Reply-To: <20081127161503.13891.62766.sendpatchset@x2.localnet>
Sender: netfilter-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

commit 249b62035ca247b9cedbefa1acf6bdc53b96e678
Author: Alexey Dobriyan <adobriyan@gmail.com>
Date:   Tue Nov 4 14:31:29 2008 +0100

    netfilter: netns ebtables: br_nf_pre_routing_finish() fixup
    
    Signed-off-by: Alexey Dobriyan <adobriyan@gmail.com>
    Signed-off-by: Patrick McHardy <kaber@trash.net>

diff --git a/net/bridge/br_netfilter.c b/net/bridge/br_netfilter.c
index db6176d..bf9d6af 100644
--- a/net/bridge/br_netfilter.c
+++ b/net/bridge/br_netfilter.c
@@ -357,7 +357,7 @@ static int br_nf_pre_routing_finish(struct sk_buff *skb)
 			if (err != -EHOSTUNREACH || !in_dev || IN_DEV_FORWARD(in_dev))
 				goto free_skb;
 
-			if (!ip_route_output_key(&init_net, &rt, &fl)) {
+			if (!ip_route_output_key(dev_net(dev), &rt, &fl)) {
 				/* - Bridged-and-DNAT'ed traffic doesn't
 				 *   require ip_forwarding. */
 				if (((struct dst_entry *)rt)->dev == dev) {
