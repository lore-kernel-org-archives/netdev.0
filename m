From: Mel Gorman <mgorman@techsingularity.net>
Subject: Re: [PATCH net-next V2 05/11] net/mlx5e: Support RX multi-packet WQE
 (Striding RQ)
Date: Tue, 19 Apr 2016 18:39:26 +0100
Message-ID: <20160419173833.GB15167@techsingularity.net>
References: <1460928725-18741-1-git-send-email-saeedm@mellanox.com>
 <1460928725-18741-6-git-send-email-saeedm@mellanox.com>
 <1460939371.10638.97.camel@edumazet-glaptop3.roam.corp.google.com>
 <1460983695.10638.113.camel@edumazet-glaptop3.roam.corp.google.com>
 <CALzJLG_W9SkgMBQp86P0WDknw4Kc=DCBrvpPemAUbRX=r4r8Yg@mail.gmail.com>
 <1460989033.10638.120.camel@edumazet-glaptop3.roam.corp.google.com>
 <20160419182532.423d3c05@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=iso-8859-15
Cc: Eric Dumazet <eric.dumazet@gmail.com>,
	Saeed Mahameed <saeedm@dev.mellanox.co.il>,
	Saeed Mahameed <saeedm@mellanox.com>,
	"David S. Miller" <davem@davemloft.net>,
	Linux Netdev List <netdev@vger.kernel.org>,
	Or Gerlitz <ogerlitz@mellanox.com>, Tal Alon <talal@mellanox.com>,
	Tariq Toukan <tariqt@mellanox.com>,
	Eran Ben Elisha <eranbe@mellanox.com>,
	Achiad Shochat <achiad@mellanox.com>, linux-mm <linux-mm@kvack.org>
To: Jesper Dangaard Brouer <brouer@redhat.com>
Return-path: <owner-linux-mm@kvack.org>
Content-Disposition: inline
In-Reply-To: <20160419182532.423d3c05@redhat.com>
Sender: owner-linux-mm@kvack.org
List-Id: netdev.vger.kernel.org

On Tue, Apr 19, 2016 at 06:25:32PM +0200, Jesper Dangaard Brouer wrote:
> On Mon, 18 Apr 2016 07:17:13 -0700
> Eric Dumazet <eric.dumazet@gmail.com> wrote:
> 
> > On Mon, 2016-04-18 at 16:05 +0300, Saeed Mahameed wrote:
> > > On Mon, Apr 18, 2016 at 3:48 PM, Eric Dumazet <eric.dumazet@gmail.com> wrote:  
> > > > On Sun, 2016-04-17 at 17:29 -0700, Eric Dumazet wrote:
> > > >  
> > > >>
> > > >> If really you need to allocate physically contiguous memory, have you
> > > >> considered converting the order-5 pages into 32 order-0 ones ?  
> > > >
> > > > Search for split_page() call sites for examples.
> > > >
> > > >  
> > > 
> > > Thanks Eric, we are already evaluating split_page as we speak.
> > > 
> > > We did look but could not find any specific alloc_pages API that

alloc_pages_exact()

> > > allocates many physically contiguous pages with order0 ! so we assume
> > > it is ok to use split_page.  
> > 
> > Note: I have no idea of split_page() performance :
> 
> Maybe Mel knows?

Irrelevant in comparison to the cost of allocating an order-5 pages if
one is not already available.

> And maybe Mel have an opinion about if this is a good
> or bad approach, e.g. will this approach stress the page allocator in a
> bad way?
> 

It'll contend on the zone lock minimally but again, irrelevant in
comparison to having to reclaim/compact an order-5 page if one is not
already free.

It'll appear to work well in benchmarks and then fall apart when the
system is running for long enough.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
