From: Alexei Starovoitov <ast@plumgrid.com>
Subject: Re: [PATCH v6 net-next 1/6] net: filter: add "load 64-bit immediate"
 eBPF instruction
Date: Mon, 25 Aug 2014 21:12:23 -0700
Message-ID: <CAMEtUuz4OGOuhtftnVAvFFS0a_6qPBj=CNsTAc23GzA10+S=bg@mail.gmail.com>
References: <1409014858-1410-1-git-send-email-ast@plumgrid.com>
	<1409014858-1410-2-git-send-email-ast@plumgrid.com>
	<20140825.180621.1003932711320755950.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: Ingo Molnar <mingo@kernel.org>,
	Linus Torvalds <torvalds@linux-foundation.org>,
	Andy Lutomirski <luto@amacapital.net>,
	Steven Rostedt <rostedt@goodmis.org>,
	Daniel Borkmann <dborkman@redhat.com>,
	Chema Gonzalez <chema@google.com>,
	Eric Dumazet <edumazet@google.com>,
	Peter Zijlstra <a.p.zijlstra@chello.nl>,
	Brendan Gregg <brendan.d.gregg@gmail.com>,
	Namhyung Kim <namhyung@kernel.org>,
	"H. Peter Anvin" <hpa@zytor.com>,
	Andrew Morton <akpm@linux-foundation.org>,
	Kees Cook <keescook@chromium.org>,
	Linux API <linux-api@vger.kernel.org>,
	Network Development <netdev@vger.kernel.org>,
	LKML <linux-kernel@vger.kernel.org>
To: David Miller <davem@davemloft.net>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20140825.180621.1003932711320755950.davem@davemloft.net>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Mon, Aug 25, 2014 at 6:06 PM, David Miller <davem@davemloft.net> wrote:
>
> Instead I would rather you look into a model like what the quake
> engine uses for it's VM.

Thanks for the tip! I wasn't aware of quake vm.
I've looked through several papers and slides.
I'm surely missing something in what they're doing, but
here is my comparison of eBPF vs QVM:
- QVM ISA is stack based vs eBPF registers
- pointer types are predefined by QVM ISA whereas eBPF relies
  on static verifier which is more extensible, since verifier can get
  progressively smarter with time without need to change interpreter,
  llvm and JITs, whereas QVM would need changes through the
  toolchain, interpreter, JITs to support new pointer type
- QVM calls with negative values invoke helper functions, which is
  similar to eBPF calls. The difference is QVM keeps negative values
  while interpreting and doing run-time checking of arguments whereas
  eBPF is statically verifying all before interpreting
- access to QVM 'local' memory is bounds checked at run-time,
  whereas eBPF does load/store bounds checking by static analysis

I may be wrong, but it seems possible to side step QVM run-time
checking, since their 'top of stack' is typeless and it seems possible
to push constant as a pointer there.

I'm biased, but eBPF seems like better architecture,
more flexible, likely faster to interpret, simple JITs, more powerful
compiler. The downside, of course, eBPF verifier is more complex
than QVM which is mainly relying on run-time checks.
