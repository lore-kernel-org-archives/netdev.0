From: ebiederm@xmission.com (Eric W. Biederman)
Subject: [PATCH 09/10] sysctl: ipv4 remove binary sysctl paths where they are broken.
Date: Thu, 09 Aug 2007 19:02:19 -0600
Message-ID: <m1ejic8an8.fsf_-_@ebiederm.dsl.xmission.com>
References: <20070726164518.GB16937@localhost.sw.ru>
	<m13azbulhf.fsf@ebiederm.dsl.xmission.com>
	<20070727145235.GC6924@localhost.sw.ru>
	<20070806124530.GD6634@localhost.sw.ru>
	<m1tzr8a3ms.fsf_-_@ebiederm.dsl.xmission.com>
	<m1ps1wa3kf.fsf_-_@ebiederm.dsl.xmission.com>
	<m1hcn8a2rq.fsf_-_@ebiederm.dsl.xmission.com>
	<m1d4xw9psl.fsf_-_@ebiederm.dsl.xmission.com>
	<m18x8k9ppv.fsf_-_@ebiederm.dsl.xmission.com>
	<m14pj89pmt.fsf_-_@ebiederm.dsl.xmission.com>
	<m1zm108axi.fsf_-_@ebiederm.dsl.xmission.com>
	<m1vebo8avf.fsf_-_@ebiederm.dsl.xmission.com>
	<m1r6mc8at5.fsf_-_@ebiederm.dsl.xmission.com>
	<m1myx08arh.fsf_-_@ebiederm.dsl.xmission.com>
	<m1ir7o8ap1.fsf_-_@ebiederm.dsl.xmission.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: linux-kernel@vger.kernel.org, Alexey Dobriyan <adobriyan@sw.ru>,
	David Miller <davem@davemloft.net>, <netdev@vger.kernel.org>
To: Andrew Morton <akpm@linux-foundation.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from ebiederm.dsl.xmission.com ([166.70.28.69]:44950 "EHLO
	ebiederm.dsl.xmission.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753873AbXHJBDQ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 9 Aug 2007 21:03:16 -0400
In-Reply-To: <m1ir7o8ap1.fsf_-_@ebiederm.dsl.xmission.com> (Eric
	W. Biederman's message of "Thu, 09 Aug 2007 19:01:14 -0600")
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


Currently tcp_available_congestion_control does not even
attempt being read from sys_sysctl, and ipfrag_max_dist
while it works allows setting of invalid values using
sys_sysctl.

So just kill the binary sys_sysctl support for these
sysctls.  If the support is not important enough to
test and get right it probably isn't important enough
to keep.

Signed-off-by: Eric W. Biederman <ebiederm@xmission.com>
---
 net/ipv4/sysctl_net_ipv4.c |    2 --
 1 files changed, 0 insertions(+), 2 deletions(-)

diff --git a/net/ipv4/sysctl_net_ipv4.c b/net/ipv4/sysctl_net_ipv4.c
index 53ef0f4..282eb7e 100644
--- a/net/ipv4/sysctl_net_ipv4.c
+++ b/net/ipv4/sysctl_net_ipv4.c
@@ -672,7 +672,6 @@ ctl_table ipv4_table[] = {
 		.strategy	= &sysctl_jiffies
 	},
 	{
-		.ctl_name	= NET_IPV4_IPFRAG_MAX_DIST,
 		.procname	= "ipfrag_max_dist",
 		.data		= &sysctl_ipfrag_max_dist,
 		.maxlen		= sizeof(int),
@@ -797,7 +796,6 @@ ctl_table ipv4_table[] = {
 	},
 #endif /* CONFIG_NETLABEL */
 	{
-		.ctl_name	= NET_TCP_AVAIL_CONG_CONTROL,
 		.procname	= "tcp_available_congestion_control",
 		.maxlen		= TCP_CA_BUF_MAX,
 		.mode		= 0444,
-- 
1.5.1.1.181.g2de0

