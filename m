From: Alexei Starovoitov <ast@plumgrid.com>
Subject: Re: [PATCH v9 tip 3/9] tracing: attach BPF programs to kprobes
Date: Sat, 21 Mar 2015 09:02:54 -0700
Message-ID: <550D962E.7010400@plumgrid.com>
References: <1426894210-27441-1-git-send-email-ast@plumgrid.com> <1426894210-27441-4-git-send-email-ast@plumgrid.com> <550D60C2.8010502@hitachi.com>
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
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <550D60C2.8010502@hitachi.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On 3/21/15 5:14 AM, Masami Hiramatsu wrote:
> (2015/03/21 8:30), Alexei Starovoitov wrote:
>>
>> Note, kprobes are _not_ a stable kernel ABI, so bpf programs attached to
>> kprobes must be recompiled for every kernel version and user must supply correct
>> LINUX_VERSION_CODE in attr.kern_version during bpf_prog_load() call.
>>
> 
> Would you mean that the ABI of kprobe-based BPF programs? Kprobe API/ABIs
> (register_kprobe() etc.) are stable, but the code who use kprobes certainly
> depends the kernel binary by design. So, if you meant it, BPF programs must
> be recompiled for every kernel binaries (including configuration changes,
> not only its version).

yes. I mainly meant that bpf+kprobe programs must be recompiled
for every kernel binary.
But you're incorrect saying that register_kprobe API is stable.
It's equally kernel dependent.
register_kprobe(struct kprobe *p) is export_gpl, but it takes
kernel internal 'struct kprobe' and it's not declared in uapi header.
Prototype of kprobe_handler_t is also kernel internal, so whoever
is using kprobes must recompile their code every time.
If we want, we can change register_kprobe function name to something
else. Just like kernel modules cannot expect that exported symbols
will stay around from version to version. We don't care when we
break out of tree modules.
