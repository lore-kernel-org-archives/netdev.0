From: Pablo Neira Ayuso <pablo@netfilter.org>
Subject: Re: [PATCH nf] conntrack: RFC5961 challenge ACK confuse conntrack
 LAST-ACK transition
Date: Fri, 15 May 2015 21:06:33 +0200
Message-ID: <20150515190633.GA11015@salvia>
References: <20150507125416.29956.24745.stgit@dragon>
 <alpine.DEB.2.10.1505111155120.30455@blackhole.kfki.hu>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Jesper Dangaard Brouer <brouer@redhat.com>, netdev@vger.kernel.org,
	netfilter-devel@vger.kernel.org
To: Jozsef Kadlecsik <kadlec@blackhole.kfki.hu>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.us.es ([193.147.175.20]:34325 "EHLO mail.us.es"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753705AbbEOTBs (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 15 May 2015 15:01:48 -0400
Content-Disposition: inline
In-Reply-To: <alpine.DEB.2.10.1505111155120.30455@blackhole.kfki.hu>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, May 11, 2015 at 12:02:17PM +0200, Jozsef Kadlecsik wrote:
> Hi,
> 
> On Thu, 7 May 2015, Jesper Dangaard Brouer wrote:
> 
> > In compliance with RFC5961, the network stack send challenge ACK in
> > response to spurious SYN packets, since commit 0c228e833c88 ("tcp:
> > Restore RFC5961-compliant behavior for SYN packets").
> > 
> > This pose a problem for netfilter conntrack in state LAST_ACK, because
> > this challenge ACK is (falsely) seen as ACKing last FIN, causing a
> > false state transition (into TIME_WAIT).
> > 
> > The challenge ACK is hard to distinguish from real last ACK.  Thus,
> > solution introduce a flag that tracks the potential for seeing a
> > challenge ACK, in case a SYN packet is let through and current state
> > is LAST_ACK.
> > 
> > When conntrack transition LAST_ACK to TIME_WAIT happens, this flag is
> > used for determining if we are expecting a challenge ACK.
> > 
> > Scapy based reproducer script avail here:
> >  https://github.com/netoptimizer/network-testing/blob/master/scapy/tcp_hacks_3WHS_LAST_ACK.py
> > 
> > Fixes: 0c228e833c88 ("tcp: Restore RFC5961-compliant behavior for SYN packets")
> > Signed-off-by: Jesper Dangaard Brouer <brouer@redhat.com>
> 
> The patch looks OK to me, thanks Jesper.
> 
> Acked-by: Jozsef Kadlecsik <kadlec@blackhole.kfki.hu>

Applied, thanks.
