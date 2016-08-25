From: =?UTF-8?B?TWFoZXNoIEJhbmRld2FyICjgpK7gpLngpYfgpLYg4KSs4KSC4KSh4KWH4KS14KS+4KSwKQ==?=
        <maheshb@google.com>
Subject: Re: [PATCH 0/5] Networking cgroup controller
Date: Thu, 25 Aug 2016 11:56:27 -0700
Message-ID: <CAF2d9jh9ZZ7A6zBZQj4JF5tMAjXG9XnunHz45+StevWRBm70xg@mail.gmail.com>
References: <1470876798-4024-1-git-send-email-anaravaram@google.com>
 <20160824210357.GU8185@htj.duckdns.org> <CAF2d9jjXxjgJU1VWDERKkv4LRvmhpjpyx7Dx76egQx43aaXtmQ@mail.gmail.com>
 <20160825180412.GA2369@ast-mbp.thefacebook.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: quoted-printable
Cc: Tejun Heo <tj@kernel.org>, corbet@lwn.net, lizefan@huawei.com,
        hannes@cmpxchg.org, David Miller <davem@davemloft.net>,
        kuznet@ms2.inr.ac.ru, jmorris@namei.org, yoshfuji@linux-ipv6.org,
        kaber@trash.net, linux-doc@vger.kernel.org,
        cgroups@vger.kernel.org, linux-netdev <netdev@vger.kernel.org>,
        Eric Dumazet <edumazet@google.com>,
        Wei Wang <weiwan@google.com>, tom@herbertland.com
To: Alexei Starovoitov <alexei.starovoitov@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-yw0-f169.google.com ([209.85.161.169]:36569 "EHLO
        mail-yw0-f169.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1755951AbcHYTDi (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 25 Aug 2016 15:03:38 -0400
Received: by mail-yw0-f169.google.com with SMTP id u134so35337687ywg.3
        for <netdev@vger.kernel.org>; Thu, 25 Aug 2016 12:03:09 -0700 (PDT)
In-Reply-To: <20160825180412.GA2369@ast-mbp.thefacebook.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, Aug 25, 2016 at 11:04 AM, Alexei Starovoitov
<alexei.starovoitov@gmail.com> wrote:
> On Thu, Aug 25, 2016 at 08:54:19AM -0700, Mahesh Bandewar (=E0=A4=AE=E0=
=A4=B9=E0=A5=87=E0=A4=B6 =E0=A4=AC=E0=A4=82=E0=A4=A1=E0=A5=87=E0=A4=B5=E0=
=A4=BE=E0=A4=B0) wrote:
>> On Wed, Aug 24, 2016 at 2:03 PM, Tejun Heo <tj@kernel.org> wrote:
>> > Hello, Anoop.
>> >
>> > On Wed, Aug 10, 2016 at 05:53:13PM -0700, Anoop Naravaram wrote:
>> >> This patchset introduces a cgroup controller for the networking subsy=
stem as a
>> >> whole. As of now, this controller will be used for:
>> >>
>> >> * Limiting the specific ports that a process in a cgroup is allowed t=
o bind
>> >>   to or listen on. For example, you can say that all the processes in=
 a
>> >>   cgroup can only bind to ports 1000-2000, and listen on ports 1000-1=
100, which
>> >>   guarantees that the remaining ports will be available for other pro=
cesses.
>> >>
>> >> * Restricting which DSCP values processes can use with their sockets.=
 For
>> >>   example, you can say that all the processes in a cgroup can only se=
nd
>> >>   packets with a DSCP tag between 48 and 63 (corresponding to TOS val=
ues of
>> >>   192 to 255).
>> >>
>> >> * Limiting the total number of udp ports that can be used by a proces=
s in a
>> >>   cgroup. For example, you can say that all the processes in one cgro=
up are
>> >>   allowed to use a total of up to 100 udp ports. Since the total numb=
er of udp
>> >>   ports that can be used by all processes is limited, this is useful =
for
>> >>   rationing out the ports to different process groups.
>> >>
>> >> In the future, more networking-related properties may be added to thi=
s
>> >> controller.
>> >
>> > Thanks for working on this; however, I share the sentiment expressed
>> > by others that this looks like too piecemeal an approach.  If there
>> > are no alternatives, we surely should consider this but it at least
>> > *looks* like bpf should be able to cover the same functionalities
>> > without having to revise and extend in-kernel capabilities constantly.
>> >
>> My primary concern is the cost that need to be paid to get this function=
ality.
>> (a) The suggested alternatives eBPF either can't solve the problem in
>> the current form or need substantial work to get it done. e.g.
>> udp-port-limit since there is no notion of "maintaining
>> counters-per-group-of-processes". This is solved by the cgroup infra.
>
> what is specifically missing?
> there are several ways to do counters in bpf and as soon as bpf program
> is attachable to a cgroup, all of these counter features come for free.
> Counting bytes or packets or port bind failures or anything else per cgro=
up
> with bpf is trivial. No extra code is needed.
>
Alexei, I was referring to the association of eBPF to the cgroup. Lack
of it makes anyone wants to use it invest into additional
administrative infra that you are currently getting with cgroup-infra.

>> (b) Also the hooks implemented are mostly with a per packet cost vs.
>> once when you are establishing the channel. Also not sure if the LSM
>> approach will allow some privileged user to over-ride the filters
>> attached and thus override the limits imposed. This is on top of the
>> administrative costs that currently don't have solution for and you
>> get it for free with cgroup infra.
>>
>> In short most of the associated problems are handled by the
>> cgroup-infra / APIs while all that need separate solution in
>> alternatives.  Tejun, feels like I'm advocating cgroup approach to you
>> ;)
>>
>> Thanks,
>> --mahesh..
>>
>>
>> > Thanks.
>> >
>> > --
>> > tejun
