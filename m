From: Kees Cook <keescook@chromium.org>
Subject: Re: [PATCH net-next v6 00/11] Landlock LSM: Toward unprivileged sandboxing
Date: Tue, 18 Apr 2017 16:26:05 -0700
Message-ID: <CAGXu5jLpM13xmFf2_bcWH=db7LEavfpZswvPbAM3+66dBPtMTg@mail.gmail.com>
References: <20170328234650.19695-1-mic@digikod.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: quoted-printable
Cc: LKML <linux-kernel@vger.kernel.org>,
        Alexei Starovoitov <ast@kernel.org>,
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
        Paul Moore <paul@paul-moore.com>,
        Sargun Dhillon <sargun@sargun.me>,
        "Serge E . Hallyn" <serge@hallyn.com>,
        Shuah Khan <shuah@kernel.org>, Tejun Heo <tj@kernel.org>,
        Thomas Graf <tgraf@suug.ch>, Will Drewry <wa
To: =?UTF-8?B?TWlja2HDq2wgU2FsYcO8bg==?= <mic@digikod.net>
Return-path: <linux-security-module-owner@vger.kernel.org>
In-Reply-To: <20170328234650.19695-1-mic@digikod.net>
Sender: owner-linux-security-module@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Tue, Mar 28, 2017 at 4:46 PM, Micka=C3=ABl Sala=C3=BCn <mic@digikod.net>=
 wrote:
> This sixth series add some changes to the previous one [1], including a s=
impler
> rule inheritance hierarchy (similar to seccomp-bpf), a ptrace scope prote=
ction,
> some file renaming (better feature identification per file), a future-pro=
of
> eBPF subtype and miscellaneous cosmetic fixes.

Sorry for the delay in review! I finally had a chunk of time I could
devote to this. I really like how it's heading. I still wonder about
its overlap with seccomp (it's really only using the syscall now...),
but that's just a detail. Getting the abstraction away from direct LSM
hooks looks good.

> There is as yet no way to allow a process to access only a subset of the
> filesystem where the subset is specified via a path or a file descriptor.=
  This
> feature is intentionally left out so as to minimize the amount of code of=
 this
> patch series but will come in a following series.  However, it is possibl=
e to
> check the file type, as done in the following example.

I understand why you've taken a progressive approach here, but I think
there are two fundamental areas where people will use Landlock: path
evaluation and network address evaluation. I think it's worth
expanding this series to include those two confinement examples, since
that can help people understand what the "general" case will look
like.

As I mentioned in one of the patch review emails, I think there needs
to be a clearer explanation of how usage counting works vs the
"events" (which I think of as "rule tables" not events -- maybe it
needs a new name?) and "rule" lists. I think I understand it, but I
spent a lot of time trying to get there. More comments would help.

Finally, another thing I'm curious about is how to deal with the
thread-sync issue. Seccomp uses its TSYNC thing, and I'd expect we'd
want something similar for landlock... but that looks really hairy as
far as locking goes. Perhaps it's already solved by using the same
locking seccomp uses, in which case I'm less inclined to kick landlock
out of seccomp.c. :)

Looks like it's coming along nicely! Thanks for continuing to work on this!

-Kees

--=20
Kees Cook
Pixel Security
