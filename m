From: Eric Dumazet <dada1@cosmosbay.com>
Subject: [ICMP]: Avoid sparse warnings in net/ipv4/icmp.c
Date: Fri, 04 Jan 2008 06:24:20 +0100
Message-ID: <477DC304.40508@cosmosbay.com>
Mime-Version: 1.0
Content-Type: multipart/mixed;
 boundary="------------060207000900060006080702"
To: "David S. Miller" <davem@davemloft.net>,
	Linux Netdev List <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from gw1.cosmosbay.com ([86.65.150.130]:46673 "EHLO
	gw1.cosmosbay.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751755AbYADFYf (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 4 Jan 2008 00:24:35 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This is a multi-part message in MIME format.
--------------060207000900060006080702
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit

   CHECK   net/ipv4/icmp.c
net/ipv4/icmp.c:249:13: warning: context imbalance in 'icmp_xmit_unlock' - 
unexpected unlock
net/ipv4/icmp.c:376:13: warning: context imbalance in 'icmp_reply' - different 
lock contexts for basic block
net/ipv4/icmp.c:430:6: warning: context imbalance in 'icmp_send' - different 
lock contexts for basic block

Solution is to declare icmp_xmit_unlock() as __inline__ (similar with 
icmp_xmit_lock())

Signed-off-by: Eric Dumazet <dada1@cosmosbay.com>

  net/ipv4/icmp.c |    2 +-
  1 files changed, 1 insertion(+), 1 deletion(-)


--------------060207000900060006080702
Content-Type: text/plain;
 name="icmp.patch"
Content-Transfer-Encoding: 7bit
Content-Disposition: inline;
 filename="icmp.patch"

diff --git a/net/ipv4/icmp.c b/net/ipv4/icmp.c
index fc66c8a..01ce07b 100644
--- a/net/ipv4/icmp.c
+++ b/net/ipv4/icmp.c
@@ -246,7 +246,7 @@ static __inline__ int icmp_xmit_lock(void)
 	return 0;
 }
 
-static void icmp_xmit_unlock(void)
+static __inline__ void icmp_xmit_unlock(void)
 {
 	spin_unlock_bh(&icmp_sock->sk_lock.slock);
 }

--------------060207000900060006080702--
