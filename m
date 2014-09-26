From: Alexei Starovoitov <ast-uqk4Ao+rVK5Wk0Htik3J/w@public.gmane.org>
Subject: Re: eBPF verifier thoughts (Re: [PATCH v15 net-next 00/11] eBPF
 syscall, verifier, testsuite)
Date: Fri, 26 Sep 2014 13:09:40 -0700
Message-ID: <CAMEtUuzAuX=PVDtfQiRKgO7h5wx3gsTJUajr8VKsF4FR-d=JDw@mail.gmail.com>
References: <CALCETrVrHHxGo1RkPu+9LVnPo9XY9yYnJzg2ot0zOgoBspzbOQ@mail.gmail.com>
	<CALCETrXFb=etdrabEjbKdxKg51ViPXptOC=6CkKwcGS7Jau8nA@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: David Miller <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>, Ingo Molnar <mingo-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org>,
	Linus Torvalds <torvalds-de/tnXTf+JLsfHDXvbKv3WD2FQJk+8+b@public.gmane.org>,
	Daniel Borkmann <dborkman-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>,
	Hannes Frederic Sowa <hannes-tFNcAqjVMyqKXQKiL6tip0B+6BGkLq7r@public.gmane.org>,
	Chema Gonzalez <chema-hpIqsD4AKlfQT0dZR+AlfA@public.gmane.org>,
	Eric Dumazet <edumazet-hpIqsD4AKlfQT0dZR+AlfA@public.gmane.org>,
	Peter Zijlstra <a.p.zijlstra-/NLkJaSkS4VmR6Xm/wNWPw@public.gmane.org>,
	Pablo Neira Ayuso <pablo-Cap9r6Oaw4JrovVCs/uTlw@public.gmane.org>,
	"H. Peter Anvin" <hpa-YMNOUZJC4hwAvxtiuMwx3w@public.gmane.org>,
	Andrew Morton <akpm-de/tnXTf+JLsfHDXvbKv3WD2FQJk+8+b@public.gmane.org>,
	Kees Cook <keescook-F7+t8E8rja9g9hUCZPvPmw@public.gmane.org>,
	Linux API <linux-api-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
	Network Development <netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
	"linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org" <linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
To: Andy Lutomirski <luto-kltTT9wpgjJwATOyAt5JVQ@public.gmane.org>
Return-path: <linux-api-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <CALCETrXFb=etdrabEjbKdxKg51ViPXptOC=6CkKwcGS7Jau8nA-JsoAwUIsXosN+BqQ9rBEUg@public.gmane.org>
Sender: linux-api-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

On Fri, Sep 26, 2014 at 12:51 PM, Andy Lutomirski <luto-kltTT9wpgjJwATOyAt5JVQ@public.gmane.org> wrote:
> On Fri, Sep 26, 2014 at 12:34 PM, Andy Lutomirski <luto-kltTT9wpgjJwATOyAt5JVQ@public.gmane.org> wrote:
>
> To add one more point:
>
> With the current verifier design, it's impossible to write a userspace
> tool that can take an eBPF program and check it.  The verification is
> far too context-dependent for that to be possible.  I won't go so far
> as to say that a userspace tool needs to *exist*, but I strongly
> object to exposing a verification algorithm that *precludes* writing
> such a tool.

that's just not true.
why is it not possible?

> I think that the eBPF program format needs to encode all context
> needed for verification.  Then verification should check that the
> program is compliant with the context and that the context is correct.
> The former could, in principle, be done in userspace, too.

one can have maps and other future objects equally
represented in user space. Nothing stops doing exactly the same
logic there.

> Here, "context" includes the program type (i.e. what type R1 hasis),
> the key and value sizes of all referenced maps, the fact that the maps
> are maps (damnit, "every object implements exactly the same interface
> and is called a 'map'" is a bad type system*), and possible also
> things like the intended stack size and any other relevant details
> about the entry calling convention.

Andy, I'm not sure where you're going with this.
Sounds like you want to redesign the whole thing?
How long it will take?
Did you consider all the cases I did?
I think I understand your concerns. What I don't understand
why you think we cannot address them step by step.
imo what this does covers a ton of use cases.
Some futuristic stuff may be better and may be not.
But here I have it working, tested and proven over many
use cases, whereas some future unclear stuff will take
unknown amount of time to redesign...
