From: "David S. Miller" <davem@redhat.com>
Subject: Re: Route cache performance tests
Date: Mon, 16 Jun 2003 16:08:56 -0700 (PDT)
Sender: linux-net-owner@vger.kernel.org
Message-ID: <20030616.160856.35828947.davem@redhat.com>
References: <20030616223714.GB18484@netnation.com>
	<20030616.154401.132900800.davem@redhat.com>
	<20030616230922.GC18484@netnation.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: ralph+d@istop.com, hadi@shell.cyberus.ca, xerox@foonet.net,
	fw@deneb.enyo.de, netdev@oss.sgi.com, linux-net@vger.kernel.org
Return-path: <linux-net-owner@vger.kernel.org>
To: sim@netnation.com
In-Reply-To: <20030616230922.GC18484@netnation.com>
List-Id: netdev.vger.kernel.org

   From: Simon Kirby <sim@netnation.com>
   Date: Mon, 16 Jun 2003 16:09:22 -0700

   On Mon, Jun 16, 2003 at 03:44:01PM -0700, David S. Miller wrote:
   
   > I pushed all of our current work to Linus's tree.
   > But for your convenience here are the routing diffs
   > against plain 2.5.71
   
   Trying to apply against 2.5.71:
   
   patching file net/ipv4/route.c
   Hunk #2 succeeded at 454 (offset -2 lines).
   Hunk #3 succeeded at 738 (offset -2 lines).
   Hunk #4 succeeded at 775 (offset -2 lines).
   patching file net/ipv4/route.c
   Hunk #1 FAILED at 739.
   1 out of 1 hunk FAILED -- saving rejects to file net/ipv4/route.c.rej
   
   Trying to apply against 2.5.71-bk2:
   
   patching file net/ipv4/route.c
   patching file net/ipv4/route.c
   Hunk #1 FAILED at 739.
   1 out of 1 hunk FAILED -- saving rejects to file net/ipv4/route.c.rej
   
   Missing something between?
   
   Code from bk2:
   
   static int rt_intern_hash(unsigned hash, struct rtable *rt, struct rtable **rp)
   {
           struct rtable   *rth, **rthp;
           unsigned long   now = jiffies;
           int attempts = !in_softirq();
   
   Patch:
   
It depends upon the first patch that I enclosed.
What I gave you was a 2-part patch, the first one
did:

@@ -721,6 +740,9 @@
 {
 	struct rtable	*rth, **rthp;
 	unsigned long	now = jiffies;
+	struct rtable *cand = NULL, **candp = NULL;
+	u32 		min_score = ~(u32)0;
+	int		chain_length = 0;
 	int attempts = !in_softirq();
 
 restart:

The second one did:

@@ -739,13 +739,19 @@
 static int rt_intern_hash(unsigned hash, struct rtable *rt, struct rtable **rp)
 {
 	struct rtable	*rth, **rthp;
-	unsigned long	now = jiffies;
-	struct rtable *cand = NULL, **candp = NULL;
-	u32 		min_score = ~(u32)0;
-	int		chain_length = 0;
+	unsigned long	now;
+	struct rtable *cand, **candp;
+	u32 		min_score;
+	int		chain_length;
 	int attempts = !in_softirq();
 
...

I have no idea why it doesn't apply.
Nothing else has happened in these bits of code for a while.
