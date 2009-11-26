From: David Ford <david@blue-labs.org>
Subject: [PATCH] additional update of dev_net(net) to struct *net in ip_fragment.c,
 NULL ptr OOPS
Date: Thu, 26 Nov 2009 05:38:49 -0500
Message-ID: <4B0E5AB9.7000103@blue-labs.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from blue-labs.org ([72.34.249.230]:60782 "EHLO blue-labs.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752638AbZKZLK2 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 26 Nov 2009 06:10:28 -0500
Received: from [10.255.0.3] ([10.255.0.3])
	(authenticated user=david bits=0)
	by colt.blue-labs.org (8.14.3/8.14.3) with ESMTP id nAQAdZx4003074
	(version=TLSv1/SSLv3 cipher=DHE-RSA-AES256-SHA bits=256 verify=NO)
	for <netdev@vger.kernel.org>; Thu, 26 Nov 2009 05:39:37 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

ipv4 ip_frag_reasm(), fully replace 'dev_net(dev)' with 'net', defined
previously patched into 2.6.29.

--- linux-2.6.32-rc8/net/ipv4/ip_fragment.c.orig 2009-09-09
18:13:59.000000000 -0400
+++ linux-2.6.32-rc8/net/ipv4/ip_fragment.c      2009-11-26
05:02:43.000000000 -0500
@@ -563,7 +563,7 @@
                printk(KERN_INFO "Oversized IP packet from %pI4.\n",
                        &qp->saddr);
 out_fail:
-       IP_INC_STATS_BH(dev_net(dev), IPSTATS_MIB_REASMFAILS);
+       IP_INC_STATS_BH(net, IPSTATS_MIB_REASMFAILS);
        return err;
 }

Signed-off-by: David Ford <david@blue-labs.org>



Between 2.6.28.10 and 2.6.29, net/ipv4/ip_fragment.c was patched,
changing from dev_net(dev) to container_of(...).  Unfortunately the goto
section (out_fail) on oversized packets inside ip_frag_reasm() didn't
get touched up as well.  Oversized IP packets cause a NULL pointer
dereference and immediate hang.

I discovered this running openvasd and my previous email on this is
titled:  NULL pointer dereference at 2.6.32-rc8:net/ipv4/ip_fragment.c:566

-david


