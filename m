From: Pavel Tikhomirov <ptikhomirov@virtuozzo.com>
Subject: [PATCH] ipv4: make tcp_notsent_lowat sysctl knob behave as true unsigned int
Date: Thu, 29 Dec 2016 17:35:07 +0300
Message-ID: <20161229143507.4934-1-ptikhomirov@virtuozzo.com>
Cc: Eric Dumazet <edumazet@google.com>,
        Alexey Kuznetsov <kuznet@ms2.inr.ac.ru>,
        James Morris <jmorris@namei.org>,
        Hideaki YOSHIFUJI <yoshfuji@linux-ipv6.org>,
        Patrick McHardy <kaber@trash.net>, netdev@vger.kernel.org,
        linux-kernel@vger.kernel.org,
        Konstantin Khorenko <khorenko@virtuozzo.com>,
        Pavel Tikhomirov <ptikhomirov@virtuozzo.com>
To: "David S . Miller" <davem@davemloft.net>
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

> cat /proc/sys/net/ipv4/tcp_notsent_lowat
-1
> echo 4294967295 > /proc/sys/net/ipv4/tcp_notsent_lowat
-bash: echo: write error: Invalid argument
> echo -2147483648 > /proc/sys/net/ipv4/tcp_notsent_lowat
> cat /proc/sys/net/ipv4/tcp_notsent_lowat
-2147483648

but in documentation we have "tcp_notsent_lowat - UNSIGNED INTEGER"

Signed-off-by: Pavel Tikhomirov <ptikhomirov@virtuozzo.com>
---
 net/ipv4/sysctl_net_ipv4.c | 5 ++++-
 1 file changed, 4 insertions(+), 1 deletion(-)

diff --git a/net/ipv4/sysctl_net_ipv4.c b/net/ipv4/sysctl_net_ipv4.c
index 80bc36b..5361373 100644
--- a/net/ipv4/sysctl_net_ipv4.c
+++ b/net/ipv4/sysctl_net_ipv4.c
@@ -41,6 +41,7 @@ static int tcp_syn_retries_min = 1;
 static int tcp_syn_retries_max = MAX_TCP_SYNCNT;
 static int ip_ping_group_range_min[] = { 0, 0 };
 static int ip_ping_group_range_max[] = { GID_T_MAX, GID_T_MAX };
+static unsigned int uint_max = UINT_MAX;
 
 /* Update system visible IP port range */
 static void set_local_port_range(struct net *net, int range[2])
@@ -958,7 +959,9 @@ static struct ctl_table ipv4_net_table[] = {
 		.data		= &init_net.ipv4.sysctl_tcp_notsent_lowat,
 		.maxlen		= sizeof(unsigned int),
 		.mode		= 0644,
-		.proc_handler	= proc_dointvec,
+		.proc_handler	= proc_doulongvec_minmax,
+		.extra1		= &zero,
+		.extra2		= &uint_max,
 	},
 #ifdef CONFIG_IP_ROUTE_MULTIPATH
 	{
-- 
2.9.3
