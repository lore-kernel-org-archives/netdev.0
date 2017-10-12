From: Florian Westphal <fw@strlen.de>
Subject: Re: [PATCH net-next 1/1] net/smc: add SMC rendezvous protocol
Date: Thu, 12 Oct 2017 13:14:29 +0200
Message-ID: <20171012111429.GG26835@breakpoint.cc>
References: <20171010141419.88190-1-ubraun@linux.vnet.ibm.com>
 <20171011.140652.272274136617199385.davem@davemloft.net>
 <b37b38df-cbb8-ca86-d460-9d3ec7acc2c6@linux.vnet.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: David Miller <davem@davemloft.net>, netdev@vger.kernel.org,
        linux-s390@vger.kernel.org, jwi@linux.vnet.ibm.com,
        schwidefsky@de.ibm.com, heiko.carstens@de.ibm.com,
        raspl@linux.vnet.ibm.com, hwippel@linux.vnet.ibm.com
To: Ursula Braun <ubraun@linux.vnet.ibm.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from Chamillionaire.breakpoint.cc ([146.0.238.67]:45500 "EHLO
        Chamillionaire.breakpoint.cc" rhost-flags-OK-OK-OK-OK)
        by vger.kernel.org with ESMTP id S1752704AbdJLLOk (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 12 Oct 2017 07:14:40 -0400
Content-Disposition: inline
In-Reply-To: <b37b38df-cbb8-ca86-d460-9d3ec7acc2c6@linux.vnet.ibm.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Ursula Braun <ubraun@linux.vnet.ibm.com> wrote:
> On 10/11/2017 11:06 PM, David Miller wrote:
> > From: Ursula Braun <ubraun@linux.vnet.ibm.com>
> > Date: Tue, 10 Oct 2017 16:14:19 +0200
> > 
> >> The goal of this patch is to leave common TCP code unmodified. Thus,
> >> it uses netfilter hooks to intercept TCP SYN and SYN/ACK
> >> packets. For outgoing packets originating from SMC sockets, the
> >> experimental option is added. For inbound packets destined for SMC
> >> sockets, the experimental option is checked.
> > 
> > I think this really isn't going to pass.
> > 
> > It's a user experience nightmare when the kernel inserts and
> > deletes filtering rules outside of what the user configures
> > on their system.

It depends if the hook is passive or not (i.e. mangles
payload/metadata or returns verdict other than NF_ACCEPT).

OUTPUT hook added here is not passive as it mangles tcp options.

> > This approach was also considerd for ipv6 ILA, and the same
> > pushback was given.

ahem.
net/ipv6/ila/ila_xlat.c:   err = nf_register_net_hooks(net, ila_nf_hook_ops,

FWIW at least the input hook seems ok to me provided it would use
skb_header_pointer for tcp header access (there is no guarantee
tcp_hdr() works or that the tcp header has been sanity checked in any
way).

Perhaps its time to consider moving net/netfilter/core.c into net/core
and rename NF_HOOK to NET_HOOK?
