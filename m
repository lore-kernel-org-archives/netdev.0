From: Andy Lutomirski <luto@amacapital.net>
Subject: Re: [PATCH RFC v4 net-next 17/26] tracing: allow eBPF programs to be
 attached to events
Date: Fri, 15 Aug 2014 10:25:44 -0700
Message-ID: <CALCETrV7vO6r--G2ns+A6qmDQYSzNXeemT=x41EF+XWmayM95g@mail.gmail.com>
References: <1407916658-8731-1-git-send-email-ast@plumgrid.com> <1407916658-8731-18-git-send-email-ast@plumgrid.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: "David S. Miller" <davem@davemloft.net>,
	Ingo Molnar <mingo@kernel.org>,
	Linus Torvalds <torvalds@linux-foundation.org>,
	Steven Rostedt <rostedt@goodmis.org>,
	Daniel Borkmann <dborkman@redhat.com>,
	Chema Gonzalez <chema@google.com>,
	Eric Dumazet <edumazet@google.com>,
	Peter Zijlstra <a.p.zijlstra@chello.nl>,
	"H. Peter Anvin" <hpa@zytor.com>,
	Andrew Morton <akpm@linux-foundation.org>,
	Kees Cook <keescook@chromium.org>,
	Linux API <linux-api@vger.kernel.org>,
	Network Development <netdev@vger.kernel.org>,
	"linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>
To: Alexei Starovoitov <ast@plumgrid.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1407916658-8731-18-git-send-email-ast@plumgrid.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Wed, Aug 13, 2014 at 12:57 AM, Alexei Starovoitov <ast@plumgrid.com> wrote:
> User interface:
> fd = open("/sys/kernel/debug/tracing/__event__/filter")
>
> write(fd, "bpf_123")

I didn't follow all the code flow leading to parsing the "bpf_123"
string, but if it works the way I imagine it does, it's a security
problem.  In general, write(2) should never do anything that involves
any security-relevant context of the caller.

Ideally, you would look up fd 123 in the file table of whomever called
open.  If that's difficult to implement efficiently, then it would be
nice to have some check that the callers of write(2) and open(2) are
the same task and that exec wasn't called in between.

This isn't a very severe security issue because you need privilege to
open the thing in the first place, but it would still be nice to
address.

--Andy
