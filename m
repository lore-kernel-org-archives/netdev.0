From: Jeff Garzik <jgarzik@pobox.com>
Subject: Re: [PATCH] sdla non-module build fix.
Date: Mon, 8 Sep 2003 13:36:44 -0400
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20030908173644.GA22629@gtf.org>
References: <20030908095708.107b98c4.shemminger@osdl.org> <Pine.LNX.4.44.0309081030310.15082-100000@home.osdl.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Stephen Hemminger <shemminger@osdl.org>, netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: Linus Torvalds <torvalds@osdl.org>
Content-Disposition: inline
In-Reply-To: <Pine.LNX.4.44.0309081030310.15082-100000@home.osdl.org>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Mon, Sep 08, 2003 at 10:32:26AM -0700, Linus Torvalds wrote:
> 
> On Mon, 8 Sep 2003, Stephen Hemminger wrote:
> >
> > Last round of changes broke sdla build if not a module.
> 
> This patch can't be right. It may fix the compile, but it looks like 
> init/exit_sdla is never registered at all if it's built-in.
> 
> I suspect the whole #ifdef should go away. A driver that does things 
> differently depending on whether it is a module or not is generally a 
> _broken_ driver.

Nope, this is one of those weird two-ways-of-initialization things, like
drivers/net/Space.c or drivers/video/fbmem.c.  If you look at the sdla
code, just above where Stephen's patch's context ends, you see
"sdla_init" which is called by both modular and non-modular code.

So -- with the exception of #ifdef'ing out MODULE_LICENSE, Stephen's
patch is ok.

Now that said, this situation is only temporary, until we get all the
network device structs being allocated dynamically, and interface
ordering issues are resolved.  Once that happens, you are absolutely
right:  sdla's #ifdef MODULE should be removed.

	Jeff
