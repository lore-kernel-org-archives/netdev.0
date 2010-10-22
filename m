From: Simon Horman <horms@verge.net.au>
Subject: Re: [PATCH] af_packet: account for VLAN when checking packet size
Date: Fri, 22 Oct 2010 10:41:26 +0200
Message-ID: <20101022084052.GA2118@verge.net.au>
References: <20101011.090153.226774563.davem@davemloft.net>
 <20101011172932.GB12342@orbit.nwl.cc>
 <20101012171940.GB30613@redhat.com>
 <20101012.104032.71103852.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: mst@redhat.com, eric.dumazet@gmail.com, netdev@vger.kernel.org,
	johann.baudy@gnu-log.net
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from kirsty.vergenet.net ([202.4.237.240]:43379 "EHLO
	kirsty.vergenet.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754956Ab0JWB1f (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 22 Oct 2010 21:27:35 -0400
Content-Disposition: inline
In-Reply-To: <20101012.104032.71103852.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, Oct 12, 2010 at 10:40:32AM -0700, David Miller wrote:
> From: "Michael S. Tsirkin" <mst@redhat.com>
> Date: Tue, 12 Oct 2010 19:19:41 +0200
> 
> > Yes, like eth_type_trans does I guess.  I think we had a similar
> > discussion already:
> > 
> > http://lists.openwall.net/netdev/2010/01/06/38
> > 
> > Summary: if we want to make the protocol field have the correct
> > value for this case we need to make it work for other
> > transports not just for ethernet.
> 
> Right, so for now we should just allow 4-byte larger
> than MTU TX packets, as long as the device is ethernet
> and can handle VLANs properly.

Incidently, I believe that this problem will only become more acute
and complex if support for 802.1ad (Provider Bridges, aka Q-in-Q),
802.1ah (Provider Backbone Bridges, aka MAC-in-MAC) or other standards
which further extend the maximum frame size.

Dave, you were mentioning to me the other day that the kernel
already supports some notion of Q-in-Q (though its not 802.1ad).
Does the current implementation allow for frames > 1504 bytes?
Is that a complication to the change proposed here?

