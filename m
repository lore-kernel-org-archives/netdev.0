From: "David S. Miller" <davem@redhat.com>
Subject: Re: [PATCH] ethtool_ops rev 4
Date: Fri, 1 Aug 2003 15:32:55 -0700
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20030801153255.204baf66.davem@redhat.com>
References: <20030801150232.GV22222@parcelfarce.linux.theplanet.co.uk>
	<20030801154021.GA7696@gtf.org>
	<20030801154656.GW22222@parcelfarce.linux.theplanet.co.uk>
	<20030801162536.GA18574@gtf.org>
	<20030801132037.3f3542ae.davem@redhat.com>
	<3F2AE91D.5090705@pobox.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: willy@debian.org, netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: Jeff Garzik <jgarzik@pobox.com>
In-Reply-To: <3F2AE91D.5090705@pobox.com>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Fri, 01 Aug 2003 18:26:37 -0400
Jeff Garzik <jgarzik@pobox.com> wrote:

> Strangely enough, creating a SET_ETHTOOL_OPS() macro (or 
> netif_ethtool_ops or pick your name) reduces ifdefs.

And then we'll have all of these functions present in
the driver, unused, and we'll get tons of warning from
gcc.

The duplication of code is still there, and this is the
main point.

> I feel that I've helped shepherd the net driver and PCI APIs to maintain 
> something fairly interesting:

It's not interesting in this case.

> It's an explicit goal to avoid changing the driver API in such a way 
> that there is a remotely sane path to supporting older kernels.

This enhancement we're talking about basically has no value unless
you accept an appearance of breakage in this particular area.

You can't get rid of the duplicated code without accepting that you
will have seperate 2.6.x and 2.4.x strains of your driver.

If you aren't willing to accept seperate strains of your driver, you
simply don't use netdev_ops.

It is the end of the conversation.

> the few things that is not easily work-around-able is new additions to 
> existing structures (which wouldn't exist in older kernels).  That's 
> what SET_ETHTOOL_OPS would wrap, while also providing a trigger for 
> generic compat glue.

What gets rid of the static functions that do the work when
SET_ETHTOOL_OPS() is a nop?

I do not accept a scheme where the functions stay there in the driver
anyways.  All you seem to be talking about is a compat library which
provides netdev_ops in library form or something silly like that.

> This (IMO) feature continually saves me real time

I don't argue that, just don't use netdev_ops in drivers you
wish to keep doing this with :-)

Look at drivers/net/acenic.c, that's similar to what your drivers will
begin to look like if you don't start accepting a disconnect in
certain areas.
