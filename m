From: Alexei Starovoitov <ast-uqk4Ao+rVK5Wk0Htik3J/w@public.gmane.org>
Subject: Re: [PATCH net-next 1/2] bpf: enable non-root eBPF programs
Date: Mon, 5 Oct 2015 17:51:43 -0700
Message-ID: <56131B1F.80002@plumgrid.com>
References: <1444078101-29060-1-git-send-email-ast@plumgrid.com>
 <1444078101-29060-2-git-send-email-ast@plumgrid.com>
 <5612F639.2050305@iogearbox.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Andy Lutomirski <luto-kltTT9wpgjJwATOyAt5JVQ@public.gmane.org>,
	Ingo Molnar <mingo-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org>,
	Hannes Frederic Sowa <hannes-tFNcAqjVMyqKXQKiL6tip0B+6BGkLq7r@public.gmane.org>,
	Eric Dumazet <edumazet-hpIqsD4AKlfQT0dZR+AlfA@public.gmane.org>,
	Kees Cook <keescook-F7+t8E8rja9g9hUCZPvPmw@public.gmane.org>, linux-api-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
To: Daniel Borkmann <daniel-FeC+5ew28dpmcu3hnIyYJQ@public.gmane.org>,
	"David S. Miller" <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>
Return-path: <linux-api-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <5612F639.2050305-FeC+5ew28dpmcu3hnIyYJQ@public.gmane.org>
Sender: linux-api-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

On 10/5/15 3:14 PM, Daniel Borkmann wrote:
> One scenario that comes to mind ... what happens when there are kernel
> pointers stored in skb->cb[] (either from the current layer or an old
> one from a different layer that the skb went through previously, but
> which did not get overwritten)?
>
> Socket filters could read a portion of skb->cb[] also when unprived and
> leak that out through maps. I think the verifier doesn't catch that,
> right?

grrr. indeed. previous layer before sk_filter() can leave junk in there.
Would need to disable cb[0-5] for unpriv, but that will make tail_call
much harder to use, since cb[0-5] is a way to pass arguments from
one prog to another and clearing them is not an option, since it's
too expensive. Like samples/bpf/sockex3_kern.c usage of cb[0]
won't work anymore. I guess that's the price of unpriv.
Will fix this, add few tail_call specific tests and respin.
Please keep poking.
