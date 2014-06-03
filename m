From: Daniel Borkmann <dborkman@redhat.com>
Subject: Re: [PATCH v2 net-next 0/2] split BPF out of core networking
Date: Tue, 03 Jun 2014 10:56:10 +0200
Message-ID: <538D8DAA.7090105@redhat.com>
References: <1401692506-7796-1-git-send-email-ast@plumgrid.com> <538C3C94.3080206@redhat.com> <CAMEtUuzkjZCsReWH9cZs8AU0mJjZH9YOdCBTWusxe6-NZ9mQ=g@mail.gmail.com> <538CAEA6.4060307@redhat.com> <CAMEtUuwxJOgYgFjg9deQZOffeg6-JUGZXZ1Rj344eQmriQ0F0Q@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8; format=flowed
Content-Transfer-Encoding: 7bit
Cc: "David S. Miller" <davem@davemloft.net>,
	Ingo Molnar <mingo@kernel.org>,
	Steven Rostedt <rostedt@goodmis.org>,
	Chema Gonzalez <chema@google.com>,
	Eric Dumazet <edumazet@google.com>,
	Peter Zijlstra <a.p.zijlstra@chello.nl>,
	Arnaldo Carvalho de Melo <acme@infradead.org>,
	Jiri Olsa <jolsa@redhat.com>,
	Thomas Gleixner <tglx@linutronix.de>,
	"H. Peter Anvin" <hpa@zytor.com>,
	Andrew Morton <akpm@linux-foundation.org>,
	Kees Cook <keescook@chromium.org>,
	Network Development <netdev@vger.kernel.org>,
	LKML <linux-kernel@vger.kernel.org>
To: Alexei Starovoitov <ast@plumgrid.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <CAMEtUuwxJOgYgFjg9deQZOffeg6-JUGZXZ1Rj344eQmriQ0F0Q@mail.gmail.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On 06/02/2014 09:02 PM, Alexei Starovoitov wrote:
...
> Classic has all sorts of hard coded assumptions. The whole
> concept of 'load from magic constant' to mean different things
> is flawed. We all got used to it and now think that it's normal
> for "ld_abs -4056" to mean "a ^= x"

I think everyone knows that, no? Sure it doesn't fit into the
concept, but I think at the time BPF extensions were introduced,
it was probably seen as the best trade-off available to access
useful skb fields while still trying to minimize exposure to uapi
as much as possible.

> This split is not trying to make classic easier to hack.
> With eBPF underneath classic, it got a lot easier to add extensions
> to classic, but we shouldn't be doing it.
> Classic BPF is not generic and cannot become one. It's eBPF's job.
>
> The split is mainly helping to clearly see the boundary of eBPF core
> vs its socket use case. It doesn't change or add any API.

So what's the plan with everything in arch/*/net/, tools/net/ and
in Documentation/networking/filter.txt, plus MAINTAINERS file, that
the current patch doesn't address?

We want changes to go via netdev@vger.kernel.org as they always
did, since [ although other use cases pop up ] the main user, as
I said, is simply still packet filtering in various networking
subsystems, no?

> This in-kernel API cleanup was done in commit 5fe821a9dee2
> You even acked it back then :)

I agreed with that change, otherwise I wouldn't have acked it,
of course.
