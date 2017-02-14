From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH v3 net-next 08/14] mlx4: use order-0 pages for RX
Date: Tue, 14 Feb 2017 14:59:19 -0500 (EST)
Message-ID: <20170214.145919.808498227095540599.davem@davemloft.net>
References: <cd4f3d91-252b-4796-2bd2-3030c18d9ee6@gmail.com>
	<20170214.120426.2032015522492111544.davem@davemloft.net>
	<20170214203822.72d41268@redhat.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: ttoukan.linux@gmail.com, edumazet@google.com,
 alexander.duyck@gmail.com, netdev@vger.kernel.org, tariqt@mellanox.com,
 kafai@fb.com, saeedm@mellanox.com, willemb@google.com,
 bblanco@plumgrid.com, ast@kernel.org, eric.dumazet@gmail.com,
 linux-mm@kvack.org
To: brouer@redhat.com
Return-path: <owner-linux-mm@kvack.org>
In-Reply-To: <20170214203822.72d41268@redhat.com>
Sender: owner-linux-mm@kvack.org
List-Id: netdev.vger.kernel.org

From: Jesper Dangaard Brouer <brouer@redhat.com>
Date: Tue, 14 Feb 2017 20:38:22 +0100

> On Tue, 14 Feb 2017 12:04:26 -0500 (EST)
> David Miller <davem@davemloft.net> wrote:
> 
>> One path I see around all of this is full integration.  Meaning that
>> we can free pages into the page allocator which are still DMA mapped.
>> And future allocations from that device are prioritized to take still
>> DMA mapped objects.
> 
> I like this idea.  Are you saying that this should be done per DMA
> engine or per device?
> 
> If this is per device, it is almost the page_pool idea.  

Per-device is simplest, at least at first.

Maybe later down the road we can try to pool by "mapping entity" be
that a parent IOMMU or something else like a hypervisor managed
page table.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
