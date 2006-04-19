From: "David S. Miller" <davem@davemloft.net>
Subject: Re: [patch] ipv4: initialize arp_tbl rw lock
Date: Wed, 19 Apr 2006 13:12:37 -0700 (PDT)
Message-ID: <20060419.131237.49371772.davem@davemloft.net>
References: <20060408100213.GA9412@osiris.boeblingen.de.ibm.com>
	<20060408031235.5d1989df.akpm@osdl.org>
	<200604191245.48458.borntrae@de.ibm.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: akpm@osdl.org, heiko.carstens@de.ibm.com, shemminger@osdl.org,
	jgarzik@pobox.com, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org, fpavlic@de.ibm.com,
	davem@sunset.davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from dsl027-180-168.sfo1.dsl.speakeasy.net ([216.27.180.168]:21959
	"EHLO sunset.davemloft.net") by vger.kernel.org with ESMTP
	id S1751187AbWDSUMs (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 19 Apr 2006 16:12:48 -0400
To: borntrae@de.ibm.com
In-Reply-To: <200604191245.48458.borntrae@de.ibm.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Christian Borntraeger <borntrae@de.ibm.com>
Date: Wed, 19 Apr 2006 12:45:48 +0200

> As spinlock debugging still does not work with the qeth driver I
> want to pick up the discussion.

Does something like the patch below work?

But this all begs the question, what happens if you want to
dig into the internals of a protocol which is built modular and
hasn't been loaded yet?

diff --git a/include/linux/init.h b/include/linux/init.h
index 93dcbe1..8169f25 100644
--- a/include/linux/init.h
+++ b/include/linux/init.h
@@ -95,8 +95,9 @@ #define postcore_initcall(fn)		__define_
 #define arch_initcall(fn)		__define_initcall("3",fn)
 #define subsys_initcall(fn)		__define_initcall("4",fn)
 #define fs_initcall(fn)			__define_initcall("5",fn)
-#define device_initcall(fn)		__define_initcall("6",fn)
-#define late_initcall(fn)		__define_initcall("7",fn)
+#define net_initcall(fn)		__define_initcall("6",fn)
+#define device_initcall(fn)		__define_initcall("7",fn)
+#define late_initcall(fn)		__define_initcall("8",fn)
 
 #define __initcall(fn) device_initcall(fn)
 
diff --git a/net/ipv4/af_inet.c b/net/ipv4/af_inet.c
index dc206f1..9803a57 100644
--- a/net/ipv4/af_inet.c
+++ b/net/ipv4/af_inet.c
@@ -1257,7 +1257,7 @@ out_unregister_udp_proto:
 	goto out;
 }
 
-module_init(inet_init);
+net_initcall(inet_init);
 
 /* ------------------------------------------------------------------------ */
 
