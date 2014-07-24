From: Alexei Starovoitov <ast@plumgrid.com>
Subject: Re: [PATCH RFC v2 net-next 10/16] bpf: add eBPF verifier
Date: Wed, 23 Jul 2014 22:01:18 -0700
Message-ID: <CAMEtUuzYD-WqxhDeq9tMhOKi+w9QCDdTbzpzaGgsnR83yEvz1A@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: "David S. Miller" <davem@davemloft.net>,
	Ingo Molnar <mingo@kernel.org>,
	Linus Torvalds <torvalds@linux-foundation.org>,
	Andy Lutomirski <luto@amacapital.net>,
	Steven Rostedt <rostedt@goodmis.org>,
	Daniel Borkmann <dborkman@redhat.com>,
	Chema Gonzalez <chema@google.com>,
	Eric Dumazet <edumazet@google.com>,
	Peter Zijlstra <a.p.zijlstra@chello.nl>,
	Arnaldo Carvalho de Melo <acme@infradead.org>,
	Jiri Olsa <jolsa@redhat.com>,
	Thomas Gleixner <tglx@linutronix.de>,
	"H. Peter Anvin" <hpa@zytor.com>,
	Andrew Morton <akpm@linux-foundation.org>,
	Linux API <linux-api@vger.kernel.org>,
	Network Development <netdev@vger.kernel.org>,
	LKML <linux-kernel@vger.kernel.org>
To: Kees Cook <keescook@chromium.org>
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Wed, Jul 23, 2014 at 5:48 PM, Alexei Starovoitov <ast@plumgrid.com> wrote:
> check_reg_arg() is indeed incorrect here. Will fix. That was a good catch.
> Thank you for review!

I fixed this missing check_reg_arg() check, addressed feedback for
other patches, rebased it and pushed it:
https://git.kernel.org/cgit/linux/kernel/git/ast/bpf.git/log/

Also replaced dump into syslog from verifier with print into user supplied
buffer, so that user space can see why verifier rejected the program.
The more I play with it the more I like fd-based user interface. Cannot
thank enough Andy for suggesting it :)
Currently map_id is still there as kernel internal id that programs are
using to access maps. I'll try to replace it with direct pointer.
That will save one idr_find() lookup in critical path. That's a good
reason to add new 16-byte eBPF instruction. It will be
"load 64-bit immediate" that we've discussed before.
