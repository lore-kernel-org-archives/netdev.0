From: Andy Lutomirski <luto@amacapital.net>
Subject: Re: [PATCH v5 10/10] landlock: Add user and kernel documentation for Landlock
Date: Tue, 21 Feb 2017 21:21:21 -0800
Message-ID: <CALCETrXzL0VH_=QYHGXk1Y5P_yLyXdyTD-JVHVKTFf8F-AhYnw@mail.gmail.com>
References: <20170222012632.4196-1-mic@digikod.net> <20170222012632.4196-11-mic@digikod.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: quoted-printable
Cc: "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, Alexei Starovoitov <ast@kernel.org>,
	Arnaldo Carvalho de Melo <acme@kernel.org>, Casey Schaufler <casey@schaufler-ca.com>,
	Daniel Borkmann <daniel@iogearbox.net>, David Drysdale <drysdale@google.com>,
	"David S . Miller" <davem@davemloft.net>, "Eric W . Biederman" <ebiederm@xmission.com>,
	James Morris <james.l.morris@oracle.com>, Jann Horn <jann@thejh.net>,
	Jonathan Corbet <corbet@lwn.net>, Matthew Garrett <mjg59@srcf.ucam.org>,
	Michael Kerrisk <mtk.manpages@gmail.com>, Kees Cook <keescook@chromium.org>,
	Paul Moore <paul@paul-moore.com>, Sargun Dhillon <sargun@sargun.me>,
	"Serge E . Hallyn" <serge@hallyn.com>, Shuah Khan <shuah@kernel.org>, Tejun Heo <tj@kernel.org>,
	Thomas Graf <tgraf@suug.ch>, Will Drewry <wad@chromium.org>,
	"kernel-hardening@lists.openwall.com" <kernel-hardening@lists.openwall.com>,
To: =?UTF-8?B?TWlja2HDq2wgU2FsYcO8bg==?= <mic@digikod.net>
Return-path: <kernel-hardening-return-6817-glkh-kernel-hardening=m.gmane.org@lists.openwall.com>
List-Post: <mailto:kernel-hardening@lists.openwall.com>
List-Help: <mailto:kernel-hardening-help@lists.openwall.com>
List-Unsubscribe: <mailto:kernel-hardening-unsubscribe@lists.openwall.com>
List-Subscribe: <mailto:kernel-hardening-subscribe@lists.openwall.com>
In-Reply-To: <20170222012632.4196-11-mic@digikod.net>
List-Id: netdev.vger.kernel.org

On Tue, Feb 21, 2017 at 5:26 PM, Micka=C3=ABl Sala=C3=BCn <mic@digikod.net>=
 wrote:
> This documentation can be built with the Sphinx framework.
>
> Signed-off-by: Micka=C3=ABl Sala=C3=BCn <mic@digikod.net>
> Cc: Alexei Starovoitov <ast@kernel.org>
> Cc: Andy Lutomirski <luto@amacapital.net>
> Cc: Daniel Borkmann <daniel@iogearbox.net>
> Cc: David S. Miller <davem@davemloft.net>
> Cc: James Morris <james.l.morris@oracle.com>
> Cc: Jonathan Corbet <corbet@lwn.net>
> Cc: Kees Cook <keescook@chromium.org>
> Cc: Serge E. Hallyn <serge@hallyn.com>


> +
> +Writing a rule
> +--------------
> +
> +To enforce a security policy, a thread first needs to create a Landlock =
rule.
> +The easiest way to write an eBPF program depicting a security rule is to=
 write
> +it in the C language.  As described in *samples/bpf/README.rst*, LLVM ca=
n
> +compile such programs.  Files *samples/bpf/landlock1_kern.c* and those i=
n
> +*tools/testing/selftests/landlock/rules/* can be used as examples.  The
> +following example is a simple rule to forbid file creation, whatever sys=
call
> +may be used (e.g. open, mkdir, link...).
> +
> +.. code-block:: c
> +
> +    static int deny_file_creation(struct landlock_context *ctx)
> +    {
> +        if (ctx->arg2 & LANDLOCK_ACTION_FS_NEW)
> +            return 1;
> +        return 0;
> +    }
> +

Would it make sense to define landlock_context (or at least a prefix
thereof) in here?  Also, can't "arg2" have a better name?

Can you specify what the return value means?  Are 0 and 1 the only
choices?  Would "KILL" be useful?  How about "COREDUMP"?

> +File system action types
> +------------------------
> +
> +Flags are used to express actions.  This makes it possible to compose ac=
tions
> +and leaves room for future improvements to add more fine-grained action =
types.
> +
> +.. kernel-doc:: include/uapi/linux/bpf.h
> +    :doc: landlock_action_fs
> +
> +.. flat-table:: FS action types availability
> +
> +    * - flags
> +      - since
> +
> +    * - LANDLOCK_ACTION_FS_EXEC
> +      - v1
> +
> +    * - LANDLOCK_ACTION_FS_WRITE
> +      - v1
> +
> +    * - LANDLOCK_ACTION_FS_READ
> +      - v1
> +
> +    * - LANDLOCK_ACTION_FS_NEW
> +      - v1
> +
> +    * - LANDLOCK_ACTION_FS_GET
> +      - v1
> +
> +    * - LANDLOCK_ACTION_FS_REMOVE
> +      - v1
> +
> +    * - LANDLOCK_ACTION_FS_IOCTL
> +      - v1
> +
> +    * - LANDLOCK_ACTION_FS_LOCK
> +      - v1
> +
> +    * - LANDLOCK_ACTION_FS_FCNTL
> +      - v1

What happens if you run an old program on a new kernel?  Can you get
unexpected action types?

> +
> +
> +Ability types
> +-------------
> +
> +The ability of a Landlock rule describes the available features (i.e. co=
ntext
> +fields and helpers).  This is useful to abstract user-space privileges f=
or
> +Landlock rules, which may not need all abilities (e.g. debug).  Only the
> +minimal set of abilities should be used (e.g. disable debug once in
> +production).
> +
> +
> +.. kernel-doc:: include/uapi/linux/bpf.h
> +    :doc: landlock_subtype_ability
> +
> +.. flat-table:: Ability types availability
> +
> +    * - flags
> +      - since
> +      - capability
> +
> +    * - LANDLOCK_SUBTYPE_ABILITY_WRITE
> +      - v1
> +      - CAP_SYS_ADMIN
> +
> +    * - LANDLOCK_SUBTYPE_ABILITY_DEBUG
> +      - v1
> +      - CAP_SYS_ADMIN
> +

What do "WRITE" and "DEBUG" mean in this context?  I'm totally lost.

Hmm.  Reading below, "WRITE" seems to mean "modify state".  Would that
be accurate?

> +
> +Helper functions
> +----------------
> +
> +See *include/uapi/linux/bpf.h* for functions documentation.
> +
> +.. flat-table:: Generic functions availability
> +

> +
> +    * - bpf_get_current_comm
> +      - v1
> +      - LANDLOCK_SUBTYPE_ABILITY_DEBUG

What would this be used for?

> +    * - bpf_get_trace_printk
> +      - v1
> +      - LANDLOCK_SUBTYPE_ABILITY_DEBUG
> +

This is different from the other DEBUG stuff in that it has side
effects.  I wonder if it should have a different flag.

--Andy
