From: Pablo Neira Ayuso <pablo@netfilter.org>
Subject: Re: [PATCH] nf_conntrack_proto_tcp: allow server to become a client
 in TW handling
Date: Wed, 22 Oct 2014 14:28:20 +0200
Message-ID: <20141022122820.GA27299@salvia>
References: <5419B546.40702@redhat.com>
 <a9618c5db692413c2970201b5206bcd357438399.1413216136.git.mleitner@redhat.com>
 <alpine.DEB.2.10.1410150854460.19251@blackhole.kfki.hu>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Marcelo Ricardo Leitner <mleitner@redhat.com>,
	netfilter-devel@vger.kernel.org, netdev@vger.kernel.org
To: Jozsef Kadlecsik <kadlec@blackhole.kfki.hu>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.us.es ([193.147.175.20]:40863 "EHLO mail.us.es"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S932865AbaJVM0z (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 22 Oct 2014 08:26:55 -0400
Content-Disposition: inline
In-Reply-To: <alpine.DEB.2.10.1410150854460.19251@blackhole.kfki.hu>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, Oct 15, 2014 at 09:27:43AM +0200, Jozsef Kadlecsik wrote:
> On Mon, 13 Oct 2014, Marcelo Ricardo Leitner wrote:
> 
> > When a port that was used to listen for inbound connections gets closed
> > and reused for outgoing connections (like rsh ends up doing for stderr
> > flow), current we may reject the SYN/ACK packet for the new connection
> > because tcp_conntracks states forbirds a port to become a client while
> > there is still a TIME_WAIT entry in there for it.
> > 
> > As TCP may expire the TIME_WAIT socket in 60s and conntrack's timeout
> > for it is 120s, there is a ~60s window that the application can end up
> > opening a port that conntrack will end up blocking.
> > 
> > This patch fixes this by simply allowing such state transition: if we
> > see a SYN, in TIME_WAIT state, on REPLY direction, move it to sSS. Note
> > that the rest of the code already handles this situation, more
> > specificly in tcp_packet(), first switch clause.
> 
> In those code branch if there was a valid FIN in either direction, we 
> destroy the old connection and a new will be created. That way the rules 
> about NEW connections will be applied, so the policies are not bypassed. 
> Otherwise we just ignore the SYN packet, so if it's invalid, we'll catch 
> the RST from the other side and destroy the conntrack entry. The event 
> flow looks OK to me.
> 
> > Signed-off-by: Marcelo Ricardo Leitner <mleitner@redhat.com>
> 
> Acked-by: Jozsef Kadlecsik <kadlec@blackhole.kfki.hu>

Applied, thanks.
