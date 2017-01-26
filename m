From: Andy Lutomirski <luto@amacapital.net>
Subject: Re: [PATCH net] bpf: expose netns inode to bpf programs
Date: Thu, 26 Jan 2017 10:12:28 -0800
Message-ID: <CALCETrU7FYz=8c2a=FWvvCxFQC3_e0nYjSU6gj62w9K8mWj=Ww@mail.gmail.com>
References: <1485401274-2836524-1-git-send-email-ast@fb.com>
 <87efzq8jbi.fsf@xmission.com> <588995DE.9040707@fb.com> <CALCETrXQ8JFV28xU7tnh3tVbe_mp5yOtHp6shi10GMNnVCQowg@mail.gmail.com>
 <588A35F8.6050909@fb.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: Linus Torvalds <torvalds@linux-foundation.org>,
        "Eric W. Biederman" <ebiederm@xmission.com>,
        "David S . Miller" <davem@davemloft.net>,
        Daniel Borkmann <daniel@iogearbox.net>,
        David Ahern <dsa@cumulusnetworks.com>,
        Tejun Heo <tj@kernel.org>, Thomas Graf <tgraf@suug.ch>,
        Network Development <netdev@vger.kernel.org>
To: Alexei Starovoitov <ast@fb.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ua0-f175.google.com ([209.85.217.175]:36635 "EHLO
        mail-ua0-f175.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1753561AbdAZSNU (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 26 Jan 2017 13:13:20 -0500
Received: by mail-ua0-f175.google.com with SMTP id 96so187849415uaq.3
        for <netdev@vger.kernel.org>; Thu, 26 Jan 2017 10:12:50 -0800 (PST)
In-Reply-To: <588A35F8.6050909@fb.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, Jan 26, 2017 at 9:46 AM, Alexei Starovoitov <ast@fb.com> wrote:
> On 1/26/17 8:37 AM, Andy Lutomirski wrote:
>>>
>>> Think of bpf programs as safe kernel modules. They don't have
>>> confined boundaries and program authors, if not careful, can shoot
>>> themselves in the foot. We're not trying to prevent that because
>>> it's impossible to check that the program is sane. Just like
>>> it's impossible to check that kernel module is sane.
>>> But in case of bpf we check that bpf program is _safe_ from the kernel
>>> point of view. If it's doing some garbage, it's program's business.
>>> Does it make more sense now?
>>>
>>
>> With all due respect, I think this is not an acceptable way to think
>> about BPF at all.  If you think of BPF this way, I think there needs
>> to be a real discussion at KS or similar as to whether this is okay.
>> The reason is simple: the kernel promises a stable ABI to userspace
>> but not to kernel modules.  By thinking of BPF as more like a module,
>> you're taking a big shortcut that will either result in ABI breakage
>> down the road or in committing to a problematic stable ABI.
>
>
> you misunderstood the analogy.
> bpf abi is certainly stable. that's why we were careful of not
> exposing anything to it that is not already stable.
>

In that case I don't understand what you're trying to say.  Eric
thinks your patch exposes a bad interface.  A bad interface for
userspace is a very different thing from a bad interface available to
kernel modules.  Are you saying that BPF is kernel-module-like in that
the ABI exposed to BPF programs doesn't need to meet the same quality
standards as userspace ABIs?

--Andy
