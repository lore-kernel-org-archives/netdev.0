From: Michal Wrobel <xmxwx@asn.pl>
Subject: [PATCH] IPv6 anycast refcnt fix
Date: Sun, 25 Feb 2007 13:04:21 +0100
Message-ID: <erru08$37g$1@sea.gmane.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-2; format=flowed
Content-Transfer-Encoding: 7bit
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from main.gmane.org ([80.91.229.2]:53414 "EHLO ciao.gmane.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S964828AbXBYMKH (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sun, 25 Feb 2007 07:10:07 -0500
Received: from root by ciao.gmane.org with local (Exim 4.43)
	id 1HLICY-0006tq-1j
	for netdev@vger.kernel.org; Sun, 25 Feb 2007 13:10:02 +0100
Received: from vw54.internetdsl.tpnet.pl ([80.55.178.54])
        by main.gmane.org with esmtp (Gmexim 0.1 (Debian))
        id 1AlnuQ-0007hv-00
        for <netdev@vger.kernel.org>; Sun, 25 Feb 2007 13:10:02 +0100
Received: from xmxwx by vw54.internetdsl.tpnet.pl with local (Gmexim 0.1 (Debian))
        id 1AlnuQ-0007hv-00
        for <netdev@vger.kernel.org>; Sun, 25 Feb 2007 13:10:02 +0100
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

This patch fixes a bug in Linux IPv6 stack which caused anycast address
to be added to a device prior DAD has been completed. This led to
incorrect reference count which resulted in infinite wait for
unregister_netdevice completion on interface removal.

Signed-off-by: Michal Wrobel <xmxwx@asn.pl>

--- linux/net/ipv6/addrconf.c	2007-02-22 19:46:27.000000000 +0100
+++ linux/net/ipv6/addrconf.c	2007-02-25 00:22:37.000000000 +0100
@@ -456,6 +456,8 @@
  			ipv6_dev_mc_dec(dev, &addr);
  	}
  	for (ifa=idev->addr_list; ifa; ifa=ifa->if_next) {
+		if (ifa->flags&IFA_F_TENTATIVE)
+			continue;
  		if (idev->cnf.forwarding)
  			addrconf_join_anycast(ifa);
  		else

