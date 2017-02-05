From: Andy Lutomirski <luto@amacapital.net>
Subject: Re: [PATCH net] bpf: expose netns inode to bpf programs
Date: Sat, 4 Feb 2017 19:49:44 -0800
Message-ID: <CALCETrWZdSOMvQ-Jx+hOiPvJEUSJgKf0A3kJWj7Ys30qjLkNgQ@mail.gmail.com>
References: <1485401274-2836524-1-git-send-email-ast@fb.com>
 <5894FC9B.8000108@iogearbox.net> <20170203230627.GB26227@ast-mbp.thefacebook.com>
 <58951567.1030401@iogearbox.net> <CALCETrVnGP3DBAWQGFDXyXsN+tq+sSF+zirp4yPgiBo42qzV-g@mail.gmail.com>
 <20170205031854.GD73775@ast-mbp.thefacebook.com> <CALCETrWs-z_P5oJjg4--3EbNBV1zg8miPyYk3p+3N+H2=FkRrg@mail.gmail.com>
 <20170205033520.GF73775@ast-mbp.thefacebook.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: Daniel Borkmann <daniel@iogearbox.net>,
        Alexei Starovoitov <ast@fb.com>,
        "David S . Miller" <davem@davemloft.net>,
        David Ahern <dsa@cumulusnetworks.com>,
        Tejun Heo <tj@kernel.org>,
        "Eric W . Biederman" <ebiederm@xmission.com>,
        Thomas Graf <tgraf@suug.ch>,
        Network Development <netdev@vger.kernel.org>
To: Alexei Starovoitov <alexei.starovoitov@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-vk0-f53.google.com ([209.85.213.53]:35891 "EHLO
        mail-vk0-f53.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751201AbdBEDuF (ORCPT
        <rfc822;netdev@vger.kernel.org>); Sat, 4 Feb 2017 22:50:05 -0500
Received: by mail-vk0-f53.google.com with SMTP id t8so37298682vke.3
        for <netdev@vger.kernel.org>; Sat, 04 Feb 2017 19:50:05 -0800 (PST)
In-Reply-To: <20170205033520.GF73775@ast-mbp.thefacebook.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sat, Feb 4, 2017 at 7:35 PM, Alexei Starovoitov
<alexei.starovoitov@gmail.com> wrote:
> On Sat, Feb 04, 2017 at 07:22:03PM -0800, Andy Lutomirski wrote:
>> On Sat, Feb 4, 2017 at 7:18 PM, Alexei Starovoitov
>> <alexei.starovoitov@gmail.com> wrote:
>> > On Sat, Feb 04, 2017 at 09:08:38AM -0800, Andy Lutomirski wrote:
>> >> > So use-case would be that someone wants to attach the very same
>> >> > prog via tc to various netdevs sitting in different netns, and
>> >> > that prog looks up a map, controlled by initns, with skb->netns_inum
>> >> > as key and the resulting value could contain allowed feature bits
>> >> > for that specific netns prog the skbs goes through? That would be
>> >> > a feature, not "concern", no? At the same time, it's up to the
>> >> > user or mgmt app what gets loaded so f.e. it might just as well
>> >> > tailor/optimize the progs individually for the devs sitting in
>> >> > netns-es to avoid such map lookup.
>> >>
>> >> Agreed.  I don't see why you would install the exact same program on
>> >> two sockets in different netnses if the program contains, say, an
>> >> ifindex.  Why not just install a variant with the right ifindex into
>> >> each socket?
>> >
>> > In other cases people prefer to have one program compiled once
>> > and thoroughly tested offline, since some folks are worried
>> > that on-the-fly compilation may cause generated code to
>> > be rejected by the verifier.
>>
>> I would be rather surprised if someone wrote a program that did had an
>> expression like (ifindex == 17), tested it offline, and refused to
>> update the 17 based on the actual ifindex in use.
>
> All programs have bugs. What bpf subsytem is trying to do is
> to be flexible and satisfy as many use cases as possible.
> Boxing users into "one way to do things" isn't a successful
> strategy in my opinion. perl vs python, if you like :)
> bpf is perl like. We don't enforce spaces vs tabs :)
>

Daniel's asking what the netns query is good for in programs that are
attached to sockets.  I think your example isn't relevant here.  In
fact, I think your example of pre-tested programs is even less
relevant, since a there's no way to know what the netns id will be
prior to the creation of a netns, so you can't usefully hard-code a
netns id into a precompiled BPF program.
