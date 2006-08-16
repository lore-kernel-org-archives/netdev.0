From: Thomas Graf <tgraf@suug.ch>
Subject: Re: [PATCH 09/16] [IPv6] address: Convert address notification to use rtnl_notify()
Date: Wed, 16 Aug 2006 13:40:03 +0200
Message-ID: <20060816114003.GY14627@postel.suug.ch>
References: <20060815122300.GV14627@postel.suug.ch> <E1GDBbw-0006Kz-00@gondolin.me.apana.org.au> <20060816105856.GW14627@postel.suug.ch> <20060816111240.GA28846@gondor.apana.org.au>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: hasso@estpak.ee, kuznet@ms2.inr.ac.ru, hadi@cyberus.ca,
	davem@davemloft.net, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from postel.suug.ch ([194.88.212.233]:33169 "EHLO postel.suug.ch")
	by vger.kernel.org with ESMTP id S1751109AbWHPLjn (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 16 Aug 2006 07:39:43 -0400
To: Herbert Xu <herbert@gondor.apana.org.au>
Content-Disposition: inline
In-Reply-To: <20060816111240.GA28846@gondor.apana.org.au>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

* Herbert Xu <herbert@gondor.apana.org.au> 2006-08-16 21:12
> On Wed, Aug 16, 2006 at 12:58:56PM +0200, Thomas Graf wrote:
> > 
> > All route and tc notifications already use the pid so applications
> > can decide whether the event was caused by them. A notification
> > is a reply to a request so it doesn't even violate RFC 2367.
> 
> Actually most IPv4 notifications *do* set the pid to zero which is
> the right thing to do for kernel-generated messages.
> 
> You're right though that the IPv6 notification modified by this patch
> does set the pid to the netlink originator.  Looking back in history
> it seems that this behaviour was only introduced last year to a subset
> of notifications.

It was added to help quagga identify which route modifications
are self caused. It's not possible to use rtm_protocol for this
purpose as other applications can delete routes added by quagga.

> This inconsistency is very bad.  IMHO this change (made last year)
> should be reverted so that all kernel generated (broadcast) notifications
> have the originator set to zero to match the source address of the
> message.

We can't just knowingly break quagga.

I think it's a good thing to include the pid, it's additional
information that is helpful to userspace. Userspace is already
aware that the notifications are orignating from the kernel,
we can't do userspace -> userspace communication anymore anyway.

> Any notification that sets the netlink pid to current->pid is
> *completely* bogus.  Let me repeat this, the netlink pid is not
> a process ID.

Everyone is aware of that, actually these patches fix all
occurences of current->pid by replacing them with a pid of 0.
