From: Jeff Garzik <jgarzik@pobox.com>
Subject: Re: [PATCH] ethtool_ops rev 4
Date: Fri, 1 Aug 2003 12:25:36 -0400
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20030801162536.GA18574@gtf.org>
References: <20030801150232.GV22222@parcelfarce.linux.theplanet.co.uk> <20030801154021.GA7696@gtf.org> <20030801154656.GW22222@parcelfarce.linux.theplanet.co.uk>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: Matthew Wilcox <willy@debian.org>
Content-Disposition: inline
In-Reply-To: <20030801154656.GW22222@parcelfarce.linux.theplanet.co.uk>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Fri, Aug 01, 2003 at 04:46:56PM +0100, Matthew Wilcox wrote:
> On Fri, Aug 01, 2003 at 11:40:21AM -0400, Jeff Garzik wrote:
> > Comments:
> > 
> > * need SET_ETHTOOL_OPS macro or HAVE_ETHTOOL_OPS test macro or similar
> 
> DaveM disagreed with that...

It's standard netdevice.h practice, and, he didn't disagree w/ my
rebuttal.

It is needed.


> > * I still do not see the need to change a simple storage of a constant
> >   (into ethtool_gdrvinfo) into _four_ separate function call hooks (reg
> >   dump len, eeprom dump len, nic-specific stats len, self-test len).
> >   Internal kernel code that needs this information is always a slow path
> >   anyway, so just call the ->get_drvinfo hook internally.
> 
> slow path, sure, but increased stack usage.  it's a tradeoff, and this way
> feels more clean to me.

Additing a function hook each time you want to retrieve a new integer
value?  That's feels overly excessive to me.


> > * I prefer not to add '#include <linux/types.h>' to ethtool.h
> 
> That means that any code which includes ethtool.h has to include types.h
> first (either implicitly or explicitly).  The rule so far has been that
> header files should call out their dependencies explictly with an include
> of the appropriate file.  So why *don't* you want it?

Because I copy it to userspace :)

	Jeff
