From: Alexei Starovoitov <alexei.starovoitov@gmail.com>
Subject: Re: [RFC v3 07/22] landlock: Handle file comparisons
Date: Wed, 14 Sep 2016 16:24:20 -0700
Message-ID: <20160914232418.GD60248@ast-mbp.thefacebook.com>
References: <20160914072415.26021-1-mic@digikod.net>
 <20160914072415.26021-8-mic@digikod.net>
 <20160914210649.GA57174@ast-mbp.thefacebook.com>
 <57D9D6FE.4090708@digikod.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 8bit
Cc: linux-kernel@vger.kernel.org, Alexei Starovoitov <ast@kernel.org>,
        Andy Lutomirski <luto@amacapital.net>,
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
        kernel-hardening@lists.openwall.com, linux-api@vger.kernel.org,
        linux-security-module@vger.kern
To: =?iso-8859-1?Q?Micka=EBl_Sala=FCn?= <mic@digikod.net>
Return-path: <linux-security-module-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <57D9D6FE.4090708@digikod.net>
Sender: owner-linux-security-module@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Thu, Sep 15, 2016 at 01:02:22AM +0200, Mickaël Salaün wrote:
> > 
> > I would suggest for the next RFC to do minimal 7 patches up to this point
> > with simple example that demonstrates the use case.
> > I would avoid all unpriv stuff and all of seccomp for the next RFC as well,
> > otherwise I don't think we can realistically make forward progress, since
> > there are too many issues raised in the subsequent patches.
> 
> I hope we will find a common agreement about seccomp vs cgroup… I think
> both approaches have their advantages, can be complementary and nicely
> combined.

I don't mind having both task based lsm and cgroup based as long as
infrastracture is not duplicated and scaling issues from earlier version
are resolved.
I'm proposing to do cgroup only for the next RFC, since mine and Sargun's
use case for this bpf+lsm+cgroup is _not_ security or sandboxing.
No need for unpriv, no_new_priv to cgroups are other things that Andy
is concerned about.

> Unprivileged sandboxing is the main goal of Landlock. This should not be
> a problem, even for privileged features, thanks to the new subtype/access.

yes. the point that unpriv stuff can come later after agreement is reached.
If we keep arguing about seccomp details this set won't go anywhere.
Even in basic part (which is cgroup+bpf+lsm) are plenty of questions
to be still agreed.

> Agreed. With this RFC, the Checmate features (i.e. network helpers)
> should be able to sit on top of Landlock.

I think neither of them should be called fancy names for no technical reason.
We will have only one bpf based lsm. That's it and it doesn't
need an obscure name. Directory name can be security/bpf/..stuff.c

