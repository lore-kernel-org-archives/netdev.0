From: Rodrigo Moya <rodrigo.moya@collabora.co.uk>
Subject: RE: [PATCH 0/10] af_unix: add multicast and filtering features to
 AF_UNIX
Date: Thu, 01 Mar 2012 13:50:37 +0100
Message-ID: <1330606237.27405.5.camel@megeve>
References: <AE90C24D6B3A694183C094C60CF0A2F6026B6E86@saturn3.aculab.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="ISO-8859-15"
Content-Transfer-Encoding: 7bit
Cc: Eric Dumazet <eric.dumazet@gmail.com>,
	Javier Martinez Canillas <javier.martinez@collabora.co.uk>,
	David Miller <davem@davemloft.net>, javier@collabora.co.uk,
	lennart@poettering.net, kay.sievers@vrfy.org,
	alban.crequy@collabora.co.uk, bart.cerneels@collabora.co.uk,
	sjoerd.simons@collabora.co.uk, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: David Laight <David.Laight@ACULAB.COM>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <AE90C24D6B3A694183C094C60CF0A2F6026B6E86@saturn3.aculab.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Thu, 2012-03-01 at 12:33 +0000, David Laight wrote:
> > > So, now we are trying a different approach. To create a new address
> > > family AF_MCAST. That way we can have more control over the
> semantics of
> > > the socket interface for that family.
> > > 
> > > We expect to have some patches in a few days and we will resend.
> > > 
> > > Does this makes more sense to you?
> > > 
> > 
> > Why adding an obscure set of IPC mechanism in network tree, and not
> > using (maybe extending) traditional IPC (Messages queues, semaphores,
> > Shared memory, pipes, futexes, ...).
> 
> If it isn't a totally silly suggestion, why not write a simple
> device driver that just does what you want?
> Which (I think) is named pipes with multiple readers.
> 
the main problem in D-Bus we are trying to solve is the context
switches, since right now, there is a daemon, which listens on a UNIX
socket, and all traffic in the bus goes through it, and then the daemon
has to route the messages it gets on that socket to the corresponding
place(s). So, every time someone sends a message to D-Bus, since all
traffic goes through the daemon, dbus-daemon gets waked-up, which is one
of the biggest bottlenecks we are trying to fix.

That's why we are thinking about using multicast with socket filters, so
that the daemon only gets traffic it cares about and thus is not waked
up and context switches don't happen when not needed.

Using message queues, AFAICS, we would have the same problem, as the
daemon would create the message queue and would get all traffic, right?

cheers
