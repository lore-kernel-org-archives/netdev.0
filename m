From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH v3 net-next 08/14] mlx4: use order-0 pages for RX
Date: Tue, 14 Feb 2017 12:22:31 -0500 (EST)
Message-ID: <20170214.122231.2022548659001388286.davem@davemloft.net>
References: <cd4f3d91-252b-4796-2bd2-3030c18d9ee6@gmail.com>
	<20170214.120426.2032015522492111544.davem@davemloft.net>
	<063D6719AE5E284EB5DD2968C1650D6DCFE63512@AcuExch.aculab.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: ttoukan.linux@gmail.com, edumazet@google.com, brouer@redhat.com,
 alexander.duyck@gmail.com, netdev@vger.kernel.org, tariqt@mellanox.com,
 kafai@fb.com, saeedm@mellanox.com, willemb@google.com,
 bblanco@plumgrid.com, ast@kernel.org, eric.dumazet@gmail.com,
 linux-mm@kvack.org
To: David.Laight@ACULAB.COM
Return-path: <owner-linux-mm@kvack.org>
In-Reply-To: <063D6719AE5E284EB5DD2968C1650D6DCFE63512@AcuExch.aculab.com>
Sender: owner-linux-mm@kvack.org
List-Id: netdev.vger.kernel.org

From: David Laight <David.Laight@ACULAB.COM>
Date: Tue, 14 Feb 2017 17:17:22 +0000

> From: David Miller
>> Sent: 14 February 2017 17:04
> ...
>> One path I see around all of this is full integration.  Meaning that
>> we can free pages into the page allocator which are still DMA mapped.
>> And future allocations from that device are prioritized to take still
>> DMA mapped objects.
> ...
> 
> For systems with 'expensive' iommu has anyone tried separating the
> allocation of iommu resource (eg page table slots) from their
> assignment to physical pages?
> 
> Provided the page sizes all match, setting up a receive buffer might
> be as simple as writing the physical address into the iommu slot
> that matches the ring entry.
> 
> Or am I thinking about hardware that is much simpler than real life?

You still will eat an expensive MMIO or hypervisor call to setup the
mapping.

IOMMU is expensive because of two operations, the slot allocation
(which takes locks) and the modification of the IOMMU PTE to setup
or teardown the mapping.

This is why attempts to preallocate slots (which people have looked
into) never really takes off.  You really have to eliminate the
entire operation to get worthwhile gains.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
