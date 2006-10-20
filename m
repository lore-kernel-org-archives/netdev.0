From: Eric Dumazet <dada1@cosmosbay.com>
Subject: [PATCH] [NET] can use __get_cpu_var() instead of per_cpu() in loopback
 driver
Date: Fri, 20 Oct 2006 09:18:35 +0200
Message-ID: <4538784B.2000306@cosmosbay.com>
References: <20051217071029.GY23384@wotan.suse.de>
 <20051216.231517.68922847.davem@davemloft.net>
 <43A3EE8A.5020907@cosmosbay.com> <43CCBF3D.2070900@cosmosbay.com>
 <4415A4C1.1030906@cosmosbay.com> <452EA214.7080905@cosmosbay.com>
 <4535B6B7.4070107@cosmosbay.com>
Mime-Version: 1.0
Content-Type: multipart/mixed; boundary="Boundary_(ID_K1Qkz0NujmxPe6/Ly+WVNA)"
Cc: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from sp604001mt.neufgp.fr ([84.96.92.60]:21487 "EHLO Smtp.neuf.fr")
	by vger.kernel.org with ESMTP id S2992550AbWJTH1v (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 20 Oct 2006 03:27:51 -0400
Received: from [192.168.30.203] ([84.7.139.149]) by sp604001mt.gpm.neuf.ld
 (Sun Java System Messaging Server 6.2-5.05 (built Feb 16 2006))
 with ESMTP id <0J7F002B4AYYWA00@sp604001mt.gpm.neuf.ld> for
 netdev@vger.kernel.org; Fri, 20 Oct 2006 09:18:35 +0200 (CEST)
In-reply-to: <4535B6B7.4070107@cosmosbay.com>
To: "David S. Miller" <davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

This is a multi-part message in MIME format.

--Boundary_(ID_K1Qkz0NujmxPe6/Ly+WVNA)
Content-type: text/plain; charset=ISO-8859-1; format=flowed
Content-transfer-encoding: 7BIT

As BHs are off in loopback_xmit(), preemption cannot occurs, so we can use 
__get_cpu_var() instead of per_cpu() (and avoid a 
preempt_enable()/preempt_disable() pair)

Signed-off-by: Eric Dumazet <dada1@cosmosbay.com>


--Boundary_(ID_K1Qkz0NujmxPe6/Ly+WVNA)
Content-type: text/plain; name=loopback.patch
Content-transfer-encoding: 7BIT
Content-disposition: inline; filename=loopback.patch

--- net-2.6/drivers/net/loopback.c	2006-10-19 16:46:27.000000000 +0200
+++ net-2.6-ed/drivers/net/loopback.c      2006-10-20 09:11:04.000000000 +0200
@@ -153,14 +153,14 @@
 #endif
 	dev->last_rx = jiffies;
 
-	lb_stats = &per_cpu(pcpu_lstats, get_cpu());
+	/* it's OK to use __get_cpu_var() because BHs are off */
+	lb_stats = &__get_cpu_var(pcpu_lstats);
 	lb_stats->bytes += skb->len;
 	lb_stats->packets++;
-	put_cpu();
 
 	netif_rx(skb);
 
-	return(0);
+	return 0;
 }
 
 static struct net_device_stats loopback_stats;

--Boundary_(ID_K1Qkz0NujmxPe6/Ly+WVNA)--
