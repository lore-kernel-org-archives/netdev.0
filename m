From: Thomas Graf <tgraf@suug.ch>
Subject: Re: [PATCH] loop unrolling in net/sched/sch_generic.c
Date: Thu, 7 Jul 2005 23:34:50 +0200
Message-ID: <20050707213450.GB16076@postel.suug.ch>
References: <42CB2698.2080904@cosmosbay.com> <42CB2B84.50702@cosmosbay.com> <20050706124206.GW16076@postel.suug.ch> <20050707.141718.85410359.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: dada1@cosmosbay.com, netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: "David S. Miller" <davem@davemloft.net>
Content-Disposition: inline
In-Reply-To: <20050707.141718.85410359.davem@davemloft.net>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

* David S. Miller <20050707.141718.85410359.davem@davemloft.net> 2005-07-07 14:17
> As an aside, this reminds me that as part of my quest to make
> sk_buff smaller, I intend to walk across the tree and change
> all tests of the form:
> 
> 	if (!skb_queue_len(list))
> 
> into:
> 
> 	if (skb_queue_empty(list))
> 
> [...]
> 
> The cases that do care (mostly packet schedulers) can
> keep track of the queue length themselves in their private data
> structures.  When they remove packets, they _know_ which queue to
> decrement the queue length of.

Since I'm changing the classful qdiscs to use a generic API
for queue management anyway I could take care of this if you want.
WRT the leaf qdiscs it's a bit more complicated since we have
to change the new API to take a new struct which includes the qlen
and the sk_buff_head but not a problem either.
