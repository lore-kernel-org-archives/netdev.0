From: Andrew Morton <akpm@osdl.org>
Subject: Re: [patch 2/2] ipvs deadlock fix
Date: Mon, 31 Jan 2005 01:47:22 -0800
Message-ID: <20050131014722.77d732c4.akpm@osdl.org>
References: <200501310633.j0V6X1l01385@mail.osdl.org>
	<20050131093609.GA3804@verge.net.au>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: davem@davemloft.net, netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: Horms <horms@verge.net.au>
In-Reply-To: <20050131093609.GA3804@verge.net.au>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

Horms <horms@verge.net.au> wrote:
>
> On Sun, Jan 30, 2005 at 10:33:02PM -0800, akpm@osdl.org wrote:
>  > 
>  > 
>  > update_defense_level() is calling si_meminfo() from timer context.  But
>  > si_meminfo takes non-irq-safe locks.
>  > 
>  > Move it all to keventd context.  
> 
>  Would I be right in thinking that the offending lock is bdev_lock which
>  is grabbed in nr_blockdev_pages() and thus that this is not an issue
>  for 2.4 whose si_meminfo() does not have such a call?

Yes, 2.4's si_meminfo() seems to be OK from interrupt context.

On x86 - I didn't check the other architectures.
