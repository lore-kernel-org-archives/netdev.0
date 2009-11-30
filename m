From: David Ford <david@blue-labs.org>
Subject: Re: [PATCH] additional update of dev_net(dev) to struct *net in ip_fragment.c,
 NULL ptr OOPS
Date: Sun, 29 Nov 2009 20:27:37 -0500
Message-ID: <4B131F89.4010906@blue-labs.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
To: davem@davemloft.net, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from blue-labs.org ([72.34.249.230]:45885 "EHLO blue-labs.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753027AbZK3B22 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sun, 29 Nov 2009 20:28:28 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

ipv4 ip_frag_reasm(), fully replace 'dev_net(dev)' with 'net', defined
previously patched into 2.6.29.

--- linux-2.6.32-rc8/net/ipv4/ip_fragment.c.orig 2009-09-09 18:13:59.000000000 -0400
+++ linux-2.6.32-rc8/net/ipv4/ip_fragment.c      2009-11-26 05:02:43.000000000 -0500
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


