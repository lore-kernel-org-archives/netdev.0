From: Ville Nuorvala <vnuorval@tcs.hut.fi>
Subject: [PATCH] IPv6: fix saddr checking bug in datagram_send_ctl()
Date: Wed, 21 Jan 2004 17:03:07 +0200 (EET)
Sender: linux-net-owner@vger.kernel.org
Message-ID: <Pine.LNX.4.58.0401211657160.29787@rhea.tcs.hut.fi>
References: <1074683199.1172.26.camel@simulacron>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: netdev@oss.sgi.com, linux-net@vger.kernel.org
Return-path: <linux-net-owner@vger.kernel.org>
To: davem@redhat.com, Andreas Jellinghaus <aj@dungeon.inka.de>
In-Reply-To: <1074683199.1172.26.camel@simulacron>
List-Id: netdev.vger.kernel.org

Hi Dave,

I'm sorry, a bug had slipped into my link-local checking patch, which
Andreas noticed.

Here is the fix.

Thanks,
Ville

===== net/ipv6/datagram.c 1.12 vs edited =====
--- 1.12/net/ipv6/datagram.c	Tue Jan 20 07:37:47 2004
+++ edited/net/ipv6/datagram.c	Wed Jan 21 16:55:39 2004
@@ -295,7 +295,7 @@

 			addr_type = ipv6_addr_type(&src_info->ipi6_addr);

-			if (ipv6_addr_type == IPV6_ADDR_ANY)
+			if (addr_type == IPV6_ADDR_ANY)
 				break;

 			if (addr_type & IPV6_ADDR_LINKLOCAL) {

--
Ville Nuorvala
Research Assistant, Institute of Digital Communications,
Helsinki University of Technology
email: vnuorval@tcs.hut.fi, phone: +358 (0)9 451 5257
