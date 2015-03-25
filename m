From: Masami Hiramatsu <masami.hiramatsu.pt-FCd8Q96Dh0JBDgjK7y7TUQ@public.gmane.org>
Subject: Re: bpf+tracing next steps. Was: [PATCH v9 tip 3/9] tracing: attach
 BPF programs to kprobes
Date: Wed, 25 Mar 2015 21:07:07 +0900
Message-ID: <5512A4EB.90604@hitachi.com>
References: <1426894210-27441-1-git-send-email-ast@plumgrid.com> <1426894210-27441-4-git-send-email-ast@plumgrid.com> <550D60C2.8010502@hitachi.com> <550D962E.7010400@plumgrid.com> <550E9421.7030507@hitachi.com> <550F0402.80900@plumgrid.com> <550F77B3.1020802@hitachi.com> <550F9D20.7070006@plumgrid.com> <550FDC8A.5010100@hitachi.com> <5512040B.3020605@plumgrid.com>
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
In-Reply-To: <5512040B.3020605-uqk4Ao+rVK5Wk0Htik3J/w@public.gmane.org>
Sender: linux-api-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

(2015/03/25 9:40), Alexei Starovoitov wrote:
> On 3/23/15 2:27 AM, Masami Hiramatsu wrote:
>> (2015/03/23 13:57), Alexei Starovoitov wrote:
>>> On 3/22/15 7:17 PM, Masami Hiramatsu wrote:
>>>> (2015/03/23 3:03), Alexei Starovoitov wrote:
>>>>
>>>>> User space tools that will compile ktap/dtrace scripts into bpf might
>>>>> use build-id for their own purpose, but that's a different discussion.
>>>>
>>>> Agreed.
>>>> I'd like to discuss it since kprobe event interface may also have same
>>>> issue.
>>>
>>> I'm not sure what 'issue' you're seeing. My understanding is that
>>> build-ids are used by perf to associate binaries with their debug info
>>> and by systemtap to make sure that probes actually match the kernel
>>> they were compiled for. In bpf case it probably will be perf way only.
>>
>> Ah, I see. So perftools can check the build-id if needed, right?
> 
> yes. of course.
> 
>>> Are you interested in doing something with bpf ? ;)
>>
>> Of course :)
> 
> Great :)
> 
>>> I know that Jovi is working on clang-based front-end, He Kuang is doing
>>> something fancy and I'm going to focus on 'tcp instrumentation' once
>>> bpf+kprobes is in. I think these efforts will help us make it
>>> concrete and will establish a path towards bpf+tracepoints
>>> (debug tracepoints or trace markers) and eventual integration with perf.
>>> Here is the wish-list (for kernel and userspace) inspired by Brendan:
>>> - access to pid, uid, tid, comm, etc
>>> - access to kernel stack trace
>>> - access to user-level stack trace
>>> - kernel debuginfo for walking kernel structs, and accessing kprobe
>>> entry args as variables
>>
>> perf probe can provide this to bpf.
> 
> I was thinking about deeper integration with perf actually.
> perf has all the right infra to find debug info in kernel and user
> binaries, to extract and understand all the dwarf stuff.
> The future tracing language can use more of it.
> The programs should be able refer to names of in-kernel variables
> and arguments natively.
> When I'm writing a program that attaches to blk_update_request()
> I would like to write:
> bpf_printk("req %p bytes %d\n", req->q, nr_bytes);
> and perf with debug info should be able to figure out that 'req'
> is the first function argument, then find out offset of '->q'
> within the struct and that 'nr_bytes' is the 3rd argument in
> appropriate register. Then generate llvm ir on the fly,
> compile it, load into kernel and attach to kprobe event at
> this blk_update_request() function. All seamlessly.

Yes, that is what perf probe providing now. I think it is easy
to do that with probe-finder.c. :)

>>> - tracing of uprobes
>>> - tracing of user markers
>>
>> I'm working on the perf-cache which will also support SDT (based on Hemant Kumar's work).
> 
> yep. waiting for SDT stuff to finalize. Would be nice to
> have 'follow' button for interesting patches :)

:)

Thank you!


-- 
Masami HIRAMATSU
Software Platform Research Dept. Linux Technology Research Center
Hitachi, Ltd., Yokohama Research Laboratory
E-mail: masami.hiramatsu.pt-FCd8Q96Dh0JBDgjK7y7TUQ@public.gmane.org
