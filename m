From: Kees Cook <keescook@chromium.org>
Subject: Re: v5 of seccomp filter c/r patches
Date: Fri, 2 Oct 2015 16:00:45 -0700
Message-ID: <CAGXu5jJHJrG7ia43Va=ft6CS4-2Yd4nVmPV-K1ge_5+TOPA96g@mail.gmail.com>
References: <1443803243-25912-1-git-send-email-tycho.andersen@canonical.com>
	<CAGXu5jJJoM3NdwSmigWy8trTBATsvkGUDmbZ02QOyU=1tD0Y-w@mail.gmail.com>
	<20151002224443.GN23065@smitten>
	<560F0BED.2070304@iogearbox.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: Tycho Andersen <tycho.andersen@canonical.com>,
	Alexei Starovoitov <ast@kernel.org>,
	Will Drewry <wad@chromium.org>,
	Oleg Nesterov <oleg@redhat.com>,
	Andy Lutomirski <luto@amacapital.net>,
	Pavel Emelyanov <xemul@parallels.com>,
	"Serge E. Hallyn" <serge.hallyn@ubuntu.com>,
	LKML <linux-kernel@vger.kernel.org>,
	Network Development <netdev@vger.kernel.org>,
	Linux API <linux-api@vger.kernel.org>
To: Daniel Borkmann <daniel@iogearbox.net>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <560F0BED.2070304@iogearbox.net>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Fri, Oct 2, 2015 at 3:57 PM, Daniel Borkmann <daniel@iogearbox.net> wrote:
> On 10/03/2015 12:44 AM, Tycho Andersen wrote:
>>
>> On Fri, Oct 02, 2015 at 02:10:24PM -0700, Kees Cook wrote:
>
> ...
>>
>> Ok, how about,
>>
>> struct sock_filter insns[BPF_MAXINSNS];
>> insn_cnt = ptrace(PTRACE_SECCOMP_GET_FILTER, pid, insns, i);
>
>
> Would also be good that when the storage buffer (insns) is NULL,
> it just returns you the number of sock_filter insns (or 0 when
> nothing attached).
>
> That would be consistent with classic socket filters (see
> sk_get_filter()), and user space could allocate a specific
> size instead of always passing in max insns.

Yes please. :)

>> when asking for the ith filter? It returns either the number of
>> instructions, -EINVAL if something was wrong (i, pid,
>> CONFIG_CHECKPOINT_RESTORE isn't enabled). While it would always
>> succeed now, if/when the underlying filter was not created from a bpf
>> classic filter, we can return -EMEDIUMTYPE? (Suggestions welcome, I
>> picked this mostly based on what sounds nice.)

We can bikeshed the non-classic case when we need it, but I think
EINVAL is "not under seccomp", and ENOENT is "no such index".

-Kees

-- 
Kees Cook
Chrome OS Security
