From: Hagen Paul Pfeifer <hagen@jauu.net>
Subject: Re: [PATCH v3 net-next 1/1] bpf32->bpf64 mapper and bpf64 interpreter
Date: Mon, 3 Mar 2014 11:05:01 +0100
Message-ID: <20140303100501.GB1108@localhost.localdomain>
References: <1393468732-3919-1-git-send-email-ast@plumgrid.com>
 <1393468732-3919-2-git-send-email-ast@plumgrid.com>
 <531084E0.5080601@redhat.com>
 <CAMEtUuw9aQaBQR-CQq8hdk+8WFqadG0u1fz3pDTsedhXSkQzTg@mail.gmail.com>
 <53112A08.5080309@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Alexei Starovoitov <ast@plumgrid.com>,
	"David S. Miller" <davem@davemloft.net>,
	Ingo Molnar <mingo@kernel.org>,
	Steven Rostedt <rostedt@goodmis.org>,
	Peter Zijlstra <a.p.zijlstra@chello.nl>,
	"H. Peter Anvin" <hpa@zytor.com>,
	Thomas Gleixner <tglx@linutronix.de>,
	Masami Hiramatsu <masami.hiramatsu.pt@hitachi.com>,
	Tom Zanussi <tom.zanussi@linux.intel.com>,
	Jovi Zhangwei <jovi.zhangwei@gmail.com>,
	Eric Dumazet <edumazet@google.com>,
	Linus Torvalds <torvalds@linux-foundation.org>,
	Andrew Morton <akpm@linux-foundation.org>,
	Frederic Weisbecker <fweisbec@gmail.com>,
	Arnaldo Carvalho de Melo <acme@infradead.org>,
	Pekka Enberg <penberg@iki.fi>,
	Arjan van de Ven <arjan@infradead.org>,
	Christoph Hellwig <hch@infradead.org>,
	linux-kernel@vger.kernel.org, netdev@vger.kernel.org,
	Jesse Gross <jesse@nicira.com>
To: Daniel Borkmann <dborkman@redhat.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <53112A08.5080309@redhat.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

* Daniel Borkmann | 2014-03-01 01:30:00 [+0100]:

>>>as in 'struct bpf_insn' the immediate value is 32 bit, so for 64 bit
>>>comparisons, you'd still need to load to immediate values, right?
>>
>>there is no insn that use 64-bit immediate, since 64-bit immediates
>>are extremely rare. grep x86-64 asm code for movabsq will return very few.
>>llvm or gcc can easily construct any constant by combination of mov,
>>shifts and ors.
>>bpf64 comparisons are all 64-bit right now. So far I didn't see a need to do
>>32-bit comparison, since old bpf is all unsigned, mapping 32->64 of
>>Jxx is painless.
>
>Hm, fair enough, I was just thinking for comparisons of IPv6 addresses
>when we do socket filtering. On the other hand, old and new insns are
>both 64 bit wide and can be used though the same api then.

What about the long term idea to support JITed nftables? A 128 bit immediate
is required - maybe the biggest requirement for nftable support.

Hagen
