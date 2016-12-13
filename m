From: John Fastabend <john.fastabend@gmail.com>
Subject: Re: Designing a safe RX-zero-copy Memory Model for Networking
Date: Tue, 13 Dec 2016 12:08:21 -0800
Message-ID: <58505535.1080908@gmail.com>
References: <alpine.DEB.2.20.1612121200280.13607@east.gentwo.org>
 <20161213171028.24dbf519@redhat.com> <5850335F.6090000@gmail.com>
 <20161213.145333.514056260418695987.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252
Content-Transfer-Encoding: 7bit
Cc: brouer@redhat.com, cl@linux.com, rppt@linux.vnet.ibm.com,
 netdev@vger.kernel.org, linux-mm@kvack.org, willemdebruijn.kernel@gmail.com,
 bjorn.topel@intel.com, magnus.karlsson@intel.com, alexander.duyck@gmail.com,
 mgorman@techsingularity.net, tom@herbertland.com, bblanco@plumgrid.com,
 tariqt@mellanox.com, saeedm@mellanox.com, jesse.brandeburg@intel.com,
 METH@il.ibm.com, vyasevich@gmail.com
To: David Miller <davem@davemloft.net>
Return-path: <owner-linux-mm@kvack.org>
In-Reply-To: <20161213.145333.514056260418695987.davem@davemloft.net>
Sender: owner-linux-mm@kvack.org
List-Id: netdev.vger.kernel.org

On 16-12-13 11:53 AM, David Miller wrote:
> From: John Fastabend <john.fastabend@gmail.com>
> Date: Tue, 13 Dec 2016 09:43:59 -0800
> 
>> What does "zero-copy send packet-pages to the application/socket that
>> requested this" mean? At the moment on x86 page-flipping appears to be
>> more expensive than memcpy (I can post some data shortly) and shared
>> memory was proposed and rejected for security reasons when we were
>> working on bifurcated driver.
> 
> The whole idea is that we map all the active RX ring pages into
> userspace from the start.
> 
> And just how Jesper's page pool work will avoid DMA map/unmap,
> it will also avoid changing the userspace mapping of the pages
> as well.
> 
> Thus avoiding the TLB/VM overhead altogether.
> 

I get this but it requires applications to be isolated. The pages from
a queue can not be shared between multiple applications in different
trust domains. And the application has to be cooperative meaning it
can't "look" at data that has not been marked by the stack as OK. In
these schemes we tend to end up with something like virtio/vhost or
af_packet.

Any ACLs/filtering/switching/headers need to be done in hardware or
the application trust boundaries are broken.

If the above can not be met then a copy is needed. What I am trying
to tease out is the above comment along with other statements like
this "can be done with out HW filter features".

.John

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
