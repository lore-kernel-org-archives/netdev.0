From: Matthew Wilcox <willy@debian.org>
Subject: Re: [PATCH] ethtool_ops rev 4
Date: Fri, 1 Aug 2003 16:46:56 +0100
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20030801154656.GW22222@parcelfarce.linux.theplanet.co.uk>
References: <20030801150232.GV22222@parcelfarce.linux.theplanet.co.uk> <20030801154021.GA7696@gtf.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Matthew Wilcox <willy@debian.org>, netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: Jeff Garzik <jgarzik@pobox.com>
Content-Disposition: inline
In-Reply-To: <20030801154021.GA7696@gtf.org>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Fri, Aug 01, 2003 at 11:40:21AM -0400, Jeff Garzik wrote:
> Comments:
> 
> * need SET_ETHTOOL_OPS macro or HAVE_ETHTOOL_OPS test macro or similar

DaveM disagreed with that...

> * I still do not see the need to change a simple storage of a constant
>   (into ethtool_gdrvinfo) into _four_ separate function call hooks (reg
>   dump len, eeprom dump len, nic-specific stats len, self-test len).
>   Internal kernel code that needs this information is always a slow path
>   anyway, so just call the ->get_drvinfo hook internally.

slow path, sure, but increased stack usage.  it's a tradeoff, and this way
feels more clean to me.

> * I prefer not to add '#include <linux/types.h>' to ethtool.h

That means that any code which includes ethtool.h has to include types.h
first (either implicitly or explicitly).  The rule so far has been that
header files should call out their dependencies explictly with an include
of the appropriate file.  So why *don't* you want it?

-- 
"It's not Hollywood.  War is real, war is primarily not about defeat or
victory, it is about death.  I've seen thousands and thousands of dead bodies.
Do you think I want to have an academic debate on this subject?" -- Robert Fisk
