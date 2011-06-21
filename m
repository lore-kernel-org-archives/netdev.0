From: Florian Westphal <fw@strlen.de>
Subject: Re: [PATCH]: Add Network Sysrq Support
Date: Tue, 21 Jun 2011 22:37:20 +0200
Message-ID: <20110621203720.GB16021@Chamillionaire.breakpoint.cc>
References: <20110621130040.12035.62533.sendpatchset@prarit.bos.redhat.com>
 <20110621130929.ddd107f7.rdunlap@xenotime.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Prarit Bhargava <prarit@redhat.com>, netdev@vger.kernel.org,
	davem@davemloft.net, agospoda@redhat.com, nhorman@redhat.com,
	lwoodman@redhat.com
To: Randy Dunlap <rdunlap@xenotime.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from Chamillionaire.breakpoint.cc ([85.10.199.196]:60638 "EHLO
	Chamillionaire.breakpoint.cc" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1757086Ab1FUUhY (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 21 Jun 2011 16:37:24 -0400
Content-Disposition: inline
In-Reply-To: <20110621130929.ddd107f7.rdunlap@xenotime.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Randy Dunlap <rdunlap@xenotime.net> wrote:
> > diff --git a/Documentation/networking/sysrq-ping.txt b/Documentation/networking/sysrq-ping.txt
> > new file mode 100644
> > index 0000000..efa8be3
> > --- /dev/null
> > +++ b/Documentation/networking/sysrq-ping.txt
> > @@ -0,0 +1,26 @@
> > +In some circumstances, a system can hang/lockup in such a way that the system
> > +is completely unresponsive to keyboard or console input but is still
> > +responsive to ping.  The config option, CONFIG_SYSRQ_PING, builds
> > +net/ipv4/sysrq-ping.ko which allows a root user to configure the system for a
> 
> or it can be built-in the kernel image... (i.e., not a loadable module)
> 
> > +remote sysrq.
> > +
> > +To use this do:
> > +
> > +mount -t debugfs none /sys/kernel/debug/
> > +echo 1 > /proc/sys/kernel/sysrq
> > +echo <hex digit val> > /sys/kernel/debug/network_sysrq_magic
> > +echo 1 > /sys/kernel/debug/network_sysrq_enable
> 
> so all of this (insecure) stuff has to be done before you suspect that
> you need it .. in case the local keyboard/console is dead.

There is an xt_SYSREQ module in xtables-addons package (i.e., a
netfilter target), it supports hashed passwords and has some sequence
number scheme to avoid replays.

I think it would make more sense to merge that upstream, simply because
it seems to be a bit more advanced...
