From: ebiederm@xmission.com (Eric W. Biederman)
Subject: [PATCH 2/3] tcp: Like icmp use register_pernet_subsys
Date: Fri, 20 Feb 2009 07:53:51 -0800
Message-ID: <m163j5hzow.fsf_-_@fess.ebiederm.org>
References: <m1ocwxi00a.fsf@fess.ebiederm.org>
	<m1bpsxhzqz.fsf@fess.ebiederm.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Linux Containers <containers@lists.osdl.org>,
	<netdev@vger.kernel.org>, Alexey Dobriyan <adobriyan@gmail.com>,
	"Denis V. Lunev" <den@openvz.org>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from out02.mta.xmission.com ([166.70.13.232]:41966 "EHLO
	out02.mta.xmission.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753434AbZBTPxa (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 20 Feb 2009 10:53:30 -0500
In-Reply-To: <m1bpsxhzqz.fsf@fess.ebiederm.org> (Eric W. Biederman's message of "Fri\, 20 Feb 2009 07\:52\:36 -0800")
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


To remove the possibility of packets flying around when network
devices are being cleaned up use reisger_pernet_subsys instead of
register_pernet_device.

Signed-off-by: Eric W. Biederman <ebiederm@aristanetworks.com>
---
 net/ipv4/tcp_ipv4.c |    2 +-
 1 files changed, 1 insertions(+), 1 deletions(-)

diff --git a/net/ipv4/tcp_ipv4.c b/net/ipv4/tcp_ipv4.c
index f6b962f..a738120 100644
--- a/net/ipv4/tcp_ipv4.c
+++ b/net/ipv4/tcp_ipv4.c
@@ -2443,7 +2443,7 @@ static struct pernet_operations __net_initdata tcp_sk_ops = {
 void __init tcp_v4_init(void)
 {
 	inet_hashinfo_init(&tcp_hashinfo);
-	if (register_pernet_device(&tcp_sk_ops))
+	if (register_pernet_subsys(&tcp_sk_ops))
 		panic("Failed to create the TCP control socket.\n");
 }
 
-- 
1.6.1.2.350.g88cc

