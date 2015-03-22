From: Masami Hiramatsu <masami.hiramatsu.pt-FCd8Q96Dh0JBDgjK7y7TUQ@public.gmane.org>
Subject: Re: Re: [PATCH v9 tip 3/9] tracing: attach BPF programs to kprobes
Date: Sun, 22 Mar 2015 19:06:25 +0900
Message-ID: <550E9421.7030507@hitachi.com>
References: <1426894210-27441-1-git-send-email-ast@plumgrid.com> <1426894210-27441-4-git-send-email-ast@plumgrid.com> <550D60C2.8010502@hitachi.com> <550D962E.7010400@plumgrid.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-2022-JP
Content-Transfer-Encoding: 7bit
Cc: Ingo Molnar <mingo-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org>,
	Steven Rostedt <rostedt-nx8X9YLhiw1AfugRpC6u6w@public.gmane.org>,
	Namhyung Kim <namhyung-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org>,
	Arnaldo Carvalho de Melo <acme-wEGCiKHe2LqWVfeAwA7xHQ@public.gmane.org>,
	Jiri Olsa <jolsa-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>,
	"David S. Miller" <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>,
	Daniel Borkmann <daniel-FeC+5ew28dpmcu3hnIyYJQ@public.gmane.org>,
	Peter Zijlstra <a.p.zijlstra-/NLkJaSkS4VmR6Xm/wNWPw@public.gmane.org>,
	linux-api-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
To: Alexei Starovoitov <ast-uqk4Ao+rVK5Wk0Htik3J/w@public.gmane.org>
Return-path: <linux-api-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <550D962E.7010400-uqk4Ao+rVK5Wk0Htik3J/w@public.gmane.org>
Sender: linux-api-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

(2015/03/22 1:02), Alexei Starovoitov wrote:
> On 3/21/15 5:14 AM, Masami Hiramatsu wrote:
>> (2015/03/21 8:30), Alexei Starovoitov wrote:
>>>
>>> Note, kprobes are _not_ a stable kernel ABI, so bpf programs attached to
>>> kprobes must be recompiled for every kernel version and user must supply correct
>>> LINUX_VERSION_CODE in attr.kern_version during bpf_prog_load() call.
>>>
>>
>> Would you mean that the ABI of kprobe-based BPF programs? Kprobe API/ABIs
>> (register_kprobe() etc.) are stable, but the code who use kprobes certainly
>> depends the kernel binary by design. So, if you meant it, BPF programs must
>> be recompiled for every kernel binaries (including configuration changes,
>> not only its version).
> 
> yes. I mainly meant that bpf+kprobe programs must be recompiled
> for every kernel binary.

Hmm, if so, as we do in perf (and systemtap too), you'd better check
kernel's build-id instead of the kernel version when loading the
BPF program. It is safer than the KERNEL_VERSION_CODE.

> But you're incorrect saying that register_kprobe API is stable.
> It's equally kernel dependent.
> register_kprobe(struct kprobe *p) is export_gpl, but it takes
> kernel internal 'struct kprobe' and it's not declared in uapi header.
> Prototype of kprobe_handler_t is also kernel internal, so whoever
> is using kprobes must recompile their code every time.
> If we want, we can change register_kprobe function name to something
> else. Just like kernel modules cannot expect that exported symbols
> will stay around from version to version. We don't care when we
> break out of tree modules.

Indeed the register_kprobe (and other kprobe related functions)
should not be treated as a stable userland exported ABI/API. :)

Thank you,

-- 
Masami HIRAMATSU
Software Platform Research Dept. Linux Technology Research Center
Hitachi, Ltd., Yokohama Research Laboratory
E-mail: masami.hiramatsu.pt-FCd8Q96Dh0JBDgjK7y7TUQ@public.gmane.org
