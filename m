From: Linus Torvalds <torvalds@osdl.org>
Subject: Re: [BK PATCHES] 2.6.x net driver fixes
Date: Wed, 14 Jul 2004 14:28:11 -0700 (PDT)
Sender: netdev-bounce@oss.sgi.com
Message-ID: <Pine.LNX.4.58.0407141426060.20824@ppc970.osdl.org>
References: <20040714192706.GA24447@havoc.gtf.org>
 <Pine.LNX.4.58.0407141229480.20824@ppc970.osdl.org> <40F58EFD.7080904@pobox.com>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: Andrew Morton <akpm@osdl.org>, netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: Jeff Garzik <jgarzik@pobox.com>
In-Reply-To: <40F58EFD.7080904@pobox.com>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org



On Wed, 14 Jul 2004, Jeff Garzik wrote:
> > 
> > The weaker ordering constraint is called "read_barrier_depends()", and
> > should be a no-op on all but alpha. Would you want to use that to fix the
> > alpha case too?
> 
> What would the proper fix be?
> 
> 	rmb();
> 	read_barrier_depends();

No, just a

	index = *indexpointer;
	read_barrier_depends();
	data = dataptr[index];

which on most architectures is a no-op, but in case the hardware might do
data or address speculation, and needs a dependent load barrier, it will
do the right thing.

For stuff that isn't data dependent, you have to use the full rmb(), which 
obviously isn't a no-op on most setups.

		Linus
