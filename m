From: "David S. Miller" <davem@davemloft.net>
Subject: Re: [BUG] overflow in net/ipv4/route.c rt_check_expire()
Date: Fri, 1 Apr 2005 13:08:32 -0800
Message-ID: <20050401130832.1f972a3b.davem@davemloft.net>
References: <42370997.6010302@cosmosbay.com>
	<20050315103253.590c8bfc.davem@davemloft.net>
	<42380EC6.60100@cosmosbay.com>
	<20050316140915.0f6b9528.davem@davemloft.net>
	<4239E00C.4080309@cosmosbay.com>
	<20050331221352.13695124.davem@davemloft.net>
	<424D5D34.4030800@cosmosbay.com>
	<20050401122802.7c71afbc.davem@davemloft.net>
	<424DB7A1.8090803@cosmosbay.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: Eric Dumazet <dada1@cosmosbay.com>
In-Reply-To: <424DB7A1.8090803@cosmosbay.com>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Fri, 01 Apr 2005 23:05:37 +0200
Eric Dumazet <dada1@cosmosbay.com> wrote:

> You mean you prefer :
> 
> static spinlock_t   *rt_hash_lock ; /* rt_hash_lock =
> alloc_memory_at_boot_time(...) */
> 
> instead of
> 
> static spinlock_t rt_hash_lock[RT_HASH_LOCK_SZ] ;
> 
> In both cases, memory is taken from lowmem, and size of kernel image
> is roughly the same (bss section takes no space in image)

In the former case the kernel image the bootloader has to
load is smaller.  That's important, believe it or not.  It
means less TLB entries need to be locked permanently into
the MMU on certain platforms.
