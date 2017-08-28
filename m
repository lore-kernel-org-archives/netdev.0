From: Alexei Starovoitov <alexei.starovoitov@gmail.com>
Subject: Re: [PATCH net-next v7 05/10] landlock: Add LSM hooks related to
 filesystem
Date: Sun, 27 Aug 2017 22:26:22 -0700
Message-ID: <20170828052620.kn5zq2q6dm3iud6g@ast-mbp>
References: <20170821000933.13024-1-mic@digikod.net>
 <20170821000933.13024-6-mic@digikod.net>
 <20170824025030.sxl2hkpcbzipb47y@ast-mbp>
 <22d09137-7212-5803-af64-0964fad875c7@digikod.net>
 <20170826011614.iqya5dqii3n7dtdb@ast-mbp>
 <3325bd7d-f3d8-2f51-384c-b5e8cee5cb91@digikod.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Transfer-Encoding: 8bit
Cc: linux-kernel@vger.kernel.org, Alexei Starovoitov <ast@kernel.org>,
        Andy Lutomirski <luto@amacapital.net>,
        Arnaldo Carvalho de Melo <acme@kernel.org>,
        Casey Schaufler <casey@schaufler-ca.com>,
        Daniel Borkmann <daniel@iogearbox.net>,
        David Drysdale <drysdale@google.com>,
        "David S . Miller" <davem@davemloft.net>,
        "Eric W . Biederman" <ebiederm@xmission.com>,
        James Morris <james.l.morris@oracle.com>,
        Jann Horn <jann@thejh.net>, Jonathan Corbet <corbet@lwn.net>,
        Matthew Garrett <mjg59@srcf.ucam.org>,
        Michael Kerrisk <mtk.manpages@gmail.com>,
        Kees Cook <keescook@chromium.org>,
        Paul Moore <paul@paul-moore.com>,
        Sargun Dhillon <sargun@sargun.me>,
        "Serge E . Hallyn" <serge@hallyn.com>,
        Shuah Khan <shuah@kernel.org>, Tejun Heo <tj@kernel.org>,
        Thomas Graf <tgr
To: =?iso-8859-1?Q?Micka=EBl_Sala=FCn?= <mic@digikod.net>
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <3325bd7d-f3d8-2f51-384c-b5e8cee5cb91@digikod.net>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Sun, Aug 27, 2017 at 03:31:35PM +0200, Mickaël Salaün wrote:
> 
> > How can you add 3rd argument? All FS events would have to get it,
> > but in some LSM hooks such argument will be meaningless, whereas
> > in other places it will carry useful info that rule can operate on.
> > Would that mean that we'll have FS_3 event type and only few LSM
> > hooks will be converted to it. That works, but then we'll lose
> > compatiblity with old rules written for FS event and that given hook.
> > Otherwise we'd need to have fancy logic to accept old FS event
> > into FS_3 LSM hook.
> 
> If we want to add a third argument to the FS event, then it will become
> accessible because its type will be different than NOT_INIT. This keep
> the compatibility with old rules because this new field was then denied.
> 
> If we want to add a new argument but only for a subset of the hooks used
> by the FS event, then we need to create a new event, like FS_FCNTL. For
> example, we may want to add a FS_RENAME event to be able to tie the
> source file and the destination file of a rename call.

that's exactly my point. To add another argument FS event
to a subset of hooks will require either new FS_FOO and
to be backwards compatible these hooks will call _both_ FS and FS_FOO
or some magic logic on kernel side that will allow old FS rules
to be attached to FS_FOO hooks?
Two calls doesn't scale and if we do 'magic logic' can we do it now
and avoid introducing events altogether?
Like all landlock programs can be landlock type and they would need
to declare what arg1, arg2, argN they expect. Then at attach
time the kernel only needs to verify that hook arg types match
what program requested.

> Anyway, I added the subtype/ABI version as a safeguard in case of
> unexpected future evolution.

I don't think that abi/version field adds anything in this context.
I still think it should simply be removed.
