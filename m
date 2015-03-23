From: Masami Hiramatsu <masami.hiramatsu.pt-FCd8Q96Dh0JBDgjK7y7TUQ@public.gmane.org>
Subject: Re: Re: [PATCH v9 tip 3/9] tracing: attach BPF programs to kprobes
Date: Mon, 23 Mar 2015 11:17:23 +0900
Message-ID: <550F77B3.1020802@hitachi.com>
References: <1426894210-27441-1-git-send-email-ast@plumgrid.com> <1426894210-27441-4-git-send-email-ast@plumgrid.com> <550D60C2.8010502@hitachi.com> <550D962E.7010400@plumgrid.com> <550E9421.7030507@hitachi.com> <550F0402.80900@plumgrid.com>
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
In-Reply-To: <550F0402.80900-uqk4Ao+rVK5Wk0Htik3J/w@public.gmane.org>
Sender: linux-api-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

(2015/03/23 3:03), Alexei Starovoitov wrote:
> On 3/22/15 3:06 AM, Masami Hiramatsu wrote:
>> (2015/03/22 1:02), Alexei Starovoitov wrote:
>>> On 3/21/15 5:14 AM, Masami Hiramatsu wrote:
>>>> (2015/03/21 8:30), Alexei Starovoitov wrote:
>>>>>
>>>>> Note, kprobes are _not_ a stable kernel ABI, so bpf programs attached to
>>>>> kprobes must be recompiled for every kernel version and user must supply correct
>>>>> LINUX_VERSION_CODE in attr.kern_version during bpf_prog_load() call.
>>>>>
>>>>
>>>> Would you mean that the ABI of kprobe-based BPF programs? Kprobe API/ABIs
>>>> (register_kprobe() etc.) are stable, but the code who use kprobes certainly
>>>> depends the kernel binary by design. So, if you meant it, BPF programs must
>>>> be recompiled for every kernel binaries (including configuration changes,
>>>> not only its version).
>>>
>>> yes. I mainly meant that bpf+kprobe programs must be recompiled
>>> for every kernel binary.
>>
>> Hmm, if so, as we do in perf (and systemtap too), you'd better check
>> kernel's build-id instead of the kernel version when loading the
>> BPF program. It is safer than the KERNEL_VERSION_CODE.
> 
> It's not about safety. As I mentioned in cover letter:
> "version check is not used for safety, but for enforcing 'non-ABI-ness'"
> In other words it's like check-box next to 'terms and conditions'
> paragraph that the user has to click before he can continue.
> By providing 'kern_version' during loading the user accepts the fact
> that bpf+kprobe is not a stable ABI. Nothing more and nothing less.
> build-id cannot achieve that, because it cannot be checked from inside
> the kernel.

Ah, I see. Hmm, I think we'd better have such interface (kernel API).

> User space tools that will compile ktap/dtrace scripts into bpf might
> use build-id for their own purpose, but that's a different discussion.

Agreed.
I'd like to discuss it since kprobe event interface may also have same
issue.

Thank you,


-- 
Masami HIRAMATSU
Software Platform Research Dept. Linux Technology Research Center
Hitachi, Ltd., Yokohama Research Laboratory
E-mail: masami.hiramatsu.pt-FCd8Q96Dh0JBDgjK7y7TUQ@public.gmane.org
