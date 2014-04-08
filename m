From: Florian Westphal <fw@strlen.de>
Subject: Re: Problems with fragments since gso skb forwarding changes in
 virtual environment
Date: Tue, 8 Apr 2014 16:33:18 +0200
Message-ID: <20140408143318.GD31953@breakpoint.cc>
References: <5342CC9A.6040800@strongswan.org>
 <20140407234640.GB31953@breakpoint.cc>
 <5343EA79.8030104@strongswan.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Florian Westphal <fw@strlen.de>, netdev@vger.kernel.org,
	"David S. Miller" <davem@davemloft.net>,
	Herbert Xu <herbert@gondor.apana.org.au>,
	Marcelo Ricardo Leitner <mleitner@redhat.com>
To: Tobias Brunner <tobias@strongswan.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from Chamillionaire.breakpoint.cc ([80.244.247.6]:49298 "EHLO
	Chamillionaire.breakpoint.cc" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1757164AbaDHOdW (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 8 Apr 2014 10:33:22 -0400
Content-Disposition: inline
In-Reply-To: <5343EA79.8030104@strongswan.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Tobias Brunner <tobias@strongswan.org> wrote:
> > 
> > Host A - br1 - Router R - br2 - Host B
> >   Mtu >1500               Mtu 1500
> > 
> > 1. host A sends GSO packet, DF not set
> > 2. packet arrives at R, still GSO packet
> > 3. forward on R fragments packet since it won't fit
> >    outgoing interface (which is normal virtio ethernet) mtu
> > 4. fragmented packets leave R
> > 5. fragmented packets arrive on host system (not pictured above) br2
> > interface
> > 
> > 6. packets are being bridged on host system, call_iptables sysctl on
> > 7. packets are defragmented by netfilter on host due to call_iptables
> > sysctl on
> > 8. packets are tossed on host in br_dev_queue_push_xmit because
> >    is_skb_forwardable() returns false
> > 
> > Is that correct?
> 
> Exactly.  The MTU is 1500 on all interfaces though.

Thanks for clarifying. In this case there is another problem as well as
no fragments should be generated in the forwarding path if the outgoing mtu
is not reduced.

Most likely a problem with udp gso + skb_gso_network_seglen().

I'll report back, thanks for your feedback.
