From: ebiederm@xmission.com (Eric W. Biederman)
Subject: [PATCH] netns: Only route multicast trafic in init_net
Date: Fri, 11 Jul 2008 13:02:04 -0700
Message-ID: <m1od54dwar.fsf@frodo.ebiederm.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: <netdev@vger.kernel.org>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from out02.mta.xmission.com ([166.70.13.232]:44198 "EHLO
	out02.mta.xmission.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754539AbYGKUMB (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 11 Jul 2008 16:12:01 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


Currently the code to only support multicast traffic in the initial
namespace is incomplete, and receiving a multicast packet causes in a
network namespace causes us to take an initialized lock.  Resulting
in a nasty oops. Ouch!

So until we have network namespace support in igmp.c simply disable
multicast packet reception.

Signed-off-by: Eric W. Biederman <ebiederm@xmission.com>
---
 net/ipv4/igmp.c |    3 +++
 1 files changed, 3 insertions(+), 0 deletions(-)

diff --git a/net/ipv4/igmp.c b/net/ipv4/igmp.c
index 2769dc4..12201ac 100644
--- a/net/ipv4/igmp.c
+++ b/net/ipv4/igmp.c
@@ -2277,6 +2277,9 @@ int ip_check_mc(struct in_device *in_dev, __be32 mc_addr, __be32 src_addr, u16 p
 	struct ip_sf_list *psf;
 	int rv = 0;
 
+	if (dev_net(in_dev->dev) != &init_net)
+		return rv;
+
 	read_lock(&in_dev->mc_list_lock);
 	for (im=in_dev->mc_list; im; im=im->next) {
 		if (im->multiaddr == mc_addr)
-- 
1.5.3.rc6.17.g1911

