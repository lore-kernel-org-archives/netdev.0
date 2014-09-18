From: Daniel Borkmann <dborkman-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>
Subject: Re: [PATCH v13 net-next 07/11] bpf: verifier (add ability to receive
 verification log)
Date: Thu, 18 Sep 2014 19:28:04 +0200
Message-ID: <541B1624.80302@redhat.com>
References: <1410914370-29883-1-git-send-email-ast@plumgrid.com> <1410914370-29883-8-git-send-email-ast@plumgrid.com> <54192F66.8020200@redhat.com> <CAMEtUuxK68ZoJ-izjLoygv0f+rLtPmMLUUq1=BJ+_ZBGfynkdA@mail.gmail.com> <5419BED8.5020309@redhat.com> <5419DE51.1060904@redhat.com> <CAMEtUuzhcmZiYZL8TR008or8uaefDBrEKDjqA-tOrRLEZsm95A@mail.gmail.com> <CAMEtUuw0aDPpQhd13ssk2PDLffBJNeef9jicOnhQLH6KtJ8gsQ@mail.gmail.com> <541A7F35.2010804@redhat.com> <CAMEtUuyZCHh7SGeLF+g0ye3OrEFWnTZCn3SBeK0-8qz-y8U30w@mail.gmail.com> <541AF11C.9050405@redhat.com> <CAMEtUuykgG70sP0tAmovLvPxgjwaR8h=R-c6Tyo6m96+Lg3sXQ@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8; format=flowed
Content-Transfer-Encoding: 7bit
Cc: "David S. Miller" <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>,
	Ingo Molnar <mingo-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org>,
	Linus Torvalds <torvalds-de/tnXTf+JLsfHDXvbKv3WD2FQJk+8+b@public.gmane.org>,
	Andy Lutomirski <luto-kltTT9wpgjJwATOyAt5JVQ@public.gmane.org>,
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
	LKML <linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
To: Alexei Starovoitov <ast-uqk4Ao+rVK5Wk0Htik3J/w@public.gmane.org>
Return-path: <linux-api-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <CAMEtUuykgG70sP0tAmovLvPxgjwaR8h=R-c6Tyo6m96+Lg3sXQ-JsoAwUIsXosN+BqQ9rBEUg@public.gmane.org>
Sender: linux-api-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

On 09/18/2014 05:24 PM, Alexei Starovoitov wrote:
...
> solve or not. If we decide to solve it, we need to have
> a plan to solve it all the way. Partial fix for size of bpf_attr
> is not a plan. It's something that is not addressing the problem
> completely. Little bit of help is not useful for userspace. It
> would need to deal with new types, verifier differences and
> other things that I mentioned earlier.

Hm, I don't think it would be a strict requirement to solve it
all the way, and I think that perf_event_open() with perf_copy_attr()
is not trying to do so either. It, however, is trying on a ``best
effort basis'' to still load something if new features are unused
by the binary (I guess you saw the comment in perf_copy_attr()).

Iff, e.g. due to new types we fail at the verifier stage, sure,
that's life since we only have backwards-compatible guarantee,
but in case we tried to use features we support, we're still able
to load the eBPF program while right now, we're rejecting it right
up-front. That's just my $0.02 ...
