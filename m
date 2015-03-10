From: Fan Du <fan.du@intel.com>
Subject: [PATCH net-next 4/4] ipv4: clamp sysctl_tcp_probe_threshold
Date: Tue, 10 Mar 2015 17:16:26 +0800
Message-ID: <1425978986-8512-5-git-send-email-fan.du@intel.com>
References: <1425978986-8512-1-git-send-email-fan.du@intel.com>
Cc: davem@davemloft.net, netdev@vger.kernel.org,
	fengyuleidian0615@gmail.com
To: johnwheffner@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga09.intel.com ([134.134.136.24]:7615 "EHLO mga09.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751116AbbCJJVa (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 10 Mar 2015 05:21:30 -0400
In-Reply-To: <1425978986-8512-1-git-send-email-fan.du@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Signed-off-by: Fan Du <fan.du@intel.com>
---
 net/ipv4/tcp_output.c |    2 +-
 1 files changed, 1 insertions(+), 1 deletions(-)

diff --git a/net/ipv4/tcp_output.c b/net/ipv4/tcp_output.c
index 89d3f84..dc0221b 100644
--- a/net/ipv4/tcp_output.c
+++ b/net/ipv4/tcp_output.c
@@ -1900,7 +1900,7 @@ static int tcp_mtu_probe(struct sock *sk)
 	 * probing process by not resetting search range to its orignal.
 	 */
 	if (probe_size > tcp_mtu_to_mss(sk, icsk->icsk_mtup.search_high) ||
-		interval < net->ipv4.sysctl_tcp_probe_threshold) {
+		interval < max(1, net->ipv4.sysctl_tcp_probe_threshold)) {
 		/* Check whether enough time has elaplased for
 		 * another round of probing.
 		 */
-- 
1.7.1
