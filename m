From: Alexei Starovoitov <ast@plumgrid.com>
Subject: Re: bpf+tracing next steps. Was: [PATCH v9 tip 3/9] tracing: attach
 BPF programs to kprobes
Date: Tue, 24 Mar 2015 17:40:43 -0700
Message-ID: <5512040B.3020605@plumgrid.com>
References: <1426894210-27441-1-git-send-email-ast@plumgrid.com> <1426894210-27441-4-git-send-email-ast@plumgrid.com> <550D60C2.8010502@hitachi.com> <550D962E.7010400@plumgrid.com> <550E9421.7030507@hitachi.com> <550F0402.80900@plumgrid.com> <550F77B3.1020802@hitachi.com> <550F9D20.7070006@plumgrid.com> <550FDC8A.5010100@hitachi.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=iso-2022-jp
Content-Transfer-Encoding: 7bit
Cc: Ingo Molnar <mingo@kernel.org>,
	Steven Rostedt <rostedt@goodmis.org>,
	Namhyung Kim <namhyung@kernel.org>,
	Arnaldo Carvalho de Melo <acme@infradead.org>,
	Jiri Olsa <jolsa@redhat.com>,
	"David S. Miller" <davem@davemloft.net>,
	Daniel Borkmann <daniel@iogearbox.net>,
	Peter Zijlstra <a.p.zijlstra@chello.nl>,
	linux-api@vger.kernel.org, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: Masami Hiramatsu <masami.hiramatsu.pt@hitachi.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pd0-f175.google.com ([209.85.192.175]:35877 "EHLO
	mail-pd0-f175.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752860AbbCYAks (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 24 Mar 2015 20:40:48 -0400
Received: by pdbcz9 with SMTP id cz9so10038548pdb.3
        for <netdev@vger.kernel.org>; Tue, 24 Mar 2015 17:40:47 -0700 (PDT)
In-Reply-To: <550FDC8A.5010100@hitachi.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 3/23/15 2:27 AM, Masami Hiramatsu wrote:
> (2015/03/23 13:57), Alexei Starovoitov wrote:
>> On 3/22/15 7:17 PM, Masami Hiramatsu wrote:
>>> (2015/03/23 3:03), Alexei Starovoitov wrote:
>>>
>>>> User space tools that will compile ktap/dtrace scripts into bpf might
>>>> use build-id for their own purpose, but that's a different discussion.
>>>
>>> Agreed.
>>> I'd like to discuss it since kprobe event interface may also have same
>>> issue.
>>
>> I'm not sure what 'issue' you're seeing. My understanding is that
>> build-ids are used by perf to associate binaries with their debug info
>> and by systemtap to make sure that probes actually match the kernel
>> they were compiled for. In bpf case it probably will be perf way only.
> 
> Ah, I see. So perftools can check the build-id if needed, right?

yes. of course.

>> Are you interested in doing something with bpf ? ;)
> 
> Of course :)

Great :)

>> I know that Jovi is working on clang-based front-end, He Kuang is doing
>> something fancy and I'm going to focus on 'tcp instrumentation' once
>> bpf+kprobes is in. I think these efforts will help us make it
>> concrete and will establish a path towards bpf+tracepoints
>> (debug tracepoints or trace markers) and eventual integration with perf.
>> Here is the wish-list (for kernel and userspace) inspired by Brendan:
>> - access to pid, uid, tid, comm, etc
>> - access to kernel stack trace
>> - access to user-level stack trace
>> - kernel debuginfo for walking kernel structs, and accessing kprobe
>> entry args as variables
> 
> perf probe can provide this to bpf.

I was thinking about deeper integration with perf actually.
perf has all the right infra to find debug info in kernel and user
binaries, to extract and understand all the dwarf stuff.
The future tracing language can use more of it.
The programs should be able refer to names of in-kernel variables
and arguments natively.
When I'm writing a program that attaches to blk_update_request()
I would like to write:
bpf_printk("req %p bytes %d\n", req->q, nr_bytes);
and perf with debug info should be able to figure out that 'req'
is the first function argument, then find out offset of '->q'
within the struct and that 'nr_bytes' is the 3rd argument in
appropriate register. Then generate llvm ir on the fly,
compile it, load into kernel and attach to kprobe event at
this blk_update_request() function. All seamlessly.

>> - tracing of uprobes
>> - tracing of user markers
> 
> I'm working on the perf-cache which will also support SDT (based on Hemant Kumar's work).

yep. waiting for SDT stuff to finalize. Would be nice to
have 'follow' button for interesting patches :)
