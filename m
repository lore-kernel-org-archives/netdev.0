From: Alexei Starovoitov <alexei.starovoitov@gmail.com>
Subject: Re: [PATCH net] bpf: expose netns inode to bpf programs
Date: Sat, 4 Feb 2017 19:48:41 -0800
Message-ID: <20170205034839.GG73775@ast-mbp.thefacebook.com>
References: <CALCETrU7FYz=8c2a=FWvvCxFQC3_e0nYjSU6gj62w9K8mWj=Ww@mail.gmail.com>
 <588A40D7.9070603@fb.com>
 <CALCETrXgdY_Kt8wn4uiATUnNJ3YXttCUREgEeQReG7u29Lc44g@mail.gmail.com>
 <588A4D3C.9070601@fb.com>
 <87r33fevva.fsf@xmission.com>
 <CALCETrWDxVHc4_hpjLQRj-XbvGX0+tbGZ8o388-xn6rNcQTySQ@mail.gmail.com>
 <20170203230830.GC26227@ast-mbp.thefacebook.com>
 <CALCETrUb1Rf-BdSTHdKSgwnftHjpmcDt1HX1KX-cpN=N7ev+eg@mail.gmail.com>
 <20170205031045.GC73775@ast-mbp.thefacebook.com>
 <CALCETrUhE_Ga4PeobPFvhtLPVGKskTUaXe9H0v=kBXe4ii7dLw@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: "Eric W. Biederman" <ebiederm@xmission.com>,
        Alexei Starovoitov <ast@fb.com>,
        Linus Torvalds <torvalds@linux-foundation.org>,
        "David S . Miller" <davem@davemloft.net>,
        Daniel Borkmann <daniel@iogearbox.net>,
        David Ahern <dsa@cumulusnetworks.com>,
        Tejun Heo <tj@kernel.org>, Thomas Graf <tgraf@suug.ch>,
        Network Development <netdev@vger.kernel.org>
To: Andy Lutomirski <luto@amacapital.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pg0-f65.google.com ([74.125.83.65]:36218 "EHLO
        mail-pg0-f65.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751386AbdBEDsr (ORCPT
        <rfc822;netdev@vger.kernel.org>); Sat, 4 Feb 2017 22:48:47 -0500
Received: by mail-pg0-f65.google.com with SMTP id 75so5738415pgf.3
        for <netdev@vger.kernel.org>; Sat, 04 Feb 2017 19:48:46 -0800 (PST)
Content-Disposition: inline
In-Reply-To: <CALCETrUhE_Ga4PeobPFvhtLPVGKskTUaXe9H0v=kBXe4ii7dLw@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sat, Feb 04, 2017 at 07:27:01PM -0800, Andy Lutomirski wrote:
> On Sat, Feb 4, 2017 at 7:10 PM, Alexei Starovoitov
> <alexei.starovoitov@gmail.com> wrote:
> > On Sat, Feb 04, 2017 at 09:07:19AM -0800, Andy Lutomirski wrote:
> >> >> can see a namespaced view of the world.  For this to work, presumably
> >> >> we need to make sure that eBPF programs that are installed by programs
> >> >> that are in a container don't see traffic that isn't in that
> >> >> container.
> >> >
> >> > such approach will break existing users.
> >>
> >> What existing users?  The whole feature has never been in a released kernel.
> >
> > the v3 patch commit log explains the use cases that work across netns.
> > And they would break if netns boundary is suddenly started to be
> > enforced for networking program types.
> 
> This is why these issues should be addressed carefully before this
> feature is stabilized in 4.10, and I'm increasingly unconvinced that
> this will happen.  There may be a single week left, and the cgroup
> override issue is still entirely unaddressed, for example.

imo cgroup override issue is not an issue and the api can be extended
at any time. I offered to change the default to disable override,
but I need override to be there, since it's the fastest and most
flexible way. So the sooner we can land bpf_sk_netns_id() patch
the faster I can post override disable.

> Also, the v3 commit log's example seems a bit weak, since seccomp can
> handle that case (block non-init-netns raw sockets) and it's not clear
> to me that a filter like that serves a purpose regardless besides
> kernel attack surface reduction.

seccomp doesn't even support extended bpf yet and that makes it
quite inflexible.

> > If you're suggesting to limit root netns for cgroup_sock program type only
> > then David explained weeks ago why it's not acceptable for vrf use
> > case which was the main reason to add that program type in the first place.
> > Also it would make one specific bpf program type to be different
> > from all others which will be confusing.
> >
> 
> I'm suggesting limiting it to the init netns for *all* cases.
> (Specifically, limiting installing programs to the init netns.  But
> perhaps limiting running of programs to the netns in which they're
> installed would be the best solution after all.)  If there isn't a
> well-understood solution that plays well with netns and that satisfies
> ip vrf, the it's worth seriously thinking about whether ip vrf is
> really ready for 4.10.

The proposed v3 is imo solves the ip vrf 'malfunction' that you found.
v1 was also solving it and iproute2 patch was ready, but as Eric pointed
out just ns.inum is not enough.
The 'malfunction' can also be addressed _without_ kernel changes,
but the kernel can make it easier, hence v3 patch.

Andy, can you please reply in one thread? In particular in v3 patch?
I'm not sure why you making more or less the same points in
different threads. I'm sure it's hard for everyone to follow.
