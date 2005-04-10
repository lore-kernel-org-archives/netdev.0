From: Evgeniy Polyakov <johnpol@2ka.mipt.ru>
Subject: Re: [Fwd: Re: connector is missing in 2.6.12-rc2-mm1]
Date: Sun, 10 Apr 2005 16:15:49 +0400
Message-ID: <20050410161549.3abe4778@zanzibar.2ka.mipt.ru>
References: <1112942924.28858.234.camel@uganda>
	<E1DKZ7e-00070D-00@gondolin.me.apana.org.au>
	<20050410143205.18bff80d@zanzibar.2ka.mipt.ru>
	<1113131325.6994.66.camel@localhost.localdomain>
	<20050410153757.104fe611@zanzibar.2ka.mipt.ru>
	<20050410121005.GF26731@postel.suug.ch>
Reply-To: johnpol@2ka.mipt.ru
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: Kay Sievers <kay.sievers@vrfy.org>,
	Herbert Xu <herbert@gondor.apana.org.au>, jmorris@redhat.com,
	ijc@hellion.org.uk, guillaume.thouvenin@bull.net, greg@kroah.com,
	linux-kernel@vger.kernel.org, akpm@osdl.org, netdev@oss.sgi.com,
	jamal <hadi@cyberus.ca>
Return-path: <linux-kernel-owner+glk-linux-kernel=40m.gmane.org-S261484AbVDJMQl@vger.kernel.org>
To: Thomas Graf <tgraf@suug.ch>
In-Reply-To: <20050410121005.GF26731@postel.suug.ch>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Sun, 10 Apr 2005 14:10:05 +0200
Thomas Graf <tgraf@suug.ch> wrote:

> * Evgeniy Polyakov <20050410153757.104fe611@zanzibar.2ka.mipt.ru> 2005-04-10 15:37
> > --- ./net/netlink/af_netlink.c.orig     2005-04-10 15:46:48.000000000 +0400
> > +++ ./net/netlink/af_netlink.c  2005-04-10 15:47:04.000000000 +0400
> > @@ -747,7 +747,7 @@
> >         if (p->exclude_sk == sk)
> >                 goto out;
> >  
> > -       if (nlk->pid == p->pid || !(nlk->groups & p->group))
> > +       if (nlk->pid == p->pid || (nlk->groups != p->group))
> >                 goto out;
> >  
> >         if (p->failure) {
> 
> Not valid, would break RTMGRP_*.

Yes, it will break too many existing application, 
it would be new API, like do_one_broadcast_direct().
If I understand Kay right, it is what he needs
for the new multicast.

	Evgeniy Polyakov

Only failure makes us experts. -- Theo de Raadt
