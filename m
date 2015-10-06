From: Ingo Molnar <mingo-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org>
Subject: Re: [PATCH net-next 1/2] bpf: enable non-root eBPF programs
Date: Tue, 6 Oct 2015 09:13:47 +0200
Message-ID: <20151006071347.GB14093@gmail.com>
References: <1444078101-29060-1-git-send-email-ast@plumgrid.com>
 <1444078101-29060-2-git-send-email-ast@plumgrid.com>
 <5612F639.2050305@iogearbox.net>
 <56131B1F.80002@plumgrid.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Daniel Borkmann <daniel-FeC+5ew28dpmcu3hnIyYJQ@public.gmane.org>,
	"David S. Miller" <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>,
	Andy Lutomirski <luto-kltTT9wpgjJwATOyAt5JVQ@public.gmane.org>,
	Hannes Frederic Sowa <hannes-tFNcAqjVMyqKXQKiL6tip0B+6BGkLq7r@public.gmane.org>,
	Eric Dumazet <edumazet-hpIqsD4AKlfQT0dZR+AlfA@public.gmane.org>,
	Kees Cook <keescook-F7+t8E8rja9g9hUCZPvPmw@public.gmane.org>, linux-api-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
To: Alexei Starovoitov <ast-uqk4Ao+rVK5Wk0Htik3J/w@public.gmane.org>
Return-path: <linux-api-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
Content-Disposition: inline
In-Reply-To: <56131B1F.80002-uqk4Ao+rVK5Wk0Htik3J/w@public.gmane.org>
Sender: linux-api-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org


* Alexei Starovoitov <ast-uqk4Ao+rVK5Wk0Htik3J/w@public.gmane.org> wrote:

> On 10/5/15 3:14 PM, Daniel Borkmann wrote:
> >One scenario that comes to mind ... what happens when there are kernel
> >pointers stored in skb->cb[] (either from the current layer or an old
> >one from a different layer that the skb went through previously, but
> >which did not get overwritten)?
> >
> >Socket filters could read a portion of skb->cb[] also when unprived and
> >leak that out through maps. I think the verifier doesn't catch that,
> >right?
> 
> grrr. indeed. previous layer before sk_filter() can leave junk in there.

Could this be solved by activating zeroing/sanitizing of this data if there's an 
active BPF function around that can access that socket?

Thanks,

	Ingo
