From: Tom Gundersen <teg@jklm.no>
Subject: [PATCH v7 30/33] net: ppp - set name assign type
Date: Thu, 10 Jul 2014 10:17:35 +0200
Message-ID: <1404980258-30853-31-git-send-email-teg@jklm.no>
References: <1404980258-30853-1-git-send-email-teg@jklm.no>
Cc: linux-kernel@vger.kernel.org, David Miller <davem@davemloft.net>,
	David Herrmann <dh.herrmann@gmail.com>,
	Kay Sievers <kay@vrfy.org>, Tom Gundersen <teg@jklm.no>,
	Paul Mackerras <paulus@samba.org>, linux-ppp@vger.kernel.org
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-la0-f50.google.com ([209.85.215.50]:53679 "EHLO
	mail-la0-f50.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752365AbaGJITG (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 10 Jul 2014 04:19:06 -0400
Received: by mail-la0-f50.google.com with SMTP id pv20so5754996lab.23
        for <netdev@vger.kernel.org>; Thu, 10 Jul 2014 01:19:04 -0700 (PDT)
In-Reply-To: <1404980258-30853-1-git-send-email-teg@jklm.no>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The ifname is of the form pppX where X is the unit number. This is even set
by userspace, or userspace requests the kernel to chose one, which is then
returned to userspace. Either way the creating user knows the name, so we
treat both cases as if the user had explicitly chosen the name and label
it NET_NAME_USER.

Signed-off-by: Tom Gundersen <teg@jklm.no>
Cc: Paul Mackerras <paulus@samba.org>
Cc: linux-ppp@vger.kernel.org
---
 drivers/net/ppp/ppp_generic.c | 1 +
 1 file changed, 1 insertion(+)

diff --git a/drivers/net/ppp/ppp_generic.c b/drivers/net/ppp/ppp_generic.c
index 5c002b1..9757b52 100644
--- a/drivers/net/ppp/ppp_generic.c
+++ b/drivers/net/ppp/ppp_generic.c
@@ -2726,6 +2726,7 @@ ppp_create_interface(struct net *net, int unit, int *retp)
 	/* Initialize the new ppp unit */
 	ppp->file.index = unit;
 	sprintf(dev->name, "ppp%d", unit);
+	dev->name_assign_type = NET_NAME_USER;
 
 	ret = register_netdev(dev);
 	if (ret != 0) {
-- 
1.9.3
