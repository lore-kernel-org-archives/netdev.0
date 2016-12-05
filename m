From: Willem de Bruijn <willemb@google.com>
Subject: Re: [PATCH nf-next] netfilter: xt_bpf: support ebpf
Date: Mon, 5 Dec 2016 18:29:53 -0500
Message-ID: <CA+FuTSfHryyqBhRyfQCChG2VPwpj1KYBk2Z7DZ-dcYL-FbbSeA@mail.gmail.com>
References: <1480969684-74414-1-git-send-email-willemdebruijn.kernel@gmail.com>
 <1480972006.18162.559.camel@edumazet-glaptop3.roam.corp.google.com>
 <20161205213001.GA16819@breakpoint.cc> <20161205223415.GA14689@salvia>
 <20161205230055.GA15379@salvia> <CAF=yD-Jk4W+zU=tdixWe3LPGcFp-sANxXLLoQTRvrkN_3=a9uw@mail.gmail.com>
 <20161205232214.GA15825@salvia>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: Willem de Bruijn <willemdebruijn.kernel@gmail.com>,
        netfilter-devel <netfilter-devel@vger.kernel.org>,
        Network Development <netdev@vger.kernel.org>,
        Daniel Borkmann <daniel@iogearbox.net>,
        Florian Westphal <fw@strlen.de>,
        Eric Dumazet <eric.dumazet@gmail.com>
To: Pablo Neira Ayuso <pablo@netfilter.org>
Return-path: <netfilter-devel-owner@vger.kernel.org>
In-Reply-To: <20161205232214.GA15825@salvia>
Sender: netfilter-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Mon, Dec 5, 2016 at 6:22 PM, Pablo Neira Ayuso <pablo@netfilter.org> wrote:
> On Mon, Dec 05, 2016 at 06:06:05PM -0500, Willem de Bruijn wrote:
> [...]
>> Eric also suggests a private variable to avoid being subject to
>> changes to PATH_MAX. Then we can indeed also choose an arbitrary lower
>> length than current PATH_MAX.
>
> Good.
>
>> FWIW, there is a workaround for users with deeply nested paths: the
>> path passed does not have to be absolute. It is literally what is
>> passed on the command line to iptables right now, including relative
>> addresses.
>
> If iptables userspace always expects to have the bpf file repository
> in some given location (suggesting to have a directory that we specify
> at ./configure time, similar to what we do with connlabel.conf), then
> I think we can rely on relative paths. Would this be flexible enough
> for your usecase?

As long as it accepts relative paths, I think it will always work.
Worst case, a user has to cd. No need for hardcoding the bpf mount
point at compile time.

I have the matching iptables patch for pinned objects, btw. Not for
elf objects, which requires linking to libelf and parsing the object,
which is more work (and perhaps best punted on by expanding libbpf in
bcc to include this functionality. it already exists under samples/bpf
and iproute2).
