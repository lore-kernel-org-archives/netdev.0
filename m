From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] Ensure IF_READY is unset when link is not ready
Date: Wed, 07 Mar 2007 15:54:38 -0800 (PST)
Message-ID: <20070307.155438.27784474.davem@davemloft.net>
References: <20070305175924.2f46446c.mitch@linux.vnet.ibm.com>
	<E1HP5rQ-0008RW-00@gondolin.me.apana.org.au>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: mitch@linux.vnet.ibm.com, yoshfuji@linux-ipv6.org,
	netdev@vger.kernel.org, usagi-core@linux-ipv6.org
To: herbert@gondor.apana.org.au
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:44851
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1751004AbXCGXyj (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 7 Mar 2007 18:54:39 -0500
In-Reply-To: <E1HP5rQ-0008RW-00@gondolin.me.apana.org.au>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Herbert Xu <herbert@gondor.apana.org.au>
Date: Thu, 08 Mar 2007 10:47:56 +1100

> Mitsuru Chinen <mitch@linux.vnet.ibm.com> wrote:
> > 
> > On linux-2.6.21-rc2 or later, IPv6 link-local address is not assigned to
> > some kind of interfaces during system start-up. (I found this issue
> > occures with e100, e1000 and tg3.)
> 
> Here is an alternative fix.
> 
> [IPV6]: Do not set IF_READY if device is down
> 
> Now that we add the IPv6 device at registration time we don't need
> to set IF_READY in ipv6_add_dev anymore because we will always get
> a NETDEV_UP event later on should the device ever become ready.
> 
> Signed-off-by: Herbert Xu <herbert@gondor.apana.org.au>

Indeed, this looks like it will do the right thing.

And if you look into the history of the code in this area
I think you'll find that this snippet being removed existed
exactly because inet6_dev creation happened long after the
device was registered.
