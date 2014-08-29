From: Alexei Starovoitov <ast-uqk4Ao+rVK5Wk0Htik3J/w@public.gmane.org>
Subject: Re: [PATCH v8 net-next 2/2] net: filter: split filter.h and expose
 eBPF to user space
Date: Fri, 29 Aug 2014 16:01:30 -0700
Message-ID: <CAMEtUuyRUujYhRsH9aUx0h7wvU1DrKRHNWZtoOYEgHVfKdCTxw@mail.gmail.com>
References: <1409171833-6979-1-git-send-email-ast@plumgrid.com>
	<1409171833-6979-3-git-send-email-ast@plumgrid.com>
	<5400BAB7.80001@redhat.com>
	<CAADnVQJbgiUK1vt_SDEG6Yee-Ht67e2M82PrHb3Kx533BOF-rg@mail.gmail.com>
	<5400FDA0.7000704@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: Alexei Starovoitov <alexei.starovoitov-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>,
	"David S. Miller" <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>,
	Ingo Molnar <mingo-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org>,
	Linus Torvalds <torvalds-de/tnXTf+JLsfHDXvbKv3WD2FQJk+8+b@public.gmane.org>,
	Andy Lutomirski <luto-kltTT9wpgjJwATOyAt5JVQ@public.gmane.org>,
	Steven Rostedt <rostedt-nx8X9YLhiw1AfugRpC6u6w@public.gmane.org>,
	Chema Gonzalez <chema-hpIqsD4AKlfQT0dZR+AlfA@public.gmane.org>,
	Eric Dumazet <edumazet-hpIqsD4AKlfQT0dZR+AlfA@public.gmane.org>,
	Peter Zijlstra <a.p.zijlstra-/NLkJaSkS4VmR6Xm/wNWPw@public.gmane.org>,
	Brendan Gregg <brendan.d.gregg-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>,
	Namhyung Kim <namhyung-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org>,
	"H. Peter Anvin" <hpa-YMNOUZJC4hwAvxtiuMwx3w@public.gmane.org>,
	Andrew Morton <akpm-de/tnXTf+JLsfHDXvbKv3WD2FQJk+8+b@public.gmane.org>,
	Kees Cook <keescook-F7+t8E8rja9g9hUCZPvPmw@public.gmane.org>,
	Linux API <linux-api-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
	"netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org" <netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
	"linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org" <linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
To: Daniel Borkmann <dborkman-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>
Return-path: <linux-api-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <5400FDA0.7000704-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>
Sender: linux-api-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

On Fri, Aug 29, 2014 at 3:24 PM, Daniel Borkmann <dborkman-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org> wrote:
>>
>> Also I really dislike 'ebpf' name in all lower case. If we make such
>> header
>> file name, we would need to rename all macros and function names
>> to EBPF_... which I find very ugly looking. I think all good abbreviations
>> are
>> three letters :)
>
>
> I don't think we would have to name defines that way, really, that would be
> terrible. We can keep them simply *as is*. Not sure though why bpf.h +
> ebpf.h
> would be that bad. ;) I haven't tried it out yet, but if we would indeed run
> into a name collision, above proposal would resolve that.

imo it's a consistency issue. If main uapi header is ebpf.h then
corresponding kernel internal header should be ebpf.h as well
and kernel/ebpf/ directory and so on.
That's why I insist on uapi/linux/bpf.h and no other name.
Note I didn't move any of the BPF_ALU64_REG, BPF_ALU32_IMM
macros from linux/filter.h. Without them my verifier testsuite
won't compile, so more lines would be added to bpf.h in the future.
At that time we can take 45 lines out of uapi/linux/filter.h and move
them into bpf_common.h. My request is let's not fight about it
right now. We didn't even cross the bridge yet and arguing
about beauty of user apps that come in 30 patches from now...

These two patches are about _intent_ of making eBPF usable
from userspace, so I can move along with llvm.
Also worth noting that llmv will not be including this uapi/linux/bpf.h
It has its own infra to generate instructions. Look at:
tools/bpf/llvm/lib/Target/BPF/BPFInstrInfo.td
it's a special 'table definition' language for describing bits and fields
of instructions.
So these two patches are mainly establishing _intent_ and bpf.h file
name. That's why I'm so paranoid about naming.

btw, I've spent last two days writing syscall manpage :(
What is the best way to present it for review?
If I just attach it raw, it's unreadable... I can include a link
to html page, but man2html produces ugly pages comparing
to what 'man' command shows. Any nice man converters
that generate stuff seen on man7.org ?
