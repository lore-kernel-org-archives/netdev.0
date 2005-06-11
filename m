From: Andi Kleen <ak@muc.de>
Subject: Re: Is kernel 2.6.11 adjust tcp_max_syn_backlog incorrectly?
Date: Sat, 11 Jun 2005 12:25:08 +0200
Message-ID: <m11x79dwcb.fsf@muc.de>
References: <75052be7050606070691c302d@mail.gmail.com>
	<75052be705060607106a6c0882@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: davem@davemloft.net, casavan@sgi.com, linux-kernel@vger.kernel.org,
	netdev@vger.kernel.org
Return-path: <linux-kernel-owner+glk-linux-kernel=40m.gmane.org-S261679AbVFKKZS@vger.kernel.org>
To: Skywind <gnuwind@gmail.com>
In-Reply-To: <75052be705060607106a6c0882@mail.gmail.com> (gnuwind@gmail.com's
 message of "Mon, 6 Jun 2005 22:10:17 +0800")
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Skywind <gnuwind@gmail.com> writes:
>
> It seems that kernel don't adjust these value automatic, is this a bug?
>
> I guess the mechanism of tcp.c in 2.6.11 have some changes(between
> 2.6.10), and it conduce to this result,
> Is this guess correctly?

Yes, there were some changes here when it was converted to a common
function for all hash tables (alloc_large_system_hash - the function
with the argument list from hell).  Anyways, here's a quick fix.

DaveM for your consideration.

Adjust TCP mem order check to new alloc_large_system_hash

Signed-off-by: Andi Kleen <ak@suse.de>

--- linux-2.6.11-work/net/ipv4/tcp.c~	2005-03-02 08:37:51.000000000 +0100
+++ linux-2.6.11-work/net/ipv4/tcp.c	2005-06-11 12:16:22.000000000 +0200
@@ -2337,7 +2337,7 @@
 			(tcp_bhash_size * sizeof(struct tcp_bind_hashbucket));
 			order++)
 		;
-	if (order > 4) {
+	if (order >= 4) {
 		sysctl_local_port_range[0] = 32768;
 		sysctl_local_port_range[1] = 61000;
 		sysctl_tcp_max_tw_buckets = 180000;
