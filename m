From: Andi Kleen <ak@suse.de>
Subject: Re: [PATCH, netfilter] NUMA aware ipv4/netfilter/ip_tables.c
Date: Mon, 19 Sep 2005 19:48:54 +0200
Message-ID: <200509191948.55333.ak@suse.de>
References: <432EF0C5.5090908@cosmosbay.com>
Mime-Version: 1.0
Content-Type: text/plain;
  charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, netfilter-devel@lists.netfilter.org
Return-path: <netfilter-devel-bounces@lists.netfilter.org>
To: Eric dumazet <abuse@cosmosbay.com>
In-Reply-To: <432EF0C5.5090908@cosmosbay.com>
Content-Disposition: inline
List-Unsubscribe: <https://lists.netfilter.org/mailman/listinfo/netfilter-devel>,
	<mailto:netfilter-devel-request@lists.netfilter.org?subject=unsubscribe>
List-Archive: </pipermail/netfilter-devel>
List-Post: <mailto:netfilter-devel@lists.netfilter.org>
List-Help: <mailto:netfilter-devel-request@lists.netfilter.org?subject=help>
List-Subscribe: <https://lists.netfilter.org/mailman/listinfo/netfilter-devel>,
	<mailto:netfilter-devel-request@lists.netfilter.org?subject=subscribe>
Sender: netfilter-devel-bounces@lists.netfilter.org
Errors-To: netfilter-devel-bounces@lists.netfilter.org
List-Id: netdev.vger.kernel.org

On Monday 19 September 2005 19:09, Eric dumazet wrote:
> Hi
>
> Part of the performance problem we have with netfilter  is memory
> allocation is not NUMA aware, but 'only' SMP aware.

How do you know? Did you measure it somehow? 

Normally I would expect fire wall state to mostly fit 
into caches (1MB+) of modern Opterons and other NUMA systems.

> What do you think of this patch ?
>
> Note : The allocation function is quite complex (copied from
> drivers/pci/pci-driver.c pci_call_probe())
> because current kernel doesnt have a NUMA aware vmalloc() wrapper

Normal vmalloc is NUMA aware and allocates on the local node.
Like all memory allocations

> , maybe 
> a future kernel will export
> such a common function ?

BTW if you want to put data onto a specific node you don't need
to schedule there - it is enough to set the process mempolicy
with sys_set_mempolicy. This is fine from kernel too, as long
as you save/restore the old one (current->mempolicy) 

-Andi


>
