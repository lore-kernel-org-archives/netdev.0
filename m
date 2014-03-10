From: Stephen Hemminger <stephen@networkplumber.org>
Subject: [PATCH net-next] bonding: force cast of IP address in options
Date: Mon, 10 Mar 2014 09:48:38 -0700
Message-ID: <20140310094838.6d286cb2@nehalam.linuxnetplumber.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: Jay Vosburgh <fubar@us.ibm.com>,
	Veaceslav Falico <vfalico@redhat.com>,
	Andy Gospodarek <andy@greyhouse.net>,
	David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pd0-f172.google.com ([209.85.192.172]:55165 "EHLO
	mail-pd0-f172.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753667AbaCJQsl (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 10 Mar 2014 12:48:41 -0400
Received: by mail-pd0-f172.google.com with SMTP id p10so7287446pdj.31
        for <netdev@vger.kernel.org>; Mon, 10 Mar 2014 09:48:41 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The option code is taking IP address and putting it into a generic
container. Force cast to silence sparse warnings.

Signed-off-by: Stephen Hemminger <stephen@networkplumber.org>

--- a/drivers/net/bonding/bond_netlink.c	2014-02-17 11:52:24.197945173 -0800
+++ b/drivers/net/bonding/bond_netlink.c	2014-03-10 09:45:36.173443246 -0700
@@ -199,7 +199,7 @@ static int bond_changelink(struct net_de
 		nla_for_each_nested(attr, data[IFLA_BOND_ARP_IP_TARGET], rem) {
 			__be32 target = nla_get_be32(attr);
 
-			bond_opt_initval(&newval, target);
+			bond_opt_initval(&newval, (__force u64)target);
 			err = __bond_opt_set(bond, BOND_OPT_ARP_TARGETS,
 					     &newval);
 			if (err)
