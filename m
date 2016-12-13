From: David Miller <davem@davemloft.net>
Subject: Re: Designing a safe RX-zero-copy Memory Model for Networking
Date: Tue, 13 Dec 2016 14:53:33 -0500 (EST)
Message-ID: <20161213.145333.514056260418695987.davem@davemloft.net>
References: <alpine.DEB.2.20.1612121200280.13607@east.gentwo.org>
	<20161213171028.24dbf519@redhat.com>
	<5850335F.6090000@gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: brouer@redhat.com, cl@linux.com, rppt@linux.vnet.ibm.com,
 netdev@vger.kernel.org, linux-mm@kvack.org,
 willemdebruijn.kernel@gmail.com, bjorn.topel@intel.com,
 magnus.karlsson@intel.com, alexander.duyck@gmail.com,
 mgorman@techsingularity.net, tom@herbertland.com, bblanco@plumgrid.com,
 tariqt@mellanox.com, saeedm@mellanox.com, jesse.brandeburg@intel.com,
 METH@il.ibm.com, vyasevich@gmail.com
To: john.fastabend@gmail.com
Return-path: <owner-linux-mm@kvack.org>
In-Reply-To: <5850335F.6090000@gmail.com>
Sender: owner-linux-mm@kvack.org
List-Id: netdev.vger.kernel.org

From: John Fastabend <john.fastabend@gmail.com>
Date: Tue, 13 Dec 2016 09:43:59 -0800

> What does "zero-copy send packet-pages to the application/socket that
> requested this" mean? At the moment on x86 page-flipping appears to be
> more expensive than memcpy (I can post some data shortly) and shared
> memory was proposed and rejected for security reasons when we were
> working on bifurcated driver.

The whole idea is that we map all the active RX ring pages into
userspace from the start.

And just how Jesper's page pool work will avoid DMA map/unmap,
it will also avoid changing the userspace mapping of the pages
as well.

Thus avoiding the TLB/VM overhead altogether.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
