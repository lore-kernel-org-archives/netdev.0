From: Horms <horms@verge.net.au>
Subject: Re: [patch 2/2] ipvs deadlock fix
Date: Mon, 31 Jan 2005 12:36:10 +0300
Message-ID: <20050131093609.GA3804@verge.net.au>
References: <200501310633.j0V6X1l01385@mail.osdl.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: davem@davemloft.net, netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: akpm@osdl.org
Content-Disposition: inline
In-Reply-To: <200501310633.j0V6X1l01385@mail.osdl.org>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Sun, Jan 30, 2005 at 10:33:02PM -0800, akpm@osdl.org wrote:
> 
> 
> update_defense_level() is calling si_meminfo() from timer context.  But
> si_meminfo takes non-irq-safe locks.
> 
> Move it all to keventd context.  

Would I be right in thinking that the offending lock is bdev_lock which
is grabbed in nr_blockdev_pages() and thus that this is not an issue
for 2.4 whose si_meminfo() does not have such a call?

-- 
Horms
