From: Willem de Bruijn <willemdebruijn.kernel@gmail.com>
Subject: Re: [PATCH nf-next] netfilter: xt_bpf: support ebpf
Date: Mon, 5 Dec 2016 18:06:05 -0500
Message-ID: <CAF=yD-Jk4W+zU=tdixWe3LPGcFp-sANxXLLoQTRvrkN_3=a9uw@mail.gmail.com>
References: <1480969684-74414-1-git-send-email-willemdebruijn.kernel@gmail.com>
 <1480972006.18162.559.camel@edumazet-glaptop3.roam.corp.google.com>
 <20161205213001.GA16819@breakpoint.cc> <20161205223415.GA14689@salvia> <20161205230055.GA15379@salvia>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: netfilter-devel@vger.kernel.org,
        Network Development <netdev@vger.kernel.org>,
        Daniel Borkmann <daniel@iogearbox.net>,
        Willem de Bruijn <willemb@google.com>,
        Florian Westphal <fw@strlen.de>,
        Eric Dumazet <eric.dumazet@gmail.com>
To: Pablo Neira Ayuso <pablo@netfilter.org>
Return-path: <netfilter-devel-owner@vger.kernel.org>
In-Reply-To: <20161205230055.GA15379@salvia>
Sender: netfilter-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Mon, Dec 5, 2016 at 6:00 PM, Pablo Neira Ayuso <pablo@netfilter.org> wrote:
> On Mon, Dec 05, 2016 at 11:34:15PM +0100, Pablo Neira Ayuso wrote:
>> On Mon, Dec 05, 2016 at 10:30:01PM +0100, Florian Westphal wrote:
>> > Eric Dumazet <eric.dumazet@gmail.com> wrote:
>> > > On Mon, 2016-12-05 at 15:28 -0500, Willem de Bruijn wrote:
>> > > > From: Willem de Bruijn <willemb@google.com>
>> > > >
>> > > > Add support for attaching an eBPF object by file descriptor.
>> > > >
>> > > > The iptables binary can be called with a path to an elf object or a
>> > > > pinned bpf object. Also pass the mode and path to the kernel to be
>> > > > able to return it later for iptables dump and save.
>> > > >
>> > > > Signed-off-by: Willem de Bruijn <willemb@google.com>
>> > > > ---
>> > >
>> > > Assuming there is no simple way to get variable matchsize in iptables,
>> > > this looks good to me, thanks.
>> >
>> > It should be possible by setting kernel .matchsize to ~0 which
>> > suppresses strict size enforcement.
>> >
>> > Its currently only used by ebt_among, but this should work for any xtables
>> > module.
>>
>> This is likely going to trigger a large rewrite of the core userspace
>> iptables codebase, and likely going to pull part of the mess we have
>> in ebtables into iptables. So I'd prefer not to follow this path.
>
> So this variable path is there to annotate what userspace claims that
> is the file that contains the bpf blob that was loaded, actually this
> is irrelevant to the kernel, so this is just there to dump it back
> when iptables-save it is called. Just a side note, one could set
> anything there from userspace, point somewhere else actually...
>
> Well anyway, going back to the path problem to keep it simple: Why
> don't just trim this down to something smaller, are you really
> expecting to reach PATH_MAX in your usecase?

Not often. Module-specific limitations that differ from global
definitions are just a pain when they bite. This module also has an
arbitrary low limit on the length of the cBPF program passed, for
instance.

Eric also suggests a private variable to avoid being subject to
changes to PATH_MAX. Then we can indeed also choose an arbitrary lower
length than current PATH_MAX.

FWIW, there is a workaround for users with deeply nested paths: the
path passed does not have to be absolute. It is literally what is
passed on the command line to iptables right now, including relative
addresses.
