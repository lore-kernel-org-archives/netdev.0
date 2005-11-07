From: Yan Zheng <yanzheng@21cn.com>
Subject: [PATCH][MCAST]Clear MAF_GSQUERY flag when process MLDv1 general query
 messages.
Date: Mon, 07 Nov 2005 22:13:34 +0800
Message-ID: <436F610E.8010400@21cn.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8; format=flowed
Content-Transfer-Encoding: 7bit
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S932468AbVKGOM0@vger.kernel.org>
To: netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	David Stevens <dlstevens@us.ibm.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hi.
 

MAF_GSQUERY flag may cause problem when MLDv1 compatibility mode expires.  



Signed-off-by: Yan Zheng <yanzheng@21cn.com>

Index: net/ipv6/mcast.c
================================================================================
--- linux-2.6.14/net/ipv6/mcast.c	2005-11-05 09:09:47.000000000 +0800
+++ linux/net/ipv6/mcast.c	2005-11-07 21:57:27.000000000 +0800
@@ -1166,6 +1166,7 @@ int igmp6_event_query(struct sk_buff *sk
 	if (group_type == IPV6_ADDR_ANY) {
 		for (ma = idev->mc_list; ma; ma=ma->next) {
 			spin_lock_bh(&ma->mca_lock);
+			ma->mca_flags &= ~MAF_GSQUERY;
 			igmp6_group_queried(ma, max_delay);
 			spin_unlock_bh(&ma->mca_lock);
 		}
