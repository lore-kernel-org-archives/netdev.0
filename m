From: Saeed Mahameed <saeedm@dev.mellanox.co.il>
Subject: Re: [PATCH net-next V2 05/11] net/mlx5e: Support RX multi-packet WQE
 (Striding RQ)
Date: Wed, 20 Apr 2016 19:46:12 +0300
Message-ID: <CALzJLG-XwPv_V51nHBxQQcsiWG20sHj0OvVacc0eVLhoQF2c8g@mail.gmail.com>
References: <1460928725-18741-1-git-send-email-saeedm@mellanox.com>
 <1460928725-18741-6-git-send-email-saeedm@mellanox.com> <1460939371.10638.97.camel@edumazet-glaptop3.roam.corp.google.com>
 <1460983695.10638.113.camel@edumazet-glaptop3.roam.corp.google.com>
 <CALzJLG_W9SkgMBQp86P0WDknw4Kc=DCBrvpPemAUbRX=r4r8Yg@mail.gmail.com>
 <1460989033.10638.120.camel@edumazet-glaptop3.roam.corp.google.com>
 <20160419182532.423d3c05@redhat.com> <20160419173833.GB15167@techsingularity.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: Jesper Dangaard Brouer <brouer@redhat.com>, Eric Dumazet <eric.dumazet@gmail.com>,
	Saeed Mahameed <saeedm@mellanox.com>, "David S. Miller" <davem@davemloft.net>,
	Linux Netdev List <netdev@vger.kernel.org>, Or Gerlitz <ogerlitz@mellanox.com>,
	Tal Alon <talal@mellanox.com>, Tariq Toukan <tariqt@mellanox.com>,
	Eran Ben Elisha <eranbe@mellanox.com>, Achiad Shochat <achiad@mellanox.com>, linux-mm <linux-mm@kvack.org>
To: Mel Gorman <mgorman@techsingularity.net>
Return-path: <owner-linux-mm@kvack.org>
In-Reply-To: <20160419173833.GB15167@techsingularity.net>
Sender: owner-linux-mm@kvack.org
List-Id: netdev.vger.kernel.org

On Tue, Apr 19, 2016 at 8:39 PM, Mel Gorman <mgorman@techsingularity.net> wrote:
> On Tue, Apr 19, 2016 at 06:25:32PM +0200, Jesper Dangaard Brouer wrote:
>> On Mon, 18 Apr 2016 07:17:13 -0700
>> Eric Dumazet <eric.dumazet@gmail.com> wrote:
>>
>
> alloc_pages_exact()
>

We want to allocate 32 order-0 physically contiguous pages and to free
each one of them individually.
the documentation states "Memory allocated by this function must be
released by free_pages_exact()"

Also it returns a pointer to the memory and we need pointers to pages.

>> > > allocates many physically contiguous pages with order0 ! so we assume
>> > > it is ok to use split_page.
>> >
>> > Note: I have no idea of split_page() performance :
>>
>> Maybe Mel knows?
>
> Irrelevant in comparison to the cost of allocating an order-5 pages if
> one is not already available.
>

we still allocate order-5 pages but now we split them to 32 order-0 pages.
the split adds extra few cpu cycles but it is lookless and
straightforward, and it does the job in terms of better memory
utilization.
now in scenarios where small packets can hold a ref on pages for too
long they would hold a ref on order-0 pages rather than order-5.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
