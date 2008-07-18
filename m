From: David Miller <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>
Subject: Re: [PATCH 20/31]: pkt_sched: Perform bulk of qdisc destruction in
 RCU.
Date: Fri, 18 Jul 2008 14:05:39 -0700 (PDT)
Message-ID: <20080718.140539.122169028.davem@davemloft.net>
References: <487FDA67.30902@trash.net>
	<1216386624.4833.94.camel@localhost>
	<1216387641.4833.96.camel@localhost>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: kaber-dcUjhNyLwpNeoWH0uzbU5w@public.gmane.org, netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, johannes-cdvu00un1VgdHxzADdlk8Q@public.gmane.org,
	linux-wireless-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
To: hadi-fAAogVwAN2Kw5LPnMra/2Q@public.gmane.org
Return-path: <linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <1216387641.4833.96.camel@localhost>
Sender: linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

From: jamal <hadi-fAAogVwAN2Kw5LPnMra/2Q@public.gmane.org>
Date: Fri, 18 Jul 2008 09:27:21 -0400

> On Fri, 2008-18-07 at 09:10 -0400, jamal wrote:
> 
> > wire still even on multiple rings;->
> > If Woz (really) showed up at 9am and the Broussards at 3 am[1] on that
> > single (congestion-buffering) FIFO waiting for the shop/wire to open up,
> > then Woz should jump the queue (if he deserves it) when shop opens at
> > 10am.
> 
> Sorry, the url of Woz allegedly jumping the queue:
> http://news.cnet.com/8301-1023_3-9989823-93.html?hhTest=1%C3%A2%C2%88%
> C2%82=rss&subj=news&tag=2547-1_3-0-20

The fundamental issue is what we believe qdiscs schedule, do they
schedule a device, or do they schedule what their namesake implies,
"queues"?

Logically once we have multiple queues, we schedule queues.

Therefore what probably makes sense is that for mostly stateless
priority queueing such as pfifo_fast, doing prioritization at the
queue level is OK.

But where non-trivial classification occurs, we have to either:

1) Make the queue selection match what the classifiers would do
   exactly.

OR

2) Point all the queues at a single device global qdisc.

What we have now implements #2.  Later on we can try to do something
as sophisticated as #1.

--
To unsubscribe from this list: send the line "unsubscribe linux-wireless" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
