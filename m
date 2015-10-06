From: Andy Lutomirski <luto-kltTT9wpgjJwATOyAt5JVQ@public.gmane.org>
Subject: Re: [PATCH net-next 1/2] bpf: enable non-root eBPF programs
Date: Tue, 6 Oct 2015 11:05:21 -0700
Message-ID: <CALCETrXwYoVMnsPJZxFtgGaD5YXzKMBYG=EJAQTbwGdKwmdb5g@mail.gmail.com>
References: <1444078101-29060-1-git-send-email-ast@plumgrid.com>
 <1444078101-29060-2-git-send-email-ast@plumgrid.com> <5612F639.2050305@iogearbox.net>
 <56131B1F.80002@plumgrid.com> <20151006071347.GB14093@gmail.com>
 <561380BB.4040506@iogearbox.net> <20151006082048.GA18287@gmail.com>
 <561388D1.30406@iogearbox.net> <561409EC.5050005@plumgrid.com> <1444154160.9555.5.camel@edumazet-glaptop2.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: Alexei Starovoitov <ast-uqk4Ao+rVK5Wk0Htik3J/w@public.gmane.org>,
	Daniel Borkmann <daniel-FeC+5ew28dpmcu3hnIyYJQ@public.gmane.org>,
	Ingo Molnar <mingo-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org>,
	"David S. Miller" <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>,
	Hannes Frederic Sowa <hannes-tFNcAqjVMyqKXQKiL6tip0B+6BGkLq7r@public.gmane.org>,
	Eric Dumazet <edumazet-hpIqsD4AKlfQT0dZR+AlfA@public.gmane.org>,
	Kees Cook <keescook-F7+t8E8rja9g9hUCZPvPmw@public.gmane.org>,
	Linux API <linux-api-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
	Network Development <netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
	"linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org" <linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
To: Eric Dumazet <eric.dumazet-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
Return-path: <linux-api-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <1444154160.9555.5.camel-XN9IlZ5yJG9HTL0Zs8A6p/gx64E7kk8eUsxypvmhUTTZJqsBc5GL+g@public.gmane.org>
Sender: linux-api-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

On Tue, Oct 6, 2015 at 10:56 AM, Eric Dumazet <eric.dumazet-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org> wrote:
> On Tue, 2015-10-06 at 10:50 -0700, Alexei Starovoitov wrote:
>
>> was also thinking that we can do it only in paths that actually
>> have multiple protocol layers, since today bpf is mainly used with
>> tcpdump(raw_socket) and new af_packet fanout both have cb cleared
>> on RX, because it just came out of alloc_skb and no layers were called,
>> and on TX we can clear 20 bytes in dev_queue_xmit_nit().
>> af_unix/netlink also have clean skb. Need to analyze tun and sctp...
>> but it feels overly fragile to save a branch in sk_filter,
>> so planning to go with
>> if(unlikely(prog->cb_access)) memset in sk_filter().
>>
>
> This will break TCP use of sk_filter().
> skb->cb[] contains useful data in TCP layer.
>
>

Since I don't know too much about the networking details:

1. Does "skb->cb" *ever* contain anything useful for an unprivileged user?

2. Does sbk->cb form a stable ABI?

Unless both answers are solid yesses, then maybe the right solution is
to just deny access entirely to unprivileged users.

--Andy

-- 
Andy Lutomirski
AMA Capital Management, LLC
