From: Wei Liu <wei.liu2@citrix.com>
Subject: [PATCH net-next] tcp: double default TSQ output bytes limit
Date: Wed, 3 Jun 2015 11:10:42 +0100
Message-ID: <1433326242-4061-1-git-send-email-wei.liu2@citrix.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: Stefano Stabellini <stefano.stabellini@eu.citrix.com>,
	George Dunlap <george.dunlap@eu.citrix.com>,
	Wei Liu <wei.liu2@citrix.com>,
	David Miller <davem@davemloft.net>,
	Eric Dumazet <eric.dumazet@gmail.com>
To: <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp02.citrix.com ([66.165.176.63]:56508 "EHLO
	SMTP02.CITRIX.COM" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751169AbbFCKQ6 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 3 Jun 2015 06:16:58 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Xen virtual network driver has higher latency than a physical NIC.
Having only 128K as limit for TSQ introduced 30% regression in guest
throughput.

This patch raises the limit to 256K. This reduces the regression to 8%.
This buys us more time to work out a proper solution in the long run.

Signed-off-by: Wei Liu <wei.liu2@citrix.com>
Cc: David Miller <davem@davemloft.net>
Cc: Eric Dumazet <eric.dumazet@gmail.com>
---
 net/ipv4/tcp_output.c | 4 ++--
 1 file changed, 2 insertions(+), 2 deletions(-)

diff --git a/net/ipv4/tcp_output.c b/net/ipv4/tcp_output.c
index 190538a..eeb59be 100644
--- a/net/ipv4/tcp_output.c
+++ b/net/ipv4/tcp_output.c
@@ -50,8 +50,8 @@ int sysctl_tcp_retrans_collapse __read_mostly = 1;
  */
 int sysctl_tcp_workaround_signed_windows __read_mostly = 0;
 
-/* Default TSQ limit of two TSO segments */
-int sysctl_tcp_limit_output_bytes __read_mostly = 131072;
+/* Default TSQ limit of four TSO segments */
+int sysctl_tcp_limit_output_bytes __read_mostly = 262144;
 
 /* This limits the percentage of the congestion window which we
  * will allow a single TSO frame to consume.  Building TSO frames
-- 
1.9.1
