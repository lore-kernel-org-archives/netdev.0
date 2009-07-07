From: David Miller <davem@davemloft.net>
Subject: Re: [RFC] Fixing up TCP/UDP checksum for UDP encap. ESP4 packets
 in transport mode
Date: Mon, 06 Jul 2009 18:30:29 -0700 (PDT)
Message-ID: <20090706.183029.82831402.davem@davemloft.net>
References: <20090622090731.GA22496@gondor.apana.org.au>
	<20090630070036.GA16225@gondor.apana.org.au>
	<20090630140835.GA20811@gondor.apana.org.au>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: christophe@saout.de, netdev@vger.kernel.org
To: herbert@gondor.apana.org.au
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:49086
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1752904AbZGGBaW (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 6 Jul 2009 21:30:22 -0400
In-Reply-To: <20090630140835.GA20811@gondor.apana.org.au>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Herbert Xu <herbert@gondor.apana.org.au>
Date: Tue, 30 Jun 2009 22:08:35 +0800

> On Tue, Jun 30, 2009 at 03:00:36PM +0800, Herbert Xu wrote:
>> 
>> Now as to the technical problem of how to recompute the checksums
>> cleanly, may I draw your attention to gso_send_checksum which does
>> exactly what you want.
> 
> Something like this untested patch.  Note that I still think this
> is totally wrong (see the patch description for an explanation).
> Perhaps a better way to do this is to write a netfilter module to
> fix up checksums on egress.  That way it would be even more explicit
> that you should do the checksum verification on the opposite end
> as well.
> 
> The real solution is to get natoa, or even better, ditch transport
> mode if you're doing NAT.

Ugly solution or not I don't like this patch because it requires
userspace to set this new attribute just to get correct checksums.

Can't we just detect the "came through remote peer" situation and
just do the checksum fixup in that case?  Anything that doesn't
require use changes, and as you've implemented it the user change
is only possible with netlink IPSEC users.
