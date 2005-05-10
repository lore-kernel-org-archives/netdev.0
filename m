From: Dmitry Torokhov <dmitry.torokhov@gmail.com>
Subject: Re: [1/1] connector/CBUS: new messaging subsystem. Revision number next.
Date: Tue, 10 May 2005 09:56:45 -0500
Message-ID: <d120d500050510075671efe331@mail.gmail.com>
References: <20050411125932.GA19538@uganda.factory.vocord.ru>
	 <200505100118.48027.dtor_core@ameritech.net>
	 <20050510140445.36cc15cb@zanzibar.2ka.mipt.ru>
Reply-To: dtor_core@ameritech.net
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7BIT
Cc: netdev@oss.sgi.com, Greg KH <greg@kroah.com>,
	Jamal Hadi Salim <hadi@cyberus.ca>,
	Kay Sievers <kay.sievers@vrfy.org>,
	Herbert Xu <herbert@gondor.apana.org.au>,
	James Morris <jmorris@redhat.com>,
	Guillaume Thouvenin <guillaume.thouvenin@bull.net>,
	linux-kernel@vger.kernel.org, Andrew Morton <akpm@osdl.org>,
	Thomas Graf <tgraf@suug.ch>, Jay Lan <jlan@engr.sgi.com>
Return-path: <linux-kernel-owner+glk-linux-kernel=40m.gmane.org-S261660AbVEJO5I@vger.kernel.org>
To: johnpol@2ka.mipt.ru
In-Reply-To: <20050510140445.36cc15cb@zanzibar.2ka.mipt.ru>
Content-Disposition: inline
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On 5/10/05, Evgeniy Polyakov <johnpol@2ka.mipt.ru> wrote:
> On Tue, 10 May 2005 01:18:46 -0500
> Dmitry Torokhov <dtor_core@ameritech.net> wrote:
> 
> > - drop cn_dev - there is only one connector;
> 
> There may be several connectors with different socket types.
> I use it in my environment for tests.
> 

Why do you need that? u32 ID space is not enough?

> > - simplify cn_notify_request to carry only one range - it simplifies code
> >   quite a bit - nothing stops clientd from sending several notification
> >   requests;
> 
> ? Nothing stops clients from sending several notification requests now.
> I do not see how it simplifies the things?
> Feel free to set idx_num and val_num to 1 and you will have the same.

Compare the implementaion - without variable-length notification
requests the code is much simplier and flexible.

> > - implement internal queuefor callbacks so we are not at mercy of scheduler;
> 
> Current implementation has big warning about such theoretical behaviour,
> if it will be triggered, I will fix that behaviour,
> more likely not by naive work allocation - there might be
> at least cache/memory pool or something...

What is the average expected rate for such messages? Not particularly
high I think. We just need to sustain sudden bursts, naive work
allocation will work just fine here.

> > - admit that SKBs are message medium and do not mess up with passing around
> >   destructor functions.
> 
> You mess up layers.
> I do not see why you want it.

What layers? Connector core is not an onion, with my patch it is 481
line .c file(down from 900+), comments probably take 1/3 of it. We
just need to keep it simple, that's all.

> Connector with your changes just does not work.

As in "I tried to run it and adjusted the application for the new
cn_notify_req size and it does not work" or "I am saying it does not
work"?

> Dmitry, I do not understand why do you change things in so radical manner,
> especially when there are no 1. new interesting features, 2. no performance
> improvements, 3. no right design changes.

There is a right design change - it keeps the code simple. It peels
all the layers you invented for something that does not really need
layers - connector is just a simple wrapper over raw netlink.

When I look at the code I see the mess of unneeded refcounting, wrong
kinds of locking, over-engineering. Of course I want to change it.

Keep it simple. Except for your testing environment why do you need to
have separate netlink sockets? You have an ample ID space. Why do you
need separate cn_dev and cn_queue_dev (and in the end have them at
all)? Why do you need "input" handler, do you expect to use different
handlers? If so which? And why? Do you expect to use other transports?
If so which? And why? You need to have justifiction for every
additional layer you putting on.

> 
> > BTW, I do not think that "All rights reserved" statement is applicable/
> > compatible with GPL this software is supposedly released under, I have
> > taken liberty of removing this statement.
> 
> You substitute license agreements with copyright.
> "All rights reserved" is targeted to copyright
> (avtorskoe pravo, zakon N 5351/1-1) of the code
> and has nothing with license.

Yes, you are probably right, sorry for the noise...

-- 
Dmitry
