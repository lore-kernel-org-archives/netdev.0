From: Daniel Borkmann <dborkman@redhat.com>
Subject: [RFC PATCH net-next 5/7] net: ipv6: mld: restrict min/max of sysctl force_mld_version
Date: Fri, 30 Aug 2013 18:58:26 +0200
Message-ID: <1377881908-8022-6-git-send-email-dborkman@redhat.com>
References: <1377881908-8022-1-git-send-email-dborkman@redhat.com>
Cc: netdev@vger.kernel.org,
	Hannes Frederic Sowa <hannes@stressinduktion.org>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:54424 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1756879Ab3H3Q6k (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 30 Aug 2013 12:58:40 -0400
In-Reply-To: <1377881908-8022-1-git-send-email-dborkman@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Restrict minimum and maximum values that are allowed to be set by the
administrator for force_mld_version into sysctl:

  0 - No enforcement of any MLD version
  1 - Enforce to use MLD version 1
  2 - Enforce to use MLD version 2

Signed-off-by: Daniel Borkmann <dborkman@redhat.com>
Cc: Hannes Frederic Sowa <hannes@stressinduktion.org>
---
 net/ipv6/addrconf.c | 7 ++++++-
 1 file changed, 6 insertions(+), 1 deletion(-)

diff --git a/net/ipv6/addrconf.c b/net/ipv6/addrconf.c
index a7183fc..dde76d4 100644
--- a/net/ipv6/addrconf.c
+++ b/net/ipv6/addrconf.c
@@ -106,6 +106,9 @@
 
 #define	INFINITY_LIFE_TIME	0xFFFFFFFF
 
+static int zero = 0;
+static int two = 2;
+
 static inline u32 cstamp_delta(unsigned long cstamp)
 {
 	return (cstamp - INITIAL_JIFFIES) * 100UL / HZ;
@@ -4842,7 +4845,9 @@ static struct addrconf_sysctl_table
 			.data		= &ipv6_devconf.force_mld_version,
 			.maxlen		= sizeof(int),
 			.mode		= 0644,
-			.proc_handler	= proc_dointvec,
+			.proc_handler	= proc_dointvec_minmax,
+			.extra1		= &zero,
+			.extra2		= &two,
 		},
 		{
 			.procname	= "mldv1_unsolicited_report_interval",
-- 
1.7.11.7
