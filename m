From: Daniel Borkmann <daniel@iogearbox.net>
Subject: Re: v5 of seccomp filter c/r patches
Date: Sat, 03 Oct 2015 00:57:49 +0200
Message-ID: <560F0BED.2070304@iogearbox.net>
References: <1443803243-25912-1-git-send-email-tycho.andersen@canonical.com> <CAGXu5jJJoM3NdwSmigWy8trTBATsvkGUDmbZ02QOyU=1tD0Y-w@mail.gmail.com> <20151002224443.GN23065@smitten>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Alexei Starovoitov <ast@kernel.org>,
	Will Drewry <wad@chromium.org>,
	Oleg Nesterov <oleg@redhat.com>,
	Andy Lutomirski <luto@amacapital.net>,
	Pavel Emelyanov <xemul@parallels.com>,
	"Serge E. Hallyn" <serge.hallyn@ubuntu.com>,
	LKML <linux-kernel@vger.kernel.org>,
	Network Development <netdev@vger.kernel.org>,
	Linux API <linux-api@vger.kernel.org>
To: Tycho Andersen <tycho.andersen@canonical.com>,
	Kees Cook <keescook@chromium.org>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20151002224443.GN23065@smitten>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On 10/03/2015 12:44 AM, Tycho Andersen wrote:
> On Fri, Oct 02, 2015 at 02:10:24PM -0700, Kees Cook wrote:
...
> Ok, how about,
>
> struct sock_filter insns[BPF_MAXINSNS];
> insn_cnt = ptrace(PTRACE_SECCOMP_GET_FILTER, pid, insns, i);

Would also be good that when the storage buffer (insns) is NULL,
it just returns you the number of sock_filter insns (or 0 when
nothing attached).

That would be consistent with classic socket filters (see
sk_get_filter()), and user space could allocate a specific
size instead of always passing in max insns.

> when asking for the ith filter? It returns either the number of
> instructions, -EINVAL if something was wrong (i, pid,
> CONFIG_CHECKPOINT_RESTORE isn't enabled). While it would always
> succeed now, if/when the underlying filter was not created from a bpf
> classic filter, we can return -EMEDIUMTYPE? (Suggestions welcome, I
> picked this mostly based on what sounds nice.)
>
> Tycho
>
