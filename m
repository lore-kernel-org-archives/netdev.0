From: Saeed Mahameed <saeedm@dev.mellanox.co.il>
Subject: Re: [PATCH net-next V2 05/11] net/mlx5e: Support RX multi-packet WQE
 (Striding RQ)
Date: Tue, 19 Apr 2016 21:30:42 +0300
Message-ID: <CALzJLG-+PNrAOghxiGdTHovMQdE3-iHC-Z4ADGF1Q_80FG3BqA@mail.gmail.com>
References: <1460928725-18741-1-git-send-email-saeedm@mellanox.com>
 <1460928725-18741-6-git-send-email-saeedm@mellanox.com> <1460939371.10638.97.camel@edumazet-glaptop3.roam.corp.google.com>
 <1460983695.10638.113.camel@edumazet-glaptop3.roam.corp.google.com>
 <CALzJLG_W9SkgMBQp86P0WDknw4Kc=DCBrvpPemAUbRX=r4r8Yg@mail.gmail.com>
 <1460989033.10638.120.camel@edumazet-glaptop3.roam.corp.google.com> <20160419182532.423d3c05@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: Eric Dumazet <eric.dumazet@gmail.com>, Saeed Mahameed <saeedm@mellanox.com>,
	"David S. Miller" <davem@davemloft.net>, Linux Netdev List <netdev@vger.kernel.org>,
	Or Gerlitz <ogerlitz@mellanox.com>, Tal Alon <talal@mellanox.com>,
	Tariq Toukan <tariqt@mellanox.com>, Eran Ben Elisha <eranbe@mellanox.com>,
	Achiad Shochat <achiad@mellanox.com>, Mel Gorman <mgorman@techsingularity.net>,
	linux-mm <linux-mm@kvack.org>
To: Jesper Dangaard Brouer <brouer@redhat.com>
Return-path: <owner-linux-mm@kvack.org>
In-Reply-To: <20160419182532.423d3c05@redhat.com>
Sender: owner-linux-mm@kvack.org
List-Id: netdev.vger.kernel.org

On Tue, Apr 19, 2016 at 7:25 PM, Jesper Dangaard Brouer
<brouer@redhat.com> wrote:
> On Mon, 18 Apr 2016 07:17:13 -0700
> Eric Dumazet <eric.dumazet@gmail.com> wrote:
>
>> Another idea would be to have a way to control max number of order-5
>> pages that a port would be using.
>>
>> Since driver always own a ref on a order-5 pages, idea would be to
>> maintain a circular ring of up to XXX such pages, so that we can detect
>> an abnormal use and fallback to order-0 immediately.
>
> That is part of my idea with my page-pool proposal.  In the page-pool I
> want to have some watermark counter that can block/stop the OOM issue at
> this RX ring level.
>
> See slide 12 of presentation:
> http://people.netfilter.org/hawk/presentations/MM-summit2016/generic_page_pool_mm_summit2016.pdf
>

Cool Idea guys, and we already tested our own version of it,
we tried to recycle our own driver pages but we saw that the stack
took too long to release them, we had to work with 2X and sometimes 4X
pages pool per ring to be able to reuse recycled pages on every RX
packet on 50Gb line rate, but we dropped the Idea since 2X is too
much.

but definitely, this is the best way to go for all drivers, reusing
already dma mapped pages and significantly reducing dma operations for
the driver is a big win !
we are still considering such option as future optimization.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
