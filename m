From: Alexei Starovoitov <ast@plumgrid.com>
Subject: Re: [PATCH v5 tip 1/7] bpf: make internal bpf API independent of
 CONFIG_BPF_SYSCALL ifdefs
Date: Mon, 2 Mar 2015 08:58:19 -0800
Message-ID: <CAMEtUuwh_P36K6+7NweYLsKrpnbLiNOtAazfJiKk8pUQfszfQg@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: Masami Hiramatsu <masami.hiramatsu.pt@hitachi.com>,
	Ingo Molnar <mingo@kernel.org>,
	Steven Rostedt <rostedt@goodmis.org>,
	Namhyung Kim <namhyung@kernel.org>,
	Arnaldo Carvalho de Melo <acme@infradead.org>,
	Jiri Olsa <jolsa@redhat.com>,
	"David S. Miller" <davem@davemloft.net>,
	Peter Zijlstra <a.p.zijlstra@chello.nl>,
	Linux API <linux-api@vger.kernel.org>,
	Network Development <netdev@vger.kernel.org>,
	LKML <linux-kernel@vger.kernel.org>
To: Daniel Borkmann <daniel@iogearbox.net>
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Mon, Mar 2, 2015 at 4:26 AM, Daniel Borkmann <daniel@iogearbox.net> wrote:
> On 03/02/2015 12:51 PM, Masami Hiramatsu wrote:
>> (2015/03/02 20:10), Daniel Borkmann wrote:
>>>
>>> Well, currently all possible map types (hash table, array map) that
>>> would actually call into bpf_register_map_type() are only built when
>>> CONFIG_BPF_SYSCALL is enabled (see kernel/bpf/Makefile). I don't think
>>> new map additions should be added that are not under kernel/bpf/ and/or
>>> enabled outside the CONFIG_BPF_SYSCALL, as it should be considered
>>> part of the eBPF core code.

agree. New map types will be only under kernel/bpf/
since this is really core infra that every component should be
able to share.

>>> The difference here (this patch) is simply that we don't want users to
>>> build ifdef spaghetti constructs in user code, so the API that is
>>> actually used by eBPF _users_ is being properly ifdef'ed in the headers.

+1

>> Or, maybe we'd better move them into new include/linux/bpf_prog.h which
>> includes basic include/linux/bpf.h. Then, user can include the bpf_prog.h
>> instead of bpf.h. Also, we can check CONFIG_BPF_SYSCAL=y at the top of
>> bpf_prog.h. This makes things clearer :)
>
> I'm preferring the 1st variant, though. We have currently two native eBPF
> users, that is, socket filters and tc's cls_bpf (queued in net-next) and
> looking at the code/API usage, it's really not that hard, where it would
> justify to move this to an extra header file, really.

agree. new header seems overkill to fix something
that is not an issue today.
