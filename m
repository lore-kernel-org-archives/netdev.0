From: acme@ghostprotocols.net
Subject: [PATCH 5/5] [IPV6]: Reorg struct ifmcaddr6 to save some bytes
Date: Fri,  1 Feb 2008 20:23:36 -0200
Message-ID: <47a39bfa.0986460a.4fda.1c03@mx.google.com>
References: y
 <1201904616-4944-1-git-send-email-y>
 <1201904616-4944-2-git-send-email-y>
 <1201904616-4944-3-git-send-email-y>
 <1201904616-4944-4-git-send-email-y>
 <1201904616-4944-5-git-send-email-y>
Cc: netdev@vger.kernel.org, Arnaldo Carvalho de Melo <acme@redhat.com>
To: "David S. Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from wx-out-0506.google.com ([66.249.82.231]:61839 "EHLO
	wx-out-0506.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754854AbYBAWXz (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 1 Feb 2008 17:23:55 -0500
Received: by wx-out-0506.google.com with SMTP id h31so1986034wxd.4
        for <netdev@vger.kernel.org>; Fri, 01 Feb 2008 14:23:55 -0800 (PST)
In-Reply-To: <1201904616-4944-5-git-send-email-y>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Arnaldo Carvalho de Melo <acme@redhat.com>

/home/acme/git/net-2.6/net/ipv6/mcast.c:
  struct ifmcaddr6 |   -8
 1 struct changed
  igmp6_group_dropped  |   -6
  add_grec             |   -3
  mld_ifc_timer_expire |  -18
  ip6_mc_add_src       |   -3
  ip6_mc_del_src       |   -3
  igmp6_group_added    |   -3
 6 functions changed, 36 bytes removed, diff: -36

ipv6.ko:
 6 functions changed, 36 bytes removed, diff: -36

Signed-off-by: Arnaldo Carvalho de Melo <acme@redhat.com>
---
 include/net/if_inet6.h |    2 +-
 1 files changed, 1 insertions(+), 1 deletions(-)

diff --git a/include/net/if_inet6.h b/include/net/if_inet6.h
index 66c43e2..b2cfc49 100644
--- a/include/net/if_inet6.h
+++ b/include/net/if_inet6.h
@@ -112,13 +112,13 @@ struct ifmcaddr6
 	struct ip6_sf_list	*mca_sources;
 	struct ip6_sf_list	*mca_tomb;
 	unsigned int		mca_sfmode;
+	unsigned char		mca_crcount;
 	unsigned long		mca_sfcount[2];
 	struct timer_list	mca_timer;
 	unsigned		mca_flags;
 	int			mca_users;
 	atomic_t		mca_refcnt;
 	spinlock_t		mca_lock;
-	unsigned char		mca_crcount;
 	unsigned long		mca_cstamp;
 	unsigned long		mca_tstamp;
 };
-- 
1.5.3.8

