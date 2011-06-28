From: Stephen Hemminger <shemminger@vyatta.com>
Subject: Re: [PATCH] net/core: Convert to current logging forms
Date: Tue, 28 Jun 2011 14:49:23 -0700
Message-ID: <20110628144923.2bdac9f9@nehalam.ftrdhcpuser.net>
References: <385ebf7e98e377e6e6c384beb961b65d4a95fb18.1309289792.git.joe@perches.com>
	<1309292501.2771.48.camel@bwh-desktop>
	<1309293068.29598.14.camel@Joe-Laptop>
	<1309293416.2771.50.camel@bwh-desktop>
	<1309297068.29598.26.camel@Joe-Laptop>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: Ben Hutchings <bhutchings@solarflare.com>, netdev@vger.kernel.org,
	"David S. Miller" <davem@davemloft.net>,
	Neil Horman <nhorman@tuxdriver.com>,
	linux-kernel@vger.kernel.org
To: Joe Perches <joe@perches.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.vyatta.com ([76.74.103.46]:45798 "EHLO mail.vyatta.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751149Ab1F1Vt1 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 28 Jun 2011 17:49:27 -0400
In-Reply-To: <1309297068.29598.26.camel@Joe-Laptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, 28 Jun 2011 14:37:48 -0700
Joe Perches <joe@perches.com> wrote:

> On Tue, 2011-06-28 at 21:36 +0100, Ben Hutchings wrote:
> > On Tue, 2011-06-28 at 13:31 -0700, Joe Perches wrote:
> > > On Tue, 2011-06-28 at 21:21 +0100, Ben Hutchings wrote:
> > > > On Tue, 2011-06-28 at 12:40 -0700, Joe Perches wrote:
> > > > > Use pr_fmt, pr_<level>, and netdev_<level> as appropriate.
> > > > > Coalesce long formats.
> > > > [...]
> > > > > --- a/net/core/dev.c
> > > > > +++ b/net/core/dev.c
> > > > > @@ -72,6 +72,8 @@
> > > > > +#define pr_fmt(fmt) KBUILD_MODNAME ": " fmt
> > > > [...]
> > > > KBUILD_MODNAME is presumably going to be "dev".
> > > 'tis.
> > > > That's not very meaningful.
> > > I think it's not useless though.
> > > Anything else you think it should be?
> > > Maybe "net_core_device:" or some such like that?
> > "netdev"
> > > Here are the format strings now prefaced by "dev:"
> > > $ strings net/core/built-in.o |grep "^<.>dev:"
> > > <6>dev: netif_stop_queue() cannot be called before register_netdev()
> > > <4>dev: dev_remove_pack: %p not found
> > > <3>dev: Loading kernel module for a network device with CAP_SYS_MODULE (deprecated)
> > > <0>dev: %s: failed to move %s to init_net: %d
> > > <3>dev: alloc_netdev: Unable to allocate device with zero queues
> > > <3>dev: alloc_netdev: Unable to allocate device with zero RX queues
> > > <3>dev: alloc_netdev: Unable to allocate device
> > Many of these refer to a specific device and should be formatted with
> > one of the netdev_* logging functions.
> 
> Perhaps another way to do this is like this:
> 
> As soon as alloc_netdev is called, netdev_<level> can
> be used, but the netdev_name() function can contain
> printf formatting control codes like %d.
> 
> Use pr_fmt(fmt) "netdev: " fmt in net/core/dev.c
> Add netdev_is_registered() to netdevice.h
> Extend uses of netdev_name() with netdev_is_registered()
> to show "(unregistered)" as may be necessary.
> Move setting of dev->name in alloc_netdev_mqs to just
> after allocation instead of at end of function.
> 
> (on top of the original patch, will respin if wanted)
> 
> Thoughts?

Does this actually create useful benefit or just create more bug possibilities?
Those messages are mostly self explanatory as is.

