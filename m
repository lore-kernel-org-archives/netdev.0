From: Joe Perches <joe@perches.com>
Subject: Re: [PATCH 08/10] dynamic_debug: make netif_dbg() call
 __netdev_printk()
Date: Thu, 07 Jul 2011 14:55:33 -0700
Message-ID: <1310075733.2755.5.camel@Joe-Laptop>
References: <cover.1309967232.git.root@dhcp-100-18-164.bos.redhat.com>
	 <889f3300a96f381aee1239ea775014fff26d93c9.1309967232.git.root@dhcp-100-18-164.bos.redhat.com>
	 <1309989543.1710.19.camel@Joe-Laptop> <20110707141259.GA2536@redhat.com>
	 <1310056161.27526.47.camel@Joe-Laptop>  <20110707180909.GC2536@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: gregkh@suse.de, jim.cromie@gmail.com, bvanassche@acm.org,
	linux-kernel@vger.kernel.org, davem@davemloft.net,
	aloisio.almeida@openbossa.org, netdev@vger.kernel.org
To: Jason Baron <jbaron@redhat.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20110707180909.GC2536@redhat.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Thu, 2011-07-07 at 14:09 -0400, Jason Baron wrote:
> On Thu, Jul 07, 2011 at 09:29:21AM -0700, Joe Perches wrote:
> > I think there's little to be gained to move the test
> > outwards and not perform the netif_msg##type(priv)
> In this particualr case, there might not be a large gain, but when I've
> converted all of the dynamic debug infrastructure to jump labels I can
> consistently see througput gains of 1% on tbench testing.

And that's not this case is it.
I don't see any value here.

[]

> I think that dynamic_debug will have continuing
> > impacts on various subsystems unless there's some generic
> > __dynamic_dbg() and _prefix() mechanism introduced into
> > more generic <foo>_dbg style.
> > Anything logging message that uses <foo>_dbg or <foo>_vdbg
> > is a candidate for dynamic_debug uses, but there's no
> > current generic mechanism to avoid subsystem specific needs.
> > Any of these could need some dynamic_debug consideration:
> right. looking quickly over this list there seem to be a few different
> categories:
> -some just alias to dev_dbg(), so they are already picked up
> -some use level logging, this could be easily added to dyanmic debug -
>   we store level info in the descriptor and then check it against
>   a currently set level, which can be per-debug statement

Fine by me.

That might also make all other netif_<type>()
and <foo>_<level>(bitmap or level test, fmt, ...)
possible to combine in this mechanism as well.

There are a lot of those.

> -any ones that can't fit the current model could probably be easily
>  converted using a callback, That is we have some dynamic debug
>  function take an optional function, which if the debugging is enabled
>  is called.

I believe that would require some registration mechanism
for modules.

> In fact, that was one of my original goals was to
> try and convert all the disparate debugging calls, to a more generic
> infrastructure. I know some subsystem converted to use pr_debug(), to
> tie into dynamic debug, but it would take a bit of work to convert the
> rest...thoughts?

Go for it.
You're the ddebug maintainer.
I'm gladly review though.

cheers, Joe
