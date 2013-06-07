From: Shawn Bohrer <sbohrer@rgmadvisors.com>
Subject: [PATCH net-next] igmp: remove unnecessary in_device member zeroing
Date: Fri,  7 Jun 2013 12:34:43 -0500
Message-ID: <1370626483-23776-1-git-send-email-sbohrer@rgmadvisors.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Cc: davem@davemloft.net, Shawn Bohrer <sbohrer@rgmadvisors.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from na3sys009aog132.obsmtp.com ([74.125.149.250]:44253 "EHLO
	na3sys009aog132.obsmtp.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1755868Ab3FGRfZ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 7 Jun 2013 13:35:25 -0400
Received: by mail-ob0-f172.google.com with SMTP id wo10so6998593obc.17
        for <netdev@vger.kernel.org>; Fri, 07 Jun 2013 10:35:19 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

ip_mc_init_dev() is passed a freshly kzalloc'd in_device so it is
unnecessary to explicitly zero out the members.

Signed-off-by: Shawn Bohrer <sbohrer@rgmadvisors.com>
---
P.S. If explicitly zeroing these members is desired there is still a bug
initializing in_dev->mc_count inside of the #ifdef CONFIG_IP_MULTICAST.
In practice it never matters because as I pointed out mc_count is
already initialized to zero.

 net/ipv4/igmp.c |    4 ----
 1 files changed, 0 insertions(+), 4 deletions(-)

diff --git a/net/ipv4/igmp.c b/net/ipv4/igmp.c
index d8c2327..a883151 100644
--- a/net/ipv4/igmp.c
+++ b/net/ipv4/igmp.c
@@ -1381,13 +1381,9 @@ void ip_mc_init_dev(struct in_device *in_dev)
 {
 	ASSERT_RTNL();
 
-	in_dev->mc_tomb = NULL;
 #ifdef CONFIG_IP_MULTICAST
-	in_dev->mr_gq_running = 0;
 	setup_timer(&in_dev->mr_gq_timer, igmp_gq_timer_expire,
 			(unsigned long)in_dev);
-	in_dev->mr_ifc_count = 0;
-	in_dev->mc_count     = 0;
 	setup_timer(&in_dev->mr_ifc_timer, igmp_ifc_timer_expire,
 			(unsigned long)in_dev);
 	in_dev->mr_qrv = IGMP_Unsolicited_Report_Count;
-- 
1.7.7.6


-- 

---------------------------------------------------------------
This email, along with any attachments, is confidential. If you 
believe you received this message in error, please contact the 
sender immediately and delete all copies of the message.  
Thank you.
