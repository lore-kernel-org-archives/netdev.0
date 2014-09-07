From: Pablo Neira Ayuso <pablo-Cap9r6Oaw4JrovVCs/uTlw@public.gmane.org>
Subject: Re: [PATCH v10 net-next 2/2] net: filter: split filter.h and expose
 eBPF to user space
Date: Sun, 7 Sep 2014 20:07:37 +0200
Message-ID: <20140907180737.GA5057@salvia>
References: <1409894238-9055-1-git-send-email-ast@plumgrid.com>
 <1409894238-9055-3-git-send-email-ast@plumgrid.com>
 <20140906141051.GA4245@salvia>
 <CAMEtUuxPynQ4wdWDgCU+9_3_GRYn8oA4f-emcF+mqiQdLsqEWg@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: "David S. Miller" <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>,
	Ingo Molnar <mingo-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org>,
	Linus Torvalds <torvalds-hQyY1W1yCW8ekmWlsbkhG0B+6BGkLq7r@public.gmane.org>,
	Andy Lutomirski <luto-kltTT9wpgjJwATOyAt5JVQ@public.gmane.org>,
	Steven Rostedt <rostedt-nx8X9YLhiw1AfugRpC6u6w@public.gmane.org>,
	Daniel Borkmann <dborkman-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>,
	Hannes Frederic Sowa <hannes-tFNcAqjVMyqKXQKiL6tip0B+6BGkLq7r@public.gmane.org>,
	Chema Gonzalez <chema-hpIqsD4AKlfQT0dZR+AlfA@public.gmane.org>,
	Eric Dumazet <edumazet-hpIqsD4AKlfQT0dZR+AlfA@public.gmane.org>,
	Peter Zijlstra <a.p.zijlstra-/NLkJaSkS4VmR6Xm/wNWPw@public.gmane.org>,
	"H. Peter Anvin" <hpa-YMNOUZJC4hwAvxtiuMwx3w@public.gmane.org>,
	Andrew Morton <akpm-hQyY1W1yCW8ekmWlsbkhG0B+6BGkLq7r@public.gmane.org>,
	Kees Cook <keescook-F7+t8E8rja9g9hUCZPvPmw@public.gmane.org>,
	Linux API <linux-api-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
	Network Development <netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
	LKML <linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
To: Alexei Starovoitov <ast-uqk4Ao+rVK5Wk0Htik3J/w@public.gmane.org>
Return-path: <linux-api-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
Content-Disposition: inline
In-Reply-To: <CAMEtUuxPynQ4wdWDgCU+9_3_GRYn8oA4f-emcF+mqiQdLsqEWg-JsoAwUIsXosN+BqQ9rBEUg@public.gmane.org>
Sender: linux-api-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

On Sat, Sep 06, 2014 at 09:04:23AM -0700, Alexei Starovoitov wrote:
> On Sat, Sep 6, 2014 at 7:10 AM, Pablo Neira Ayuso <pablo-Cap9r6Oaw4JrovVCs/uTlw@public.gmane.org> wrote:
> > On Thu, Sep 04, 2014 at 10:17:18PM -0700, Alexei Starovoitov wrote:
> >> allow user space to generate eBPF programs
> >>
> >> uapi/linux/bpf.h: eBPF instruction set definition
> >>
> >> linux/filter.h: the rest
> >>
> >> This patch only moves macro definitions, but practically it freezes existing
> >> eBPF instruction set, though new instructions can still be added in the future.
> >>
> >> These eBPF definitions cannot go into uapi/linux/filter.h, since the names
> >> may conflict with existing applications.
> >>
> >> Full eBPF ISA description is in Documentation/networking/filter.txt
> >
> > I think you need to have at least one single interface using this
> > before you can expose it to userspace. So this should come in the
> > small batch that introduces the first interface of your ebpf code in
> > userspace. AFAIK, this has been the policy so far.
> 
> That's what I've been doing over the last year.
> My first eBPF patch was in Sep of 2013!
> since then I've been only tweaking and massaging it.
> Nothing fundamentally changed.
> Last few month I've been posting these series with not only
> first user, but with multiple. Many examples, test cases and so on.
> The series became big and Dave asked to split them.
> Please see the cover letter. These two patches is stage I.
> More examples and use cases in stage II, stage III, stage IV, etc

If the patches that provide the very first user interface don't get in
time to this merge window round for whatever reason, we'll have the
layout of this exposed to userspace in the next kernel version with no
clients at all, that doesn't make sense to me.

I don't think the speed up of the llvm submission is a good argument,
this sounds to me similar to the "please apply this patch that
reserves this new netlink family in include/linux/netlink.h, I promise
this new subsystem will be submitted soon though. Meanwhile this will
speed up submission of my userspace software to distributions for
packaging" argument.

I think you have to find the way to send a small batch with the very
essencial stuff that, if merged mainstream, will provide just one new
feature while leaving the repository in consistent state. Then, send
follow up patches that enhance your thing and that add new clients of
it.
