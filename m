From: Andrew Morton <akpm@osdl.org>
Subject: Re: [IPV4] Fix ip_rt_gc_min_interval_ms procfs/sysctl
Date: Fri, 18 Feb 2005 03:02:22 -0800
Message-ID: <20050218030222.51fcc83f.akpm@osdl.org>
References: <20050218.192430.98634850.yoshfuji@linux-ipv6.org>
	<20050218024917.2e5c19ec.akpm@osdl.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
To: yoshfuji@linux-ipv6.org, torvalds@osdl.org, davem@davemloft.net,
        netdev@oss.sgi.com
In-Reply-To: <20050218024917.2e5c19ec.akpm@osdl.org>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

Andrew Morton <akpm@osdl.org> wrote:
>
>  A better approach wold be to rework ip_rt_gc_min_interval so that its
>  userspace-visible units are milliseconds.

<actually looks at the code>

We are doing, via gc_min_interval_ms.

Funny thing is, sysctl table is treating ip_rt_gc_min_interval as a long,
and it isn't.  I wonder if the current code works correctly on 64-bit
big-endian.

Seems to me a simpler fix would be to make it a long?

diff -puN net/ipv4/route.c~a net/ipv4/route.c
--- 25/net/ipv4/route.c~a	2005-02-18 02:58:19.000000000 -0800
+++ 25-akpm/net/ipv4/route.c	2005-02-18 03:01:30.000000000 -0800
@@ -113,7 +113,7 @@ static int ip_rt_max_delay		= 10 * HZ;
 static int ip_rt_max_size;
 static int ip_rt_gc_timeout		= RT_GC_TIMEOUT;
 static int ip_rt_gc_interval		= 60 * HZ;
-static int ip_rt_gc_min_interval	= HZ / 2;
+static long ip_rt_gc_min_interval	= HZ / 2;
 static int ip_rt_redirect_number	= 9;
 static int ip_rt_redirect_load		= HZ / 50;
 static int ip_rt_redirect_silence	= ((HZ / 50) << (9 + 1));
@@ -2536,9 +2536,9 @@ ctl_table ipv4_route_table[] = {
 		.ctl_name	= NET_IPV4_ROUTE_GC_MIN_INTERVAL,
 		.procname	= "gc_min_interval",
 		.data		= &ip_rt_gc_min_interval,
-		.maxlen		= sizeof(int),
+		.maxlen		= sizeof(long),
 		.mode		= 0644,
-		.proc_handler	= &proc_dointvec_jiffies,
+		.proc_handler	= &proc_doulongvec_minmax,
 		.strategy	= &sysctl_jiffies,
 	},
 	{
_
