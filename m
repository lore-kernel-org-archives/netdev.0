From: Vivek Goyal <vgoyal@redhat.com>
Subject: Re: [PATCH 2/2] net: Implement SO_PASSCGROUP to enable passing
 cgroup path
Date: Wed, 23 Apr 2014 12:01:06 -0400
Message-ID: <20140423160106.GB24651@redhat.com>
References: <CALCETrVBJFgKwRKBE2jAG6kiGgkJ+MyQiw2nyz5yj0h68kCk9A@mail.gmail.com>
 <1397759013.2628.86.camel@willson.li.ssimo.org>
 <20140417185023.GA32527@redhat.com>
 <1397761817.2628.113.camel@willson.li.ssimo.org>
 <20140417191646.GA2461@redhat.com>
 <CALCETrW3F1+3qF3thrAmuoWVbRveBJ2=owpigh4mv6iAafoQCw@mail.gmail.com>
 <20140421150307.GA4367@redhat.com>
 <CALCETrW5RvbW-Hz_Y7oULP6sEfdhGBh51+mTj4RwobHV-ji+Kg@mail.gmail.com>
 <20140423150744.GC22755@redhat.com>
 <CALCETrVhXPK2roQZ7sKMPbJOsLCaMwhUJdL-p0tbUqN8cubsjg@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Simo Sorce <ssorce@redhat.com>, Daniel J Walsh <dwalsh@redhat.com>,
	David Miller <davem@davemloft.net>, Tejun Heo <tj@kernel.org>,
	"linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>,
	lpoetter@redhat.com, cgroups@vger.kernel.org, kay@redhat.com,
	Network Development <netdev@vger.kernel.org>
To: Andy Lutomirski <luto@amacapital.net>
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <CALCETrVhXPK2roQZ7sKMPbJOsLCaMwhUJdL-p0tbUqN8cubsjg@mail.gmail.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Wed, Apr 23, 2014 at 08:37:56AM -0700, Andy Lutomirski wrote:
> On Wed, Apr 23, 2014 at 8:07 AM, Vivek Goyal <vgoyal@redhat.com> wrote:
> > On Mon, Apr 21, 2014 at 08:47:51AM -0700, Andy Lutomirski wrote:
> >
> > [..]
> >> To summarize from my reading of how this crap words:
> >>
> >> When a unit is created, systemd opens a stream socket pointing at
> >> /run/systemd/journal/stdout.  It tells journald the unit, along with
> >> lots of other useful information.  journald records this association
> >> between the socket and the unit.  Systemd could tell journald the
> >> cgroup here, too, if it wanted it.
> >
> > Ok, that's a fair point. I looked at  connect_logger_as() and I see
> > that systemd does connect() on behalf of service being launched and
> > sets up fd and passes bunch of information to journald. So cgroup could
> > be one of the information and that would act like SO_PEERCGROUP in
> > this specific case. Not sure why it is not done though. I will let
> > systemd folks comment on that. I don't have enough background here.
> >
> > But this works in this specific case where there is a mechanism to
> > pass meta information to receiver. What about SSSD use case where
> > they want to know the cgroup of client and possibly provide differentiated
> > service based on client.
> 
> Separate sockets sounds like it will work just fine, if not better, here, to me.

That's one way of doing it. But that can't be the argument to not provide
another way of doing same thing with the help of single socket instead
of maintaining multiple ones.

Setting up separate socket for each client will require knowing every
client in advance so that one can socket appropriately. But mutiplexing
everything on one socket, does not have that constraint and should make
life little bit easier.

I think they will be just two different ways of doing things and user
can choose one depending on what suits them.

Thanks
Vivek
