From: Stephen Hemminger <shemminger@vyatta.com>
Subject: [PATCH] net: Avoid problems with bonding and device rename
Date: Wed, 14 May 2008 17:03:16 -0700
Message-ID: <20080514170316.672f809d@extreme>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.vyatta.com ([216.93.170.194]:47066 "EHLO mail.vyatta.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754202AbYEOADS (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 14 May 2008 20:03:18 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

See: http://bugzilla.kernel.org/show_bug.cgi?id=10698

The use of /sys/class/net/bonding_masters was a poor ABI choice
that now we have to live with. Best choice is to just block other
usage of that name.

Signed-off-by: Stephen Hemminger <shemminger@vyatta.com>


--- a/net/core/dev.c	2008-05-14 16:50:53.000000000 -0700
+++ b/net/core/dev.c	2008-05-14 16:52:25.000000000 -0700
@@ -758,6 +758,9 @@ int dev_valid_name(const char *name)
 		return 0;
 	if (!strcmp(name, ".") || !strcmp(name, ".."))
 		return 0;
+	/* Sigh. need better ABI discipline -- see bond_sysfs */
+	if (!strcmp(name, "bonding_masters"))
+		return 0;
 
 	while (*name) {
 		if (*name == '/' || isspace(*name))
