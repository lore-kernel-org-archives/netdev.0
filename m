From: Simo Sorce <ssorce@redhat.com>
Subject: Re: [PATCH 2/2] net: Implement SO_PEERCGROUP
Date: Thu, 13 Mar 2014 13:55:32 -0400
Message-ID: <1394733332.32465.248.camel@willson.li.ssimo.org>
References: <1394657163-7472-1-git-send-email-vgoyal@redhat.com>
	 <1394657163-7472-3-git-send-email-vgoyal@redhat.com>
	 <5320CAEC.6030008@amacapital.net>
	 <CALCETrUTjN=XKwnO62P9roZtLLuk7_9Oi17Mj_Aa2ZFtZc1gVA@mail.gmail.com>
	 <20140313141422.GB18914@redhat.com>
	 <1394722534.32465.227.camel@willson.li.ssimo.org>
	 <20140313150034.GG18914@redhat.com>
	 <1394728389.32465.230.camel@willson.li.ssimo.org>
	 <CALCETrWqoc8nxbRQWpRKBu23N3ZXd98Cbk7xvvtZ6crKKR6mng@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: Vivek Goyal <vgoyal@redhat.com>,
	"linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>,
	cgroups@vger.kernel.org,
	Network Development <netdev@vger.kernel.org>,
	"David S. Miller" <davem@davemloft.net>, Tejun Heo <tj@kernel.org>,
	jkaluza@redhat.com, lpoetter@redhat.com, kay@redhat.com
To: Andy Lutomirski <luto@amacapital.net>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <CALCETrWqoc8nxbRQWpRKBu23N3ZXd98Cbk7xvvtZ6crKKR6mng@mail.gmail.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Thu, 2014-03-13 at 10:25 -0700, Andy Lutomirski wrote:
> On Thu, Mar 13, 2014 at 9:33 AM, Simo Sorce <ssorce@redhat.com> wrote:
> > On Thu, 2014-03-13 at 11:00 -0400, Vivek Goyal wrote:
> >> On Thu, Mar 13, 2014 at 10:55:34AM -0400, Simo Sorce wrote:
> >>
> >> [..]
> >> > > > This might not be quite as awful as I thought.  At least you're
> >> > > > looking up the cgroup at connection time instead of at send time.
> >> > > >
> >> > > > OTOH, this is still racy -- the socket could easily outlive the cgroup
> >> > > > that created it.
> >> > >
> >> > > That's a good point. What guarantees that previous cgroup was not
> >> > > reassigned to a different container.
> >> > >
> >> > > What if a process A opens the connection with sssd. Process A passes the
> >> > > file descriptor to a different process B in a differnt container.
> >> >
> >> > Stop right here.
> >> > If the process passes the fd it is not my problem anymore.
> >> > The process can as well just 'proxy' all the information to another
> >> > process.
> >> >
> >> > We just care to properly identify the 'original' container, we are not
> >> > in the business of detecting malicious behavior. That's something other
> >> > mechanism need to protect against (SELinux or other LSMs, normal
> >> > permissions, capabilities, etc...).
> >> >
> >> > > Process A exits. Container gets removed from system and new one gets
> >> > > launched which uses same cgroup as old one. Now process B sends a new
> >> > > request and SSSD will serve it based on policy of newly launched
> >> > > container.
> >> > >
> >> > > This sounds very similar to pid race where socket/connection will outlive
> >> > > the pid.
> >> >
> >> > Nope, completely different.
> >> >
> >>
> >> I think you missed my point. Passing file descriptor is not the problem.
> >> Problem is reuse of same cgroup name for a different container while
> >> socket lives on. And it is same race as reuse of a pid for a different
> >> process.
> >
> > The cgroup name should not be reused of course, if userspace does that,
> > it is userspace's issue. cgroup names are not a constrained namespace
> > like pids which force the kernel to reuse them for processes of a
> > different nature.
> >
> 
> You're proposing a feature that will enshrine cgroups into the API use
> by non-cgroup-controlling applications.  I don't think that anyone
> thinks that cgroups are pretty, so this is an unfortunate thing to
> have to do.
> 
> I've suggested three different ways that your goal could be achieved
> without using cgroups at all.  You haven't really addressed any of
> them.

I replied now, none of them strike me as practical or something that can
be enforced.

> In order for something like this to go into the kernel, I would expect
> a real use case and a justification for why this is the right way to
> do it.

I think my justification is quite real, the fact you do not like it does
not really make it any less real.

I am open to suggestions on alternative methods of course, I do not care
which way as long as it is practical and does not cause unreasonable
restrictions on the containerization. As far as I could see all of the
container stuff uses cgroups already for various reasons, so using
cgroups seem natural.

> "Docker containers can be identified by cgroup path" is completely
> unconvincing to me.

Provide an alternative, so far there is a cgroup with a unique name
associated to every container, I haven't found any other way to derive
that information in a race free way so far.

Simo.
