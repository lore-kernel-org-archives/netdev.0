From: Tom Gundersen <teg@jklm.no>
Subject: [PATCH net-next v9 9/9] net: ppp - set name assign type
Date: Thu, 17 Jul 2014 10:06:10 +0200
Message-ID: <1405584370-30054-10-git-send-email-teg@jklm.no>
References: <1405584370-30054-1-git-send-email-teg@jklm.no>
Cc: David Miller <davem@davemloft.net>, linux-kernel@vger.kernel.org,
	Tom Gundersen <teg@jklm.no>, Paul Mackerras <paulus@samba.org>,
	linux-ppp@vger.kernel.org
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-we0-f173.google.com ([74.125.82.173]:60488 "EHLO
	mail-we0-f173.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755404AbaGQIGk (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 17 Jul 2014 04:06:40 -0400
Received: by mail-we0-f173.google.com with SMTP id q58so2038901wes.32
        for <netdev@vger.kernel.org>; Thu, 17 Jul 2014 01:06:37 -0700 (PDT)
In-Reply-To: <1405584370-30054-1-git-send-email-teg@jklm.no>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The ifname is of the form pppX where X is the unit number. This is either set
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
index c38ee90..6526057 100644
--- a/drivers/net/ppp/ppp_generic.c
+++ b/drivers/net/ppp/ppp_generic.c
@@ -2728,6 +2728,7 @@ ppp_create_interface(struct net *net, int unit, int *retp)
 	/* Initialize the new ppp unit */
 	ppp->file.index = unit;
 	sprintf(dev->name, "ppp%d", unit);
+	dev->name_assign_type = NET_NAME_USER;
 
 	ret = register_netdev(dev);
 	if (ret != 0) {
-- 
1.9.3
