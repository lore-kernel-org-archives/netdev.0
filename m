From: Krishna Kumar <krkumar@us.ibm.com>
Subject: [PATCH] memory leak in ndisc_router_discovery
Date: Fri, 8 Nov 2002 15:02:15 -0800 (PST)
Sender: netdev-bounce@oss.sgi.com
Message-ID: <200211082302.gA8N2Fv16472@eng2.beaverton.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: linux-kernel@vger.kernel.org, netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: kuznet@ms2.inr.ac.ru, davem@redhat.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

Hi Alexey & Dave,

There is a bug in router advertisement handling code, where the reference
(and memory) to the inet6_dev pointer can get leaked. Following is the patch
to fix it (patch against 2.5.46) :

thanks,

- KK

diff -ruN linux.org/net/ipv6/ndisc.c linux/net/ipv6/ndisc.c
--- linux.org/net/ipv6/ndisc.c	Fri Nov  7 10:02:11 2002
+++ linux/net/ipv6/ndisc.c	Fri Nov  8 14:37:27 2002
@@ -871,6 +871,7 @@
 	}
 
 	if (!ndisc_parse_options(opt, optlen, &ndopts)) {
+		in6_dev_put(in6_dev);
 		if (net_ratelimit())
 			ND_PRINTK2(KERN_WARNING
 				   "ICMP6 RA: invalid ND option, ignored.\n");
