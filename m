From: Alexei Starovoitov <ast@plumgrid.com>
Subject: bpf+tracing next steps. Was: [PATCH v9 tip 3/9] tracing: attach BPF
 programs to kprobes
Date: Sun, 22 Mar 2015 21:57:04 -0700
Message-ID: <550F9D20.7070006@plumgrid.com>
References: <1426894210-27441-1-git-send-email-ast@plumgrid.com> <1426894210-27441-4-git-send-email-ast@plumgrid.com> <550D60C2.8010502@hitachi.com> <550D962E.7010400@plumgrid.com> <550E9421.7030507@hitachi.com> <550F0402.80900@plumgrid.com> <550F77B3.1020802@hitachi.com>
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
Received: from mail-ie0-f175.google.com ([209.85.223.175]:32794 "EHLO
	mail-ie0-f175.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751766AbbCWE5D (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 23 Mar 2015 00:57:03 -0400
Received: by iecvj10 with SMTP id vj10so27771850iec.0
        for <netdev@vger.kernel.org>; Sun, 22 Mar 2015 21:57:02 -0700 (PDT)
In-Reply-To: <550F77B3.1020802@hitachi.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 3/22/15 7:17 PM, Masami Hiramatsu wrote:
> (2015/03/23 3:03), Alexei Starovoitov wrote:
> 
>> User space tools that will compile ktap/dtrace scripts into bpf might
>> use build-id for their own purpose, but that's a different discussion.
> 
> Agreed.
> I'd like to discuss it since kprobe event interface may also have same
> issue.

I'm not sure what 'issue' you're seeing. My understanding is that
build-ids are used by perf to associate binaries with their debug info
and by systemtap to make sure that probes actually match the kernel
they were compiled for. In bpf case it probably will be perf way only.
Are you interested in doing something with bpf ? ;)
I know that Jovi is working on clang-based front-end, He Kuang is doing
something fancy and I'm going to focus on 'tcp instrumentation' once
bpf+kprobes is in. I think these efforts will help us make it
concrete and will establish a path towards bpf+tracepoints
(debug tracepoints or trace markers) and eventual integration with perf.
Here is the wish-list (for kernel and userspace) inspired by Brendan:
- access to pid, uid, tid, comm, etc
- access to kernel stack trace
- access to user-level stack trace
- kernel debuginfo for walking kernel structs, and accessing kprobe
entry args as variables
- tracing of uprobes
- tracing of user markers
- user debuginfo for user structs and args
- easy to use language
- library of scripting features
- nice one-liner syntax

I think there is a lot of interest in bpf+tracing and would be good to
align the efforts.
