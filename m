From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: [PATCH net] ipv4: disable BH in set_ping_group_range()
Date: Thu, 20 Oct 2016 10:26:48 -0700
Message-ID: <1476984408.7065.21.camel@edumazet-glaptop3.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev <netdev@vger.kernel.org>, Eric Salo <salo@google.com>,
        Cong Wang <xiyou.wangcong@gmail.com>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pf0-f196.google.com ([209.85.192.196]:33498 "EHLO
        mail-pf0-f196.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S964929AbcJTR0u (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 20 Oct 2016 13:26:50 -0400
Received: by mail-pf0-f196.google.com with SMTP id i85so6131453pfa.0
        for <netdev@vger.kernel.org>; Thu, 20 Oct 2016 10:26:50 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Eric Dumazet <edumazet@google.com>

In commit 4ee3bd4a8c746 ("ipv4: disable BH when changing ip local port
range") Cong added BH protection in set_local_port_range() but missed
that same fix was needed in set_ping_group_range()

Fixes: b8f1a55639e6 ("udp: Add function to make source port for UDP tunnels")
Signed-off-by: Eric Dumazet <edumazet@google.com>
Reported-by: Eric Salo <salo@google.com>
---
 net/ipv4/sysctl_net_ipv4.c |    4 ++--
 1 file changed, 2 insertions(+), 2 deletions(-)

diff --git a/net/ipv4/sysctl_net_ipv4.c b/net/ipv4/sysctl_net_ipv4.c
index 1cb67de106fe..500ae4010bed 100644
--- a/net/ipv4/sysctl_net_ipv4.c
+++ b/net/ipv4/sysctl_net_ipv4.c
@@ -109,10 +109,10 @@ static void set_ping_group_range(struct ctl_table *table, kgid_t low, kgid_t hig
 	kgid_t *data = table->data;
 	struct net *net =
 		container_of(table->data, struct net, ipv4.ping_group_range.range);
-	write_seqlock(&net->ipv4.ip_local_ports.lock);
+	write_seqlock_bh(&net->ipv4.ip_local_ports.lock);
 	data[0] = low;
 	data[1] = high;
-	write_sequnlock(&net->ipv4.ip_local_ports.lock);
+	write_sequnlock_bh(&net->ipv4.ip_local_ports.lock);
 }
 
 /* Validate changes from /proc interface. */
