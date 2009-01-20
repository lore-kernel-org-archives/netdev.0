From: Evgeniy Polyakov <zbr@ioremap.net>
Subject: Re: [PATCH] tcp: splice as many packets as possible at once
Date: Tue, 20 Jan 2009 15:11:15 +0300
Message-ID: <20090120121115.GA17277@ioremap.net>
References: <20090115.153449.204259387.davem@davemloft.net> <20090115234255.GE1123@1wt.eu> <20090115234408.GA1693@1wt.eu> <20090115.155434.206643894.davem@davemloft.net> <20090119004206.GA10396@1wt.eu> <4975BD09.3020103@zeus.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Willy Tarreau <w@1wt.eu>, David Miller <davem@davemloft.net>,
	herbert@gondor.apana.org.au, jarkao2@gmail.com,
	dada1@cosmosbay.com, mingo@elte.hu, linux-kernel@vger.kernel.org,
	netdev@vger.kernel.org, jens.axboe@oracle.com
To: Ben Mansell <ben@zeus.com>
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S1761160AbZATML3@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <4975BD09.3020103@zeus.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Tue, Jan 20, 2009 at 12:01:13PM +0000, Ben Mansell (ben@zeus.com) wrote:
> I've also tested on the same three patches (against 2.6.27.2 here), and 
> the patches appear to work just fine. I'm running a similar proxy 
> benchmark test to Willy, on a machine with 4 gigabit NICs (2xtg3, 
> 2xforcedeth). splice is working OK now, although I get identical results 
> when using splice() or read()/write(): 2.4 Gbps at 100% CPU (2% user, 
> 98% system).

With small MTU or when driver does not support fragmented allocation
(iirc at least forcedeth does not) skb will contain all the data in the
linear part and thus will be copied in the kernel. read()/write() does
effectively the same, but in userspace.
This should only affect splice usage which involves socket->pipe data
transfer.

> I may be hitting a h/w limitation which prevents any higher throughput, 
> but I'm a little surprised that splice() didn't use less CPU time. 
> Anyway, the splice code is working which is the important part!

Does splice without patches (but with performance improvement for
non-blocking splice) has the same performance? It does not copy data,
but you may hit the data corruption? If performance is the same, this
maybe indeed HW limitation.

-- 
	Evgeniy Polyakov
