From: Alexei Starovoitov <alexei.starovoitov@gmail.com>
Subject: Re: [PATCH 0/5] Networking cgroup controller
Date: Thu, 25 Aug 2016 14:29:24 -0700
Message-ID: <20160825212922.GA5388@ast-mbp.thefacebook.com>
References: <1470876798-4024-1-git-send-email-anaravaram@google.com>
 <20160824210357.GU8185@htj.duckdns.org>
 <CAF2d9jjXxjgJU1VWDERKkv4LRvmhpjpyx7Dx76egQx43aaXtmQ@mail.gmail.com>
 <20160825180412.GA2369@ast-mbp.thefacebook.com>
 <CAF2d9jh9ZZ7A6zBZQj4JF5tMAjXG9XnunHz45+StevWRBm70xg@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 8bit
Cc: Tejun Heo <tj@kernel.org>, corbet@lwn.net, lizefan@huawei.com,
        hannes@cmpxchg.org, David Miller <davem@davemloft.net>,
        kuznet@ms2.inr.ac.ru, jmorris@namei.org, yoshfuji@linux-ipv6.org,
        kaber@trash.net, linux-doc@vger.kernel.org,
        cgroups@vger.kernel.org, linux-netdev <netdev@vger.kernel.org>,
        Eric Dumazet <edumazet@google.com>,
        Wei Wang <weiwan@google.com>, tom@herbertland.com
To: Mahesh Bandewar
         =?utf-8?B?KOCkruCkueClh+CktiDgpKzgpILgpKHgpYfgpLXgpL4=?=
         =?utf-8?B?4KSwKQ==?= <maheshb@google.com>
Return-path: <linux-doc-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <CAF2d9jh9ZZ7A6zBZQj4JF5tMAjXG9XnunHz45+StevWRBm70xg@mail.gmail.com>
Sender: linux-doc-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Thu, Aug 25, 2016 at 11:56:27AM -0700, Mahesh Bandewar (महेश बंडेवार) wrote:
> On Thu, Aug 25, 2016 at 11:04 AM, Alexei Starovoitov
> <alexei.starovoitov@gmail.com> wrote:
> > On Thu, Aug 25, 2016 at 08:54:19AM -0700, Mahesh Bandewar (महेश बंडेवार) wrote:
> >> On Wed, Aug 24, 2016 at 2:03 PM, Tejun Heo <tj@kernel.org> wrote:
> >> > Hello, Anoop.
> >> >
> >> > On Wed, Aug 10, 2016 at 05:53:13PM -0700, Anoop Naravaram wrote:
> >> >> This patchset introduces a cgroup controller for the networking subsystem as a
> >> >> whole. As of now, this controller will be used for:
> >> >>
> >> >> * Limiting the specific ports that a process in a cgroup is allowed to bind
> >> >>   to or listen on. For example, you can say that all the processes in a
> >> >>   cgroup can only bind to ports 1000-2000, and listen on ports 1000-1100, which
> >> >>   guarantees that the remaining ports will be available for other processes.
> >> >>
> >> >> * Restricting which DSCP values processes can use with their sockets. For
> >> >>   example, you can say that all the processes in a cgroup can only send
> >> >>   packets with a DSCP tag between 48 and 63 (corresponding to TOS values of
> >> >>   192 to 255).
> >> >>
> >> >> * Limiting the total number of udp ports that can be used by a process in a
> >> >>   cgroup. For example, you can say that all the processes in one cgroup are
> >> >>   allowed to use a total of up to 100 udp ports. Since the total number of udp
> >> >>   ports that can be used by all processes is limited, this is useful for
> >> >>   rationing out the ports to different process groups.
> >> >>
> >> >> In the future, more networking-related properties may be added to this
> >> >> controller.
> >> >
> >> > Thanks for working on this; however, I share the sentiment expressed
> >> > by others that this looks like too piecemeal an approach.  If there
> >> > are no alternatives, we surely should consider this but it at least
> >> > *looks* like bpf should be able to cover the same functionalities
> >> > without having to revise and extend in-kernel capabilities constantly.
> >> >
> >> My primary concern is the cost that need to be paid to get this functionality.
> >> (a) The suggested alternatives eBPF either can't solve the problem in
> >> the current form or need substantial work to get it done. e.g.
> >> udp-port-limit since there is no notion of "maintaining
> >> counters-per-group-of-processes". This is solved by the cgroup infra.
> >
> > what is specifically missing?
> > there are several ways to do counters in bpf and as soon as bpf program
> > is attachable to a cgroup, all of these counter features come for free.
> > Counting bytes or packets or port bind failures or anything else per cgroup
> > with bpf is trivial. No extra code is needed.
> >
> Alexei, I was referring to the association of eBPF to the cgroup. Lack
> of it makes anyone wants to use it invest into additional
> administrative infra that you are currently getting with cgroup-infra.

Please look at Daniel's patches. They have been circulating in different
forms for quite some time now. Your bind port filter use case can be
easily added on top. Then the end result is additional ten lines of code
instead of hundreds.
Another alternative is to go cgroup+lsm+bpf route that Sargun and Mickael
are proposing. I think it will also work for your use case.
The goal we all should have is to have common infra that solves the
largest number of use cases.

