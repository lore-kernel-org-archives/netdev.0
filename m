From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH linux-2.6 v2] IPv6: Temp addresses are immediately
 deleted.
Date: Tue, 28 Sep 2010 23:30:28 -0700 (PDT)
Message-ID: <20100928.233028.112599117.davem@davemloft.net>
References: <20100927171010.GB7106@adams.ccsl.carleton.ca>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: kuznet@ms2.inr.ac.ru, pekkas@netcore.fi, jmorris@namei.org,
	yoshfuji@linux-ipv6.org, kaber@trash.net, shemminger@vyatta.com,
	eric.dumazet@gmail.com, herbert@gondor.apana.org.au,
	ebiederm@xmission.com, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: gwurster@scs.carleton.ca
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:59034
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1752980Ab0I2GaI (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 29 Sep 2010 02:30:08 -0400
In-Reply-To: <20100927171010.GB7106@adams.ccsl.carleton.ca>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Glenn Wurster <gwurster@scs.carleton.ca>
Date: Mon, 27 Sep 2010 13:10:10 -0400

> There is a bug in the interaction between ipv6_create_tempaddr and 
> addrconf_verify.  Because ipv6_create_tempaddr uses the cstamp and tstamp 
> from the public address in creating a private address, if we have not 
> received a router advertisement in a while, tstamp + temp_valid_lft might be 
> < now.  If this happens, the new address is created inside 
> ipv6_create_tempaddr, then the loop within addrconf_verify starts again and 
> the address is immediately deleted.  We are left with no temporary addresses 
> on the interface, and no more will be created until the public IP address is 
> updated.  To avoid this, set the expiry time to be the minimum of the time 
> left on the public address or the config option PLUS the current age of the 
> public interface.
> 
> Version 2, now with 100% fewer line wraps.  Thanks to David Miller for
> pointing out the line wrapping issue.
> 
> Signed-off-by: Glenn Wurster <gwurster@scs.carleton.ca>

This can only happen if we apply your other patch, which I showed
was incorrect as per RFCs.

We only create temporary address when public addresses are created,
and this is the point where we are handling a router advertisement
with non-zero Valid Lifetime.

Therefore I'm not applying this patch either.

