From: Phil Oester <kernel@linuxace.com>
Subject: [PATCH] Fix multicast on VLAN interfaces
Date: Thu, 21 Feb 2008 14:05:42 -0800
Message-ID: <20080221220542.GA19693@linuxace.com>
Mime-Version: 1.0
Content-Type: multipart/mixed; boundary="G4iJoqBmSsgzjUCe"
Cc: kaber@trash.net
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from adsl-67-120-171-161.dsl.lsan03.pacbell.net ([67.120.171.161]:36509
	"HELO linuxace.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with SMTP id S1761244AbYBUWOU (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 21 Feb 2008 17:14:20 -0500
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


--G4iJoqBmSsgzjUCe
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline

In commit 56addd6eeeb4e11f5a0af7093ca078e0f29140e0 the VLAN multicast list
handling was reworked.  Unfortunately, a variable initialization was missed,
and multicast over vlan devices has been broken since 2.6.23-rc1 (apparently
not too many people use this).  Trivial fix below, which might be a candidate
for -stable.

Phil

Signed-off-by: Phil Oester <kernel@linuxace.com>


--G4iJoqBmSsgzjUCe
Content-Type: text/plain; charset=us-ascii
Content-Disposition: attachment; filename=patch-mcast-vlan

diff --git a/net/core/dev.c b/net/core/dev.c
index 908f07c..999af2e 100644
--- a/net/core/dev.c
+++ b/net/core/dev.c
@@ -2905,6 +2905,7 @@ int __dev_addr_add(struct dev_addr_list **list, int *count,
 		return -ENOMEM;
 	memcpy(da->da_addr, addr, alen);
 	da->da_addrlen = alen;
+	da->da_synced = 0;
 	da->da_users = 1;
 	da->da_gusers = glbl ? 1 : 0;
 	da->next = *list;

--G4iJoqBmSsgzjUCe--
