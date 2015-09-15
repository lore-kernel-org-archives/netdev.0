From: Tycho Andersen <tycho.andersen-Z7WLFzj8eWMS+FvcfC7Uqw@public.gmane.org>
Subject: Re: v2 of seccomp filter c/r patches
Date: Tue, 15 Sep 2015 12:26:26 -0600
Message-ID: <20150915182626.GK31864@smitten>
References: <1441930862-14347-1-git-send-email-tycho.andersen@canonical.com>
 <CALCETrVYtv1=g-xPjQ-LiX+5GK3xtB6a2hYbat0TuU-Bd4QA6Q@mail.gmail.com>
 <CALCETrWxLMSgdsdT9gTL80LSovONmCcTYjzqrHqF-WdJ4BN1Uw@mail.gmail.com>
 <20150911172806.GA7244@smitten>
 <CALCETrWH0vLZwkOV6JCnC-pLaHe0dboXs5-ETkXFCR9X-aq7qw@mail.gmail.com>
 <20150915160738.GJ31864@smitten>
 <CALCETrVxhNvmEdMq0XRy1YZ+oJLDwcmE1y6prs7FGGhsS-Y5gg@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Kees Cook <keescook-F7+t8E8rja9g9hUCZPvPmw@public.gmane.org>,
	Pavel Emelyanov <xemul-bzQdu9zFT3WakBO8gow8eQ@public.gmane.org>,
	Network Development <netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
	Alexei Starovoitov <ast-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org>,
	"David S. Miller" <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>,
	Oleg Nesterov <oleg-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>,
	"Serge E. Hallyn" <serge.hallyn-GeWIH/nMZzLQT0dZR+AlfA@public.gmane.org>,
	Linux API <linux-api-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
	Will Drewry <wad-F7+t8E8rja9g9hUCZPvPmw@public.gmane.org>,
	"linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org" <linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
	Daniel Borkmann <daniel-FeC+5ew28dpmcu3hnIyYJQ@public.gmane.org>
To: Andy Lutomirski <luto-kltTT9wpgjJwATOyAt5JVQ@public.gmane.org>
Return-path: <linux-api-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
Content-Disposition: inline
In-Reply-To: <CALCETrVxhNvmEdMq0XRy1YZ+oJLDwcmE1y6prs7FGGhsS-Y5gg-JsoAwUIsXosN+BqQ9rBEUg@public.gmane.org>
Sender: linux-api-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

Hi Andy,

On Tue, Sep 15, 2015 at 11:13:51AM -0700, Andy Lutomirski wrote:
> On Tue, Sep 15, 2015 at 9:07 AM, Tycho Andersen
> <tycho.andersen-Z7WLFzj8eWMS+FvcfC7Uqw@public.gmane.org> wrote:
> > Hi Andy,
> >
> > On Mon, Sep 14, 2015 at 10:52:46AM -0700, Andy Lutomirski wrote:
> >>
> >> I'm not sure I entirely like this solution...
> >
> > Ok. Since we also aren't going to do all the eBPF stuff now, how about
> > something that looks like this:
> >
> > struct seccomp_layer {
> >   unsigned int size;
> >   unsigned int type; /* SECCOMP_BPF_CLASSIC or SECCOMP_EBPF or ... */
> >   bool inherited;
> >   union {
> >     unsigned int insn_cnt;
> >     struct bpf_insn *insns;
> >   };
> > };
> >
> > with a ptrace command:
> >
> > ptrace(PTRACE_SECCOMP_DUMP_LAYER, pid, i, &layer);
> >
> > If we save a pointer to the current seccomp filter on fork (if there
> > is one), then I think the inherited flag is just,
> >
> > inherited = is_ancestor(child->seccomp.filter, child->seccomp.inherited_filter)
> >
> 
> I'm lost.  What is the inherited flag for?

We need some way to expose the seccomp hierarchy, specifically which
filters are inherited, so that we can correctly restore the filter
tree for tasks that may use TSYNC in the future. You've mentioned that
you don't like kcmp, so this is an alternative to that.

Tycho
