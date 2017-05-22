From: SF Markus Elfring <elfring@users.sourceforge.net>
Subject: [PATCH 1/3] net: pktgen: Improve four size determinations
Date: Mon, 22 May 2017 11:12:55 +0200
Message-ID: <08d6e27c-dcc3-5e24-7ec9-ba1587309658@users.sourceforge.net>
References: <79472009-7764-bb92-5f29-60bb21793cec@users.sourceforge.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 7bit
Cc: LKML <linux-kernel@vger.kernel.org>,
        kernel-janitors@vger.kernel.org
To: netdev@vger.kernel.org, Alexey Dobriyan <adobriyan@gmail.com>,
        "David S. Miller" <davem@davemloft.net>,
        Eric Dumazet <edumazet@google.com>,
        Florian Westphal <fw@strlen.de>,
        =?UTF-8?B?R8O8bnRlciBSw7Zjaw==?= <linux@roeck-us.net>,
        John Fastabend <john.fastabend@gmail.com>,
        Paolo Abeni <pabeni@redhat.com>,
        Willem de Bruijn <willemb@google.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <79472009-7764-bb92-5f29-60bb21793cec@users.sourceforge.net>
Content-Language: en-GB
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Markus Elfring <elfring@users.sourceforge.net>
Date: Mon, 22 May 2017 10:34:11 +0200

Replace the specification of four data structures by pointer dereferences
as the parameter for the operator "sizeof" to make the corresponding size
determination a bit safer according to the Linux coding style convention.

Signed-off-by: Markus Elfring <elfring@users.sourceforge.net>
---
 net/core/pktgen.c | 9 ++++-----
 1 file changed, 4 insertions(+), 5 deletions(-)

diff --git a/net/core/pktgen.c b/net/core/pktgen.c
index 96947f5d41e4..c89f4ad21187 100644
--- a/net/core/pktgen.c
+++ b/net/core/pktgen.c
@@ -2995,10 +2995,10 @@ static struct sk_buff *fill_packet_ipv6(struct net_device *odev,
 
 	skb_reset_mac_header(skb);
 	skb_set_network_header(skb, skb->len);
-	iph = (struct ipv6hdr *) skb_put(skb, sizeof(struct ipv6hdr));
+	iph = (struct ipv6hdr *)skb_put(skb, sizeof(*iph));
 
 	skb_set_transport_header(skb, skb->len);
-	udph = (struct udphdr *) skb_put(skb, sizeof(struct udphdr));
+	udph = (struct udphdr *)skb_put(skb, sizeof(*udph));
 	skb_set_queue_mapping(skb, queue_map);
 	skb->priority = pkt_dev->skb_priority;
 
@@ -3678,5 +3678,5 @@ static int pktgen_add_device(struct pktgen_thread *t, const char *ifname)
 		return -EBUSY;
 	}
 
-	pkt_dev = kzalloc_node(sizeof(struct pktgen_dev), GFP_KERNEL, node);
+	pkt_dev = kzalloc_node(sizeof(*pkt_dev), GFP_KERNEL, node);
 	if (!pkt_dev)
@@ -3756,6 +3756,5 @@ static int __net_init pktgen_create_thread(int cpu, struct pktgen_net *pn)
 	struct proc_dir_entry *pe;
 	struct task_struct *p;
 
-	t = kzalloc_node(sizeof(struct pktgen_thread), GFP_KERNEL,
-			 cpu_to_node(cpu));
+	t = kzalloc_node(sizeof(*t), GFP_KERNEL, cpu_to_node(cpu));
 	if (!t) {
-- 
2.13.0
