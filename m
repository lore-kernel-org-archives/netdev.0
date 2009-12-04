From: Stephen Rothwell <sfr@canb.auug.org.au>
Subject: linux-next: manual merge of the sysctl tree with the net tree
Date: Fri, 4 Dec 2009 19:43:01 +1100
Message-ID: <20091204194301.ca77fe40.sfr@canb.auug.org.au>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: linux-next@vger.kernel.org, linux-kernel@vger.kernel.org,
	William Allen Simpson <william.allen.simpson@gmail.com>,
	David Miller <davem@davemloft.net>, <netdev@vger.kernel.org>
To: "Eric W. Biederman" <ebiederm@xmission.com>
Return-path: <linux-next-owner@vger.kernel.org>
Sender: linux-next-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hi Eric,

Today's linux-next merge of the sysctl tree got a conflict in
net/ipv4/sysctl_net_ipv4.c between commit
519855c508b9a17878c0977a3cdefc09b59b30df ("TCPCT part 1c:
sysctl_tcp_cookie_size, socket option TCP_COOKIE_TRANSACTIONS") from the
net tree and commit f8572d8f2a2ba75408b97dc24ef47c83671795d7 ("sysctl
net: Remove unused binary sysctl code") from the sysctl tree.

I fixed it up (see below) and can carry the fix as necessary.
-- 
Cheers,
Stephen Rothwell                    sfr@canb.auug.org.au

diff --cc net/ipv4/sysctl_net_ipv4.c
index 13f7ab6,3000567..0000000
--- a/net/ipv4/sysctl_net_ipv4.c
+++ b/net/ipv4/sysctl_net_ipv4.c
@@@ -713,15 -569,6 +569,13 @@@ static struct ctl_table ipv4_table[] = 
  		.proc_handler	= proc_dointvec,
  	},
  	{
- 		.ctl_name	= CTL_UNNUMBERED,
 +		.procname	= "tcp_cookie_size",
 +		.data		= &sysctl_tcp_cookie_size,
 +		.maxlen		= sizeof(int),
 +		.mode		= 0644,
 +		.proc_handler	= proc_dointvec
 +	},
 +	{
- 		.ctl_name	= CTL_UNNUMBERED,
  		.procname	= "udp_mem",
  		.data		= &sysctl_udp_mem,
  		.maxlen		= sizeof(sysctl_udp_mem),
