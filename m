From: Rusty Russell <rusty@rustcorp.com.au>
Subject: Re: [patch 7/9] lguest: the net driver
Date: Wed, 09 May 2007 21:55:25 +1000
Message-ID: <1178711725.7286.82.camel@localhost.localdomain>
References: <E1HljA6-0001E4-00@gondolin.me.apana.org.au>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: akpm@linux-foundation.org, linux-kernel@vger.kernel.org,
	virtualization@lists.osdl.org, ak@suse.de, jeff@garzik.org,
	jmorris@namei.org, netdev@vger.kernel.org
To: Herbert Xu <herbert@gondor.apana.org.au>
Return-path: <netdev-owner@vger.kernel.org>
Received: from ozlabs.org ([203.10.76.45]:40481 "EHLO ozlabs.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752072AbXEILzp (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 9 May 2007 07:55:45 -0400
In-Reply-To: <E1HljA6-0001E4-00@gondolin.me.apana.org.au>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Wed, 2007-05-09 at 20:12 +1000, Herbert Xu wrote:
> akpm@linux-foundation.org wrote:
> >
> > +       if (desc->features & LGUEST_NET_F_NOCSUM)
> > +               dev->features |= NETIF_F_NO_CSUM;
> 
> Any reason why you're using NO_CSUM here instead of HW_CSUM?
> Practically there is no difference but NO_CSUM could be treated
> differently in future and I'm not sure whether such changes would
> be desirable in this driver (i.e., not even generating a partial
> checksum).

Hi Herbert,

	NO_CSUM because it really doesn't need a checksum.  The
LGUEST_NET_F_NOCSUM is only set for local inter-guest networking.  If
some guest were to route the packets outside the machine, this would be
an issue, though ("don't do that").

> Also, there doesn't seem to be any passing of metadata to the
> backend which means that neither NO_CSUM/HW_CSUM can work if
> somebody needs to look at the checksum field.  You could use
> IP_CSUM if you do the same hack on the backend that Xen does.
> Otherwise you'll have to make do with no checksum offload at all.

Yeah, definitely good future work.  This is far simpler: external-facing
networks don't get marked with the LGUEST_NET_F_NOCSUM but set.

KVM is going to have a paravirt network driver too: it'd be nice to
share code here.

> I think you'd also need a change_mtu function if the SG feature
> is going to be of some use since the default Ethernet one limits
> the MTU to 1500.

Indeed, that would be a new feature, and is certainly a consideration
for more efficient inter-guest networking.  However, I consider that
somewhat cheating: it's nice to know that 1500 doesn't suck too hard.

Remember, "Features kill puppies!" 8)

Thanks,
Rusty.

