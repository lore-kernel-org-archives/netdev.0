From: Tom Rini <trini@kernel.crashing.org>
Subject: Re: [PATCH 2.6.9] Export phys_cpu_present_map
Date: Wed, 20 Oct 2004 11:16:26 -0700
Sender: linux-mips-bounce@linux-mips.org
Message-ID: <20041020181626.GH12544@smtp.west.cox.net>
References: <20041020171626.GG12544@smtp.west.cox.net> <20041020174905.GA12697@lst.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: linux-mips@linux-mips.org, netdev@oss.sgi.com
Return-path: <linux-mips-bounce@linux-mips.org>
To: Christoph Hellwig <hch@lst.de>
Content-Disposition: inline
In-Reply-To: <20041020174905.GA12697@lst.de>
Errors-to: linux-mips-bounce@linux-mips.org
List-Id: netdev.vger.kernel.org

[ Note that XFS has a similar problem, with cpu_possible() calls ]
On Wed, Oct 20, 2004 at 07:49:05PM +0200, Christoph Hellwig wrote:
> On Wed, Oct 20, 2004 at 10:16:26AM -0700, Tom Rini wrote:
> > In net/ipv6/icmp.c::icmpv6_init() there is a call to cpu_possible()
> > which preprocesses down to "test_bit(((i)), (phys_cpu_present_map).bits)"
> > If ipv6 is a module, phys_cpu_present_map (or cpu_possible_map which is
> > defined t phys_cpu_present_map) needs to be exported.
> 
> The loop in there should be rewritten as for_each_cpu which doesn't need
> this export.

Here's what I did:
--- linux-2.6.9.orig/net/ipv6/icmp.c
+++ linux-2.6.9/net/ipv6/icmp.c
@@ -691,10 +691,7 @@ int __init icmpv6_init(struct net_proto_
 	struct sock *sk;
 	int err, i, j;
 
-	for (i = 0; i < NR_CPUS; i++) {
-		if (!cpu_possible(i))
-			continue;
-
+	for_each_cpu(i) {

But I still get the problem.  Further, on i386 cpu_possible() becomes
cpu_callout_map which is exported as well.

-- 
Tom Rini
http://gate.crashing.org/~trini/
