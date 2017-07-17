From: Shaohua Li <shli@kernel.org>
Subject: Re: [RFC net 1/2] net: set skb hash for IP6 TCP reset packet
Date: Mon, 17 Jul 2017 14:53:22 -0700
Message-ID: <20170717215322.vdbz2l76qmdtp4xu@kernel.org>
References: <cover.1499967945.git.shli@fb.com>
 <5595e60068d7c18c7f0749d8a355a008123ca0d8.1499967945.git.shli@fb.com>
 <1500281511.5566.15.camel@edumazet-glaptop3.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, davem@davemloft.net, Kernel-team@fb.com,
        Florent Fourcot <flo@fourcot.fr>
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.kernel.org ([198.145.29.99]:58662 "EHLO mail.kernel.org"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1751318AbdGQVxZ (ORCPT <rfc822;netdev@vger.kernel.org>);
        Mon, 17 Jul 2017 17:53:25 -0400
Content-Disposition: inline
In-Reply-To: <1500281511.5566.15.camel@edumazet-glaptop3.roam.corp.google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, Jul 17, 2017 at 01:51:51AM -0700, Eric Dumazet wrote:
> On Thu, 2017-07-13 at 10:56 -0700, Shaohua Li wrote:
> > From: Shaohua Li <shli@fb.com>
> > 
> > Please see below tcpdump output:
> 
> > The tcp reset packet has a different flowlabel, which causes our router
> > doesn't correctly close tcp connection.
> 
> This looks a bug in your router, because (IPv6 only) flowlabel is not
> part of the tuple identifying a TCP flow.

Actually it's for load balance between several routers.
> 
> >   The reason is the normal packet
> > gets the skb->hash from sk->sk_txhash, which is generated randomly.
> > ip6_make_flowlabel then uses the hash to create a flowlabel. The reset
> > packet doesn't get assigned a hash, so the flowlabel is calculated with
> > flowi6.
> > 
> > The solution is to save the hash value for timeout sock and use it for
> > reset packet.
> 
> I am a bit unsure why we need to add yet another field in TCP timewait
> structure, since :
> 
> 1) flowlabel can vary during a TCP flow lifetime.
> 2) flowlabel is different unde synflood (each syncookie gets a random
> flowlabel), and if 3rd packet comes back from the client to finish 3WHS,
> the flowlabel will again be different from the one that SYNACK used.

Is it acceptable we reuse tw_flowlabel as Florent Fourcot suggested? It makes
no sense to change flowlabel for no reason.

Thanks,
Shaohua
