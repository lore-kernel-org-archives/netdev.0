From: Alexei Starovoitov <ast@plumgrid.com>
Subject: Re: [PATCH RFC net-next] tracing: accelerate tracing filters with BPF
Date: Tue, 13 May 2014 20:29:14 -0700
Message-ID: <CAMEtUuzct=k_9f4QTqRf2TG6mFCjpnfTjo+JkHYQDHKj_i2b+A@mail.gmail.com>
References: <1400036111-7803-1-git-send-email-ast@plumgrid.com>
	<20140513231708.7eb39a38@gandalf.local.home>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Ingo Molnar <mingo@kernel.org>,
	"David S. Miller" <davem@davemloft.net>,
	Eric Dumazet <edumazet@google.com>,
	Daniel Borkmann <dborkman@redhat.com>,
	Peter Zijlstra <a.p.zijlstra@chello.nl>,
	Arnaldo Carvalho de Melo <acme@infradead.org>,
	Jiri Olsa <jolsa@redhat.com>,
	Thomas Gleixner <tglx@linutronix.de>,
	"H. Peter Anvin" <hpa@zytor.com>,
	Network Development <netdev@vger.kernel.org>,
	LKML <linux-kernel@vger.kernel.org>
To: Steven Rostedt <rostedt@goodmis.org>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20140513231708.7eb39a38@gandalf.local.home>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Tue, May 13, 2014 at 8:17 PM, Steven Rostedt <rostedt@goodmis.org> w=
rote:
> On Tue, 13 May 2014 19:55:11 -0700
> Alexei Starovoitov <ast@plumgrid.com> wrote:
>
>> Tracing filters are parsing user supplied character string and const=
ructing
>> a predicate tree. filter_match_preds() was used to walk nodes of the=
 tree to
>> simulate matching of boolean expression.
>>
>
> I applied this on top of net-next, from:
>
>  git://git.kernel.org/pub/scm/linux/kernel/git/davem/net-next.git
>  (master branch)
>
> and got this compile error:

Sorry I wasn't clear in the log.
This patch depends on JIT patches that were posted separately.
Since this one is RFC, I didn't want to mix them.
JIT patches:
http://patchwork.ozlabs.org/patch/348558/
http://patchwork.ozlabs.org/patch/348559/
http://patchwork.ozlabs.org/patch/348560/

> kernel/trace/trace_events_filter.c: In function =E2=80=98emit_cond=E2=
=80=99:
> kernel/trace/trace_events_filter.c:1361:36: error: =E2=80=98__bpf_cal=
l_base=E2=80=99 undeclared (first use in this function)
> kernel/trace/trace_events_filter.c:1361:36: note: each undeclared ide=
ntifier is reported only once for each function it appears in
> kernel/trace/trace_events_filter.c: In function =E2=80=98filter_gen_b=
pf=E2=80=99:
> kernel/trace/trace_events_filter.c:1622:2: error: implicit declaratio=
n of function =E2=80=98bpf_int_jit_compile=E2=80=99 [-Werror=3Dimplicit=
-function-declaration]
>
> Config attached.
>
> -- Steve
