From: Simon Kirby <sim@netnation.com>
Subject: Re: Route cache performance tests
Date: Mon, 16 Jun 2003 16:09:22 -0700
Sender: linux-net-owner@vger.kernel.org
Message-ID: <20030616230922.GC18484@netnation.com>
References: <20030610075732.GD23009@netnation.com> <20030612.232002.41633789.davem@redhat.com> <20030616223714.GB18484@netnation.com> <20030616.154401.132900800.davem@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: ralph+d@istop.com, hadi@shell.cyberus.ca, xerox@foonet.net,
	fw@deneb.enyo.de, netdev@oss.sgi.com, linux-net@vger.kernel.org
Return-path: <linux-net-owner@vger.kernel.org>
To: "David S. Miller" <davem@redhat.com>
Content-Disposition: inline
In-Reply-To: <20030616.154401.132900800.davem@redhat.com>
List-Id: netdev.vger.kernel.org

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

 static int rt_intern_hash(unsigned hash, struct rtable *rt, struct rtable **rp)
 {
        struct rtable   *rth, **rthp;
-       unsigned long   now = jiffies;
-       struct rtable *cand = NULL, **candp = NULL;
...

Simon-
