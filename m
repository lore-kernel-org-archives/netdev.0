From: Ingo Molnar <mingo@kernel.org>
Subject: Re: [PATCH v2 net-next 0/2] split BPF out of core networking
Date: Tue, 3 Jun 2014 20:16:46 +0200
Message-ID: <20140603181646.GA5028@gmail.com>
References: <1401692506-7796-1-git-send-email-ast@plumgrid.com>
 <20140602081545.7baf4a91@lwn.net>
 <20140602092456.2114440a@gandalf.local.home>
 <20140602141606.GC2544@kernel.org>
 <CAMEtUuxZQuyJaTfoNECnZCJ=q8A_aMpncGwUgWNm9Huxm=bynw@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Arnaldo Carvalho de Melo <acme@kernel.org>,
	Steven Rostedt <rostedt@goodmis.org>,
	Jonathan Corbet <corbet@lwn.net>,
	"David S. Miller" <davem@davemloft.net>,
	Daniel Borkmann <dborkman@redhat.com>,
	Chema Gonzalez <chema@google.com>,
	Eric Dumazet <edumazet@google.com>,
	Peter Zijlstra <a.p.zijlstra@chello.nl>,
	Jiri Olsa <jolsa@redhat.com>,
	Thomas Gleixner <tglx@linutronix.de>,
	"H. Peter Anvin" <hpa@zytor.com>,
	Andrew Morton <akpm@linux-foundation.org>,
	Kees Cook <keescook@chromium.org>,
	Network Development <netdev@vger.kernel.org>,
	LKML <linux-kernel@vger.kernel.org>
To: Alexei Starovoitov <ast@plumgrid.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <CAMEtUuxZQuyJaTfoNECnZCJ=q8A_aMpncGwUgWNm9Huxm=bynw@mail.gmail.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


* Alexei Starovoitov <ast@plumgrid.com> wrote:

> On Mon, Jun 2, 2014 at 7:16 AM, Arnaldo Carvalho de Melo
> <acme@kernel.org> wrote:
> > Em Mon, Jun 02, 2014 at 09:24:56AM -0400, Steven Rostedt escreveu:
> >> On Mon, 2 Jun 2014 08:15:45 -0500
> >> Jonathan Corbet <corbet@lwn.net> wrote:
> >
> >> > On Mon,  2 Jun 2014 00:01:44 -0700
> >> > Alexei Starovoitov <ast@plumgrid.com> wrote:
> >
> >> > > This patch set splits BPF out of core networking into generic component
> >
> >> > Quick, probably dumb question: if you're going to split it out, why not
> >> > split it out entirely, into kernel/ or (perhaps better) lib/?  The
> >> > whole point seems to be that BPF is outgrowing its networking home, so
> >> > it seems like it might be better to make it truly generic.
> >
> >> I believe this is what Ingo suggested as well. If it is become generic,
> >> it belongs in lib/
> >
> > Yes, that was his suggestion, which I agree with, FWIW.
> 
> I guess I posted v2 too quickly :) v2 splits filter.c into 
> kernel/bpf/. I think it's a better location than lib/bpf, since lib 
> feels too constrained by definition of 'library'. bpf is more than a 
> set of library calls.

Yeah, the upgrade to kernel/bpf/ is a better place for BPF IMO: BPF is 
really an 'active', stateful subsystem, with non-trivial per arch 
implementations, while lib/ is generally for standalone, generic, 
platform-decoupled library functions (with a few exceptions).

Thanks,

	Ingo
