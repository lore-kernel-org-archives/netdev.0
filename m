From: Alexei Starovoitov <ast@plumgrid.com>
Subject: Re: [PATCH v9 tip 3/9] tracing: attach BPF programs to kprobes
Date: Sun, 22 Mar 2015 11:03:46 -0700
Message-ID: <550F0402.80900@plumgrid.com>
References: <1426894210-27441-1-git-send-email-ast@plumgrid.com> <1426894210-27441-4-git-send-email-ast@plumgrid.com> <550D60C2.8010502@hitachi.com> <550D962E.7010400@plumgrid.com> <550E9421.7030507@hitachi.com>
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
Received: from mail-ie0-f175.google.com ([209.85.223.175]:34568 "EHLO
	mail-ie0-f175.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751752AbbCVSDr (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 22 Mar 2015 14:03:47 -0400
Received: by iedfl3 with SMTP id fl3so25230384ied.1
        for <netdev@vger.kernel.org>; Sun, 22 Mar 2015 11:03:46 -0700 (PDT)
In-Reply-To: <550E9421.7030507@hitachi.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 3/22/15 3:06 AM, Masami Hiramatsu wrote:
> (2015/03/22 1:02), Alexei Starovoitov wrote:
>> On 3/21/15 5:14 AM, Masami Hiramatsu wrote:
>>> (2015/03/21 8:30), Alexei Starovoitov wrote:
>>>>
>>>> Note, kprobes are _not_ a stable kernel ABI, so bpf programs attached to
>>>> kprobes must be recompiled for every kernel version and user must supply correct
>>>> LINUX_VERSION_CODE in attr.kern_version during bpf_prog_load() call.
>>>>
>>>
>>> Would you mean that the ABI of kprobe-based BPF programs? Kprobe API/ABIs
>>> (register_kprobe() etc.) are stable, but the code who use kprobes certainly
>>> depends the kernel binary by design. So, if you meant it, BPF programs must
>>> be recompiled for every kernel binaries (including configuration changes,
>>> not only its version).
>>
>> yes. I mainly meant that bpf+kprobe programs must be recompiled
>> for every kernel binary.
> 
> Hmm, if so, as we do in perf (and systemtap too), you'd better check
> kernel's build-id instead of the kernel version when loading the
> BPF program. It is safer than the KERNEL_VERSION_CODE.

It's not about safety. As I mentioned in cover letter:
"version check is not used for safety, but for enforcing 'non-ABI-ness'"
In other words it's like check-box next to 'terms and conditions'
paragraph that the user has to click before he can continue.
By providing 'kern_version' during loading the user accepts the fact
that bpf+kprobe is not a stable ABI. Nothing more and nothing less.
build-id cannot achieve that, because it cannot be checked from inside
the kernel.
User space tools that will compile ktap/dtrace scripts into bpf might
use build-id for their own purpose, but that's a different discussion.
