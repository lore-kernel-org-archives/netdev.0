From: Pavel Tikhomirov <ptikhomirov@virtuozzo.com>
Subject: [PATCH v2] ipv4: make tcp_notsent_lowat sysctl knob behave as true unsigned int
Date: Mon,  9 Jan 2017 10:45:49 +0300
Message-ID: <20170109074549.12220-1-ptikhomirov@virtuozzo.com>
References: <20161230.152325.1460360247883491150.davem@davemloft.net>
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
In-Reply-To: <20161230.152325.1460360247883491150.davem@davemloft.net>
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

v2: simplify to just proc_douintvec
Signed-off-by: Pavel Tikhomirov <ptikhomirov@virtuozzo.com>
---
 net/ipv4/sysctl_net_ipv4.c | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/net/ipv4/sysctl_net_ipv4.c b/net/ipv4/sysctl_net_ipv4.c
index 80bc36b..566cfc5 100644
--- a/net/ipv4/sysctl_net_ipv4.c
+++ b/net/ipv4/sysctl_net_ipv4.c
@@ -958,7 +958,7 @@ static struct ctl_table ipv4_net_table[] = {
 		.data		= &init_net.ipv4.sysctl_tcp_notsent_lowat,
 		.maxlen		= sizeof(unsigned int),
 		.mode		= 0644,
-		.proc_handler	= proc_dointvec,
+		.proc_handler	= proc_douintvec,
 	},
 #ifdef CONFIG_IP_ROUTE_MULTIPATH
 	{
-- 
2.9.3
