From: Andy Lutomirski <luto@amacapital.net>
Subject: Re: [PATCH v2 net] bpf: add bpf_sk_netns_id() helper
Date: Sat, 4 Feb 2017 09:15:10 -0800
Message-ID: <CALCETrU6hAxyTGZXn1Eo=Pcq8gxLL2=Ai=Hks5-PjDW-3HtJjA@mail.gmail.com>
References: <1486171342-3310547-1-git-send-email-ast@fb.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: "David S . Miller" <davem@davemloft.net>,
        Daniel Borkmann <daniel@iogearbox.net>,
        David Ahern <dsa@cumulusnetworks.com>,
        Tejun Heo <tj@kernel.org>,
        "Eric W . Biederman" <ebiederm@xmission.com>,
        Network Development <netdev@vger.kernel.org>
To: Alexei Starovoitov <ast@fb.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-vk0-f43.google.com ([209.85.213.43]:35430 "EHLO
        mail-vk0-f43.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751047AbdBDRPc (ORCPT
        <rfc822;netdev@vger.kernel.org>); Sat, 4 Feb 2017 12:15:32 -0500
Received: by mail-vk0-f43.google.com with SMTP id x75so32531218vke.2
        for <netdev@vger.kernel.org>; Sat, 04 Feb 2017 09:15:32 -0800 (PST)
In-Reply-To: <1486171342-3310547-1-git-send-email-ast@fb.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, Feb 3, 2017 at 5:22 PM, Alexei Starovoitov <ast@fb.com> wrote:
> Note that all bpf programs types are global.

I don't think this has a clear enough meaning to work with.  In
particular, I think that, if you have some software that installs
cgroup+bpf programs and you run it in a container, then I have no idea
what "global" means in this context, and you may run into trouble with
this patch once namespace ids become migratable because the cgroup+bpf
program in the container would potentially see dev+ino numbers from
*outside* the container.  What happens when you migrate it?

I think that this patch plus a minor change to prevent installing
cgroup+bpf programs if the installer isn't in the init netns + fs ns
would work because it would allow new, migratable semantics to be
added down the road to relax the restriction.

Eric, what do you think?
