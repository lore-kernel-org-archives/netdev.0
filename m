From: Andrew Morton <akpm@osdl.org>
Subject: Re: [RFC] Limit the size of the IPV4 route hash.
Date: Fri, 10 Dec 2004 15:38:48 -0800
Message-ID: <20041210153848.5acacd0a.akpm@osdl.org>
References: <20041210190025.GA21116@lnx-holt.americas.sgi.com>
	<20041210114829.034e02eb.davem@davemloft.net>
	<20041210210006.GB23222@lnx-holt.americas.sgi.com>
	<20041210130947.1d945422.akpm@osdl.org>
	<20041210232722.GC24468@lnx-holt.americas.sgi.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: holt@sgi.com, davem@davemloft.net, yoshfuji@linux-ipv6.org,
        hirofumi@parknet.co.jp, torvalds@osdl.org, dipankar@ibm.com,
        laforge@gnumonks.org, bunk@stusta.de, herbert@apana.org.au,
        paulmck@ibm.com, netdev@oss.sgi.com, linux-kernel@vger.kernel.org,
        gnb@sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: Robin Holt <holt@sgi.com>
In-Reply-To: <20041210232722.GC24468@lnx-holt.americas.sgi.com>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

Robin Holt <holt@sgi.com> wrote:
>
> > The big risk is that someone has a too-small table for some specific
> > application and their machine runs more slowly than it should, but they
> > never notice.  I wonder if it would be possible to put a little once-only
> > printk into the routing code: "warning route-cache chain exceeded 100
> > entries: consider using the rhash_entries boot option".
> 
> Since the hash gets flushed every 10 seconds, what if we kept track of
> the maximum depth reached and when we reach a certain threshold, just
> allocate a larger hash and replace the old with the new.  I do like the
> printk idea so the admin can prevent inconsistent performance early in
> the run cycle for the system.  We could even scale the hash size up based
> upon demand.

Once the system has been running for a while, the possibility of allocating
a decent number of physically-contiguous pages is basically zero.

If we were to dynamically size it we'd need to either use new data
structure (slower) or use vmalloc() (slower and can fragment vmalloc
space).
