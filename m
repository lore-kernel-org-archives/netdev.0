From: Andy Lutomirski <luto@amacapital.net>
Subject: Re: [RFC v3 18/22] cgroup,landlock: Add CGRP_NO_NEW_PRIVS to handle
 unprivileged hooks
Date: Wed, 14 Sep 2016 11:27:48 -0700
Message-ID: <CALCETrXBDVe9AzHnD1B5r=GGVNsU5gsC92iqD0S94mQBZOzOBQ@mail.gmail.com>
References: <20160914072415.26021-1-mic@digikod.net> <20160914072415.26021-19-mic@digikod.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: quoted-printable
Cc: "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>,
        Alexei Starovoitov <ast@kernel.org>,
        Arnd Bergmann <arnd@arndb.de>,
        Casey Schaufler <casey@schaufler-ca.com>,
        Daniel Borkmann <daniel@iogearbox.net>,
        Daniel Mack <daniel@zonque.org>,
        David Drysdale <drysdale@google.com>,
        "David S . Miller" <davem@davemloft.net>,
        Elena Reshetova <elena.reshetova@intel.com>,
        "Eric W . Biederman" <ebiederm@xmission.com>,
        James Morris <james.l.morris@oracle.com>,
        Kees Cook <keescook@chromium.org>,
        Paul Moore <pmoore@redhat.com>,
        Sargun Dhillon <sargun@sargun.me>,
        "Serge E . Hallyn" <serge@hallyn.com>, Tejun Heo <tj@kernel.org>,
        Will Drewry <wad@chromium.org>,
        "kernel-hardening@lists.openwall.com"
        <kernel-hardening@lists.openwall.com>,
        Linux API <linu
To: =?UTF-8?B?TWlja2HDq2wgU2FsYcO8bg==?= <mic@digikod.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-yb0-f173.google.com ([209.85.213.173]:34143 "EHLO
        mail-yb0-f173.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751061AbcINS2J (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 14 Sep 2016 14:28:09 -0400
Received: by mail-yb0-f173.google.com with SMTP id x93so19319408ybh.1
        for <netdev@vger.kernel.org>; Wed, 14 Sep 2016 11:28:09 -0700 (PDT)
In-Reply-To: <20160914072415.26021-19-mic@digikod.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, Sep 14, 2016 at 12:24 AM, Micka=C3=ABl Sala=C3=BCn <mic@digikod.net=
> wrote:
> Add a new flag CGRP_NO_NEW_PRIVS for each cgroup. This flag is initially
> set for all cgroup except the root. The flag is clear when a new process
> without the no_new_privs flags is attached to the cgroup.
>
> If a cgroup is landlocked, then any new attempt, from an unprivileged
> process, to attach a process without no_new_privs to this cgroup will
> be denied.

Until and unless everyone can agree on a way to properly namespace,
delegate, etc cgroups, I think that trying to add unprivileged
semantics to cgroups is nuts.  Given the big thread about cgroup v2,
no-internal-tasks, etc, I just don't see how this approach can be
viable.

Can we try to make landlock work completely independently of cgroups
so that it doesn't get stuck and so that programs can use it without
worrying about cgroup v1 vs v2, interactions with cgroup managers,
cgroup managers that (supposedly?) will start migrating processes
around piecemeal and almost certainly blowing up landlock in the
process, etc?

I have no problem with looking at prototypes for how landlock +
cgroups would work, but I can't imagine the result being mergeable.
