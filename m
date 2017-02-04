From: Andy Lutomirski <luto@amacapital.net>
Subject: Re: [PATCH net] bpf: expose netns inode to bpf programs
Date: Sat, 4 Feb 2017 09:07:19 -0800
Message-ID: <CALCETrUb1Rf-BdSTHdKSgwnftHjpmcDt1HX1KX-cpN=N7ev+eg@mail.gmail.com>
References: <87efzq8jbi.fsf@xmission.com> <588995DE.9040707@fb.com>
 <CALCETrXQ8JFV28xU7tnh3tVbe_mp5yOtHp6shi10GMNnVCQowg@mail.gmail.com>
 <588A35F8.6050909@fb.com> <CALCETrU7FYz=8c2a=FWvvCxFQC3_e0nYjSU6gj62w9K8mWj=Ww@mail.gmail.com>
 <588A40D7.9070603@fb.com> <CALCETrXgdY_Kt8wn4uiATUnNJ3YXttCUREgEeQReG7u29Lc44g@mail.gmail.com>
 <588A4D3C.9070601@fb.com> <87r33fevva.fsf@xmission.com> <CALCETrWDxVHc4_hpjLQRj-XbvGX0+tbGZ8o388-xn6rNcQTySQ@mail.gmail.com>
 <20170203230830.GC26227@ast-mbp.thefacebook.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: "Eric W. Biederman" <ebiederm@xmission.com>,
        Alexei Starovoitov <ast@fb.com>,
        Linus Torvalds <torvalds@linux-foundation.org>,
        "David S . Miller" <davem@davemloft.net>,
        Daniel Borkmann <daniel@iogearbox.net>,
        David Ahern <dsa@cumulusnetworks.com>,
        Tejun Heo <tj@kernel.org>, Thomas Graf <tgraf@suug.ch>,
        Network Development <netdev@vger.kernel.org>
To: Alexei Starovoitov <alexei.starovoitov@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-vk0-f50.google.com ([209.85.213.50]:33022 "EHLO
        mail-vk0-f50.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751425AbdBDRHl (ORCPT
        <rfc822;netdev@vger.kernel.org>); Sat, 4 Feb 2017 12:07:41 -0500
Received: by mail-vk0-f50.google.com with SMTP id k127so32529777vke.0
        for <netdev@vger.kernel.org>; Sat, 04 Feb 2017 09:07:41 -0800 (PST)
In-Reply-To: <20170203230830.GC26227@ast-mbp.thefacebook.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, Feb 3, 2017 at 3:08 PM, Alexei Starovoitov
<alexei.starovoitov@gmail.com> wrote:
> On Fri, Feb 03, 2017 at 01:00:47PM -0800, Andy Lutomirski wrote:
>>
>> ISTM any ability to migrate namespaces and to migrate eBPF programs
>> that know about namespaces needs to have the eBPF program firmly
>> rooted in some namespace (or perhaps cgroup in this case) so that it
>
> programs are already global. We cannot break that.

I don't know what you mean here.  It ought to be possible to have a
(privileged) program that installs and uses cgroup+bpf programs run
under CRIU and get migrated.  Maybe not yet, but some day.  This
should be doable without the program noticing, and it would be
unfortunate if the API makes this harder than necessary.

>
>> can see a namespaced view of the world.  For this to work, presumably
>> we need to make sure that eBPF programs that are installed by programs
>> that are in a container don't see traffic that isn't in that
>> container.
>
> such approach will break existing users.

What existing users?  The whole feature has never been in a released kernel.
