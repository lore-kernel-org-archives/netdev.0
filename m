From: Jozsef Kadlecsik <kadlec@blackhole.kfki.hu>
Subject: [PATCH] fix netfilter refcounting [was Re: Conntrack leak (2.6.2rc2)]
Date: Tue, 3 Feb 2004 18:43:38 +0100 (CET)
Sender: netfilter-devel-admin@lists.netfilter.org
Message-ID: <Pine.LNX.4.33.0402031825170.11950-100000@blackhole.kfki.hu>
References: <Pine.LNX.4.33.0402031629150.11737-100000@blackhole.kfki.hu>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: <netdev@oss.sgi.com>, <netfilter-devel@lists.netfilter.org>
Return-path: <netfilter-devel-admin@lists.netfilter.org>
To: David Miller <davem@redhat.com>, Steve Hill <steve@navaho.co.uk>
In-Reply-To: <Pine.LNX.4.33.0402031629150.11737-100000@blackhole.kfki.hu>
Errors-To: netfilter-devel-admin@lists.netfilter.org
List-Help: <mailto:netfilter-devel-request@lists.netfilter.org?subject=help>
List-Post: <mailto:netfilter-devel@lists.netfilter.org>
List-Subscribe: <https://lists.netfilter.org/mailman/listinfo/netfilter-devel>,
	<mailto:netfilter-devel-request@lists.netfilter.org?subject=subscribe>
List-Unsubscribe: <https://lists.netfilter.org/mailman/listinfo/netfilter-devel>,
	<mailto:netfilter-devel-request@lists.netfilter.org?subject=unsubscribe>
List-Archive: <https://lists.netfilter.org/pipermail/netfilter-devel/>
List-Id: netdev.vger.kernel.org

Hi Dave,

Steve Hill reported a conntrack leakage in 2.6.2-rc2 when nat is enabled
and the system forwards fragmented packets. It turned out that an
nf_conntrack_put was missing from ip_copy_metadata:

--- a/net/ipv4/ip_output.c	2004-01-09 08:00:12.000000000 +0100
+++ t/net/ipv4/ip_output.c	2004-02-03 18:15:07.000000000 +0100
@@ -414,6 +414,7 @@
 	to->nfmark = from->nfmark;
 	to->nfcache = from->nfcache;
 	/* Connection association is same as pre-frag packet */
+	nf_conntrack_put(to->nfct);
 	to->nfct = from->nfct;
 	nf_conntrack_get(to->nfct);
 #ifdef CONFIG_BRIDGE_NETFILTER

Please apply the patch.

Best regards,
Jozsef
-
E-mail  : kadlec@blackhole.kfki.hu, kadlec@sunserv.kfki.hu
PGP key : http://www.kfki.hu/~kadlec/pgp_public_key.txt
Address : KFKI Research Institute for Particle and Nuclear Physics
          H-1525 Budapest 114, POB. 49, Hungary
