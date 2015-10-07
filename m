From: Ingo Molnar <mingo@kernel.org>
Subject: Re: [PATCH net-next 1/2] bpf: enable non-root eBPF programs
Date: Wed, 7 Oct 2015 08:05:29 +0200
Message-ID: <20151007060529.GA6364@gmail.com>
References: <1444078101-29060-2-git-send-email-ast@plumgrid.com>
 <5612F639.2050305@iogearbox.net>
 <56131B1F.80002@plumgrid.com>
 <20151006071347.GB14093@gmail.com>
 <561380BB.4040506@iogearbox.net>
 <20151006082048.GA18287@gmail.com>
 <561388D1.30406@iogearbox.net>
 <561409EC.5050005@plumgrid.com>
 <1444154160.9555.5.camel@edumazet-glaptop2.roam.corp.google.com>
 <CALCETrXwYoVMnsPJZxFtgGaD5YXzKMBYG=EJAQTbwGdKwmdb5g@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Eric Dumazet <eric.dumazet@gmail.com>,
	Alexei Starovoitov <ast@plumgrid.com>,
	Daniel Borkmann <daniel@iogearbox.net>,
	"David S. Miller" <davem@davemloft.net>,
	Hannes Frederic Sowa <hannes@stressinduktion.org>,
	Eric Dumazet <edumazet@google.com>,
	Kees Cook <keescook@chromium.org>,
	Linux API <linux-api@vger.kernel.org>,
	Network Development <netdev@vger.kernel.org>,
	"linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>
To: Andy Lutomirski <luto@amacapital.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wi0-f169.google.com ([209.85.212.169]:35874 "EHLO
	mail-wi0-f169.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751414AbbJGGFd (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 7 Oct 2015 02:05:33 -0400
Content-Disposition: inline
In-Reply-To: <CALCETrXwYoVMnsPJZxFtgGaD5YXzKMBYG=EJAQTbwGdKwmdb5g@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


* Andy Lutomirski <luto@amacapital.net> wrote:

> On Tue, Oct 6, 2015 at 10:56 AM, Eric Dumazet <eric.dumazet@gmail.com> wrote:
> > On Tue, 2015-10-06 at 10:50 -0700, Alexei Starovoitov wrote:
> >
> >> was also thinking that we can do it only in paths that actually
> >> have multiple protocol layers, since today bpf is mainly used with
> >> tcpdump(raw_socket) and new af_packet fanout both have cb cleared
> >> on RX, because it just came out of alloc_skb and no layers were called,
> >> and on TX we can clear 20 bytes in dev_queue_xmit_nit().
> >> af_unix/netlink also have clean skb. Need to analyze tun and sctp...
> >> but it feels overly fragile to save a branch in sk_filter,
> >> so planning to go with
> >> if(unlikely(prog->cb_access)) memset in sk_filter().
> >>
> >
> > This will break TCP use of sk_filter().
> > skb->cb[] contains useful data in TCP layer.
> >
> >
> 
> Since I don't know too much about the networking details:
> 
> 1. Does "skb->cb" *ever* contain anything useful for an unprivileged user?
> 
> 2. Does sbk->cb form a stable ABI?
> 
> Unless both answers are solid yesses, then maybe the right solution is
> to just deny access entirely to unprivileged users.

So this kind of instrumentation data is not an ABI in a similar fashion as tracing 
information is not an ABI either.

I.e. tracepoints can (and sometimes do) change 'semantics' - in that the 
interpretation of the implementational details behind that data changes as the 
implementation changes. That's not something that can ever be an ABI, just like 
the contents of /proc/kcore or /proc/slabinfo can not be an ABI.

Thanks,

	Ingo
