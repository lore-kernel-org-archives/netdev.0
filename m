From: Andy Lutomirski <luto@amacapital.net>
Subject: Re: [PATCH v2 net] bpf: add bpf_sk_netns_id() helper
Date: Sat, 4 Feb 2017 19:33:14 -0800
Message-ID: <CALCETrU4_y0qSJu4epTO9aNEVZzt9cXY52=bHyGutbAMuEd-VA@mail.gmail.com>
References: <1486171342-3310547-1-git-send-email-ast@fb.com>
 <CALCETrU6hAxyTGZXn1Eo=Pcq8gxLL2=Ai=Hks5-PjDW-3HtJjA@mail.gmail.com> <20170205032548.GE73775@ast-mbp.thefacebook.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: Alexei Starovoitov <ast@fb.com>,
        "David S . Miller" <davem@davemloft.net>,
        Daniel Borkmann <daniel@iogearbox.net>,
        David Ahern <dsa@cumulusnetworks.com>,
        Tejun Heo <tj@kernel.org>,
        "Eric W . Biederman" <ebiederm@xmission.com>,
        Network Development <netdev@vger.kernel.org>
To: Alexei Starovoitov <alexei.starovoitov@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ua0-f178.google.com ([209.85.217.178]:35310 "EHLO
        mail-ua0-f178.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751201AbdBEDdg (ORCPT
        <rfc822;netdev@vger.kernel.org>); Sat, 4 Feb 2017 22:33:36 -0500
Received: by mail-ua0-f178.google.com with SMTP id y9so40318433uae.2
        for <netdev@vger.kernel.org>; Sat, 04 Feb 2017 19:33:35 -0800 (PST)
In-Reply-To: <20170205032548.GE73775@ast-mbp.thefacebook.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sat, Feb 4, 2017 at 7:25 PM, Alexei Starovoitov
<alexei.starovoitov@gmail.com> wrote:
> On Sat, Feb 04, 2017 at 09:15:10AM -0800, Andy Lutomirski wrote:
>> On Fri, Feb 3, 2017 at 5:22 PM, Alexei Starovoitov <ast@fb.com> wrote:
>> > Note that all bpf programs types are global.
>>
>> I don't think this has a clear enough meaning to work with.  In
>
> Please clarify what you mean. The quoted part says
> "bpf programs are global". What is not "clear enough" there?

What does "bpf programs are global" mean?  I am genuinely unable to
figure out what you mean.  Here are some example guesses of what you
might mean:

 - BPF programs are compiled independently of a namespace.  This is
certainly true, but I don't think it matters.

 - You want BPF programs to affect everything on the system.  But this
doesn't seem right to be -- they only affect things in the relevant
cgroup, so they're not global in that sense.

 - You want BPF programs to affect everything in their cgroup
regardless of namespace.  This does seem to be what you think, but it
doesn't say *why*, which is the relevant bit.

 - The set of BPF program types and the verification rules are
independent of cgroup and namespace.  This is true, but I don't think
it matters.

That's all I came up with.  So, I'll repeat: what does "bpf programs
are global" mean?

>
>> I think that this patch plus a minor change to prevent installing
>> cgroup+bpf programs if the installer isn't in the init netns + fs ns
>> would work because it would allow new, migratable semantics to be
>> added down the road to relax the restriction.
>
> Forcing installer to be in init netns is not acceptable to David
> who added cgroup_sock in the first place. I'm not sure why
> we have to discuss that bit in circles.
>

Because we're one week or so from 4.10 final, the 4.10-rc code is
problematic even for ip vrf, and there isn't a clear solution yet.
There are a bunch of requirements that seem to conflict, and something
has to give.

--Andy
