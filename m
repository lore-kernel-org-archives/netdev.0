From: Ville Nuorvala <vnuorval@tcs.hut.fi>
Subject: [PATCH|RFC] IPv6: Equal behavior in addrconf_sysctl_forward() and
 addrconf_sysctl_forward_strategy()
Date: Thu, 22 Jan 2004 12:59:07 +0200 (EET)
Sender: netdev-bounce@oss.sgi.com
Message-ID: <Pine.LNX.4.58.0401221253040.1098@rhea.tcs.hut.fi>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: davem@redhat.com, yoshfuji@linux-ipv6.org
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

Hi guys,

is there any reason for _forward() to call rt6_purge_dflt_routers(), but
_forward_strategy() not do the same?

If no, the patch below should fix this.

Thanks,
Ville

===== net/ipv6/addrconf.c 1.86 vs edited =====
--- 1.86/net/ipv6/addrconf.c	Tue Jan 20 06:59:54 2004
+++ edited/net/ipv6/addrconf.c	Thu Jan 22 12:22:21 2004
@@ -3030,6 +3030,9 @@
 			idev = NULL;
 		*valp = new;
 		addrconf_forward_change(idev);
+
+		if (*valp)
+			rt6_purge_dflt_routers(0);
 	} else
 		*valp = new;


--
Ville Nuorvala
Research Assistant, Institute of Digital Communications,
Helsinki University of Technology
email: vnuorval@tcs.hut.fi, phone: +358 (0)9 451 5257
