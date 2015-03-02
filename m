From: Masami Hiramatsu <masami.hiramatsu.pt@hitachi.com>
Subject: Re: [PATCH v5 tip 1/7] bpf: make internal bpf API independent of
 CONFIG_BPF_SYSCALL ifdefs
Date: Mon, 02 Mar 2015 20:51:31 +0900
Message-ID: <54F44EC3.4070504@hitachi.com>
References: <1425252465-27527-1-git-send-email-ast@plumgrid.com> <1425252465-27527-2-git-send-email-ast@plumgrid.com> <54F44115.40505@hitachi.com> <54F4451B.8000703@iogearbox.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-2022-JP
Content-Transfer-Encoding: 7bit
Cc: Alexei Starovoitov <ast@plumgrid.com>,
	Ingo Molnar <mingo@kernel.org>,
	Steven Rostedt <rostedt@goodmis.org>,
	Namhyung Kim <namhyung@kernel.org>,
	Arnaldo Carvalho de Melo <acme@infradead.org>,
	Jiri Olsa <jolsa@redhat.com>,
	"David S. Miller" <davem@davemloft.net>,
	Peter Zijlstra <a.p.zijlstra@chello.nl>,
	linux-api@vger.kernel.org, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: Daniel Borkmann <daniel@iogearbox.net>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <54F4451B.8000703@iogearbox.net>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

(2015/03/02 20:10), Daniel Borkmann wrote:
> On 03/02/2015 11:53 AM, Masami Hiramatsu wrote:
> ...
>> Hmm, it seems that this still doesn't hide some APIs which is provided
>> only when CONFIG_BPF_SYSCALL. For example bpf_register_map_type etc.
>> I think all those APIs should be hidden in #ifdef or at least be commented
>> so that the user doesn't refer that without the kconfig.
>> (I don't think we need to provide dummy functions for those APIs,
>>   but it's better to clarify which API we can use with which kconfig)
> 
> Well, currently all possible map types (hash table, array map) that
> would actually call into bpf_register_map_type() are only built when
> CONFIG_BPF_SYSCALL is enabled (see kernel/bpf/Makefile). I don't think
> new map additions should be added that are not under kernel/bpf/ and/or
> enabled outside the CONFIG_BPF_SYSCALL, as it should be considered
> part of the eBPF core code.
> 
> The difference here (this patch) is simply that we don't want users to
> build ifdef spaghetti constructs in user code, so the API that is
> actually used by eBPF _users_ is being properly ifdef'ed in the headers.
> 
> So, I don't think this is a big problem, but we could move these bits
> under the ifdef CONFIG_BPF_SYSCALL w/o providing a dummy in the else part.
> I can do that outside of the scope of this set.

Or, maybe we'd better move them into new include/linux/bpf_prog.h which
includes basic include/linux/bpf.h. Then, user can include the bpf_prog.h
instead of bpf.h. Also, we can check CONFIG_BPF_SYSCAL=y at the top of
bpf_prog.h. This makes things clearer :)

Thank you,


-- 
Masami HIRAMATSU
Software Platform Research Dept. Linux Technology Research Center
Hitachi, Ltd., Yokohama Research Laboratory
E-mail: masami.hiramatsu.pt@hitachi.com
