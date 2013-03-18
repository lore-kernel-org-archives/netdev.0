From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH nf-next] netfilter: nfnetlink_queue: zero copy support
Date: Mon, 18 Mar 2013 06:51:19 -0700
Message-ID: <1363614679.29475.130.camel@edumazet-glaptop>
References: <1363576555.29475.122.camel@edumazet-glaptop>
	 <20130318092444.GG7938@breakpoint.cc>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: Pablo Neira Ayuso <pablo@netfilter.org>,
	netdev <netdev@vger.kernel.org>,
	Netfilter Developer Mailing List
	<netfilter-devel@vger.kernel.org>
To: Florian Westphal <fw@strlen.de>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pb0-f45.google.com ([209.85.160.45]:59159 "EHLO
	mail-pb0-f45.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750985Ab3CRNvW (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 18 Mar 2013 09:51:22 -0400
In-Reply-To: <20130318092444.GG7938@breakpoint.cc>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, 2013-03-18 at 10:24 +0100, Florian Westphal wrote:
> Eric Dumazet <eric.dumazet@gmail.com> wrote:
> >
> > -GRO/GSO packets are segmented in nf_queue()
> > and checksummed in nfqnl_build_packet_message().
> > Proper support for GSO/GRO packets (no segmentation,
> > and no checksumming) needs application cooperation, if we
> > want no regressions.
> 
> Since ipqueue is gone we might be able to push the segmentation
> down to nfnetlink_queue.  Then new userspace applications
> could indicate a 'I won't verify checksums and will handle huge
> packets'.
> 
> Are you working on something like this?

I validated that it was only an API concern, by commenting out the code,
and got 20Gbps (link speed) using the sample program (using a bigger
buffer to receive the skbs and removing the printf() for each packet)

Pablo followed the experiments and I believe he has an idea of the
needed API. Anyway, after one week in NFWS, I wont have the time to do
it, I have a huge backlog...

Note that its not a zero copy :

Before the patch we had 2 copies. (kernel->kernel done in softirq
context, and kernel->user in process context)

After the patch we have the copy from kernel to user land, done
in process context.
