From: Flavio Leitner <fbl@redhat.com>
Subject: Re: [PATCH] route: add more relaxed option for secure_redirects
Date: Wed, 16 Nov 2011 21:17:38 -0200
Message-ID: <20111116211738.067354c0@asterix.rh>
References: <1320710630-28335-1-git-send-email-fbl@redhat.com>
	<20111111.203321.93615255271311412.davem@davemloft.net>
	<20111116184612.25615c02@asterix.rh>
	<20111116.170213.1763930566851730338.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:5374 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753184Ab1KPXRl (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 16 Nov 2011 18:17:41 -0500
In-Reply-To: <20111116.170213.1763930566851730338.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, 16 Nov 2011 17:02:13 -0500 (EST)
David Miller <davem@davemloft.net> wrote:

> From: Flavio Leitner <fbl@redhat.com>
> Date: Wed, 16 Nov 2011 18:46:12 -0200
> 
> > Thus, the only option at the sender side would be using iptables
> > to change the ICMP redirect source address to be the float address,
> > but that is not working as well. (It isn't passing through -t nat)
> 
> If it's going to mangle the packet in one direct, the only option
> for sane operation is to make the exact reverse transformation in
> the other direction for ICMP messages.
> 
> I'm sorry to be so difficult about this, but this is the only way to
> handle this problem.  If packet mangling is performed to change the
> world, that mangling entity has taken on the responsibility to make
> everything look correct to all entities for the mangled packets
> and any packets generated in response to such mangled packets.
>

I'm sorry, I lost you there. There is no transformation happening in
any side. The iptables is just a work around to force the outgoing
ICMP redirect to use the correct source address (secondary or alias). 

The whole problem is the linux gateway sending ICMP redirects using
*always* the primary address.

fbl
