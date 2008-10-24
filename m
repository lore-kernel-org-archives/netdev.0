From: frank.blaschka@de.ibm.com
Subject: [patch 3/4] qeth: remove unnecessary support ckeck in sysfs route6
Date: Fri, 24 Oct 2008 11:16:54 +0200
Message-ID: <20081024091733.417039000@de.ibm.com>
References: <20081024091651.603673000@de.ibm.com>
Cc: netdev@vger.kernel.org, linux-s390@vger.kernel.org
To: jgarzik@pobox.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from mtagate4.de.ibm.com ([195.212.29.153]:34316 "EHLO
	mtagate4.de.ibm.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750965AbYJXJRx (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 24 Oct 2008 05:17:53 -0400
Content-Disposition: inline; filename=604-qeth-ipv6check.diff
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Frank Blaschka <frank.blaschka@de.ibm.com>

Removing this check improves usability because you do not have to
set the device online to initially set ipv6 routing option.

Signed-off-by: Frank Blaschka <frank.blaschka@de.ibm.com>
---

 drivers/s390/net/qeth_l3_sys.c |    7 -------
 1 file changed, 7 deletions(-)

Index: git_linus/drivers/s390/net/qeth_l3_sys.c
===================================================================
--- git_linus.orig/drivers/s390/net/qeth_l3_sys.c
+++ git_linus/drivers/s390/net/qeth_l3_sys.c
@@ -121,9 +121,6 @@ static ssize_t qeth_l3_dev_route6_show(s
 	if (!card)
 		return -EINVAL;
 
-	if (!qeth_is_supported(card, IPA_IPV6))
-		return sprintf(buf, "%s\n", "n/a");
-
 	return qeth_l3_dev_route_show(card, &card->options.route6, buf);
 }
 
@@ -135,10 +132,6 @@ static ssize_t qeth_l3_dev_route6_store(
 	if (!card)
 		return -EINVAL;
 
-	if (!qeth_is_supported(card, IPA_IPV6)) {
-		return -EOPNOTSUPP;
-	}
-
 	return qeth_l3_dev_route_store(card, &card->options.route6,
 				QETH_PROT_IPV6, buf, count);
 }

-- 
