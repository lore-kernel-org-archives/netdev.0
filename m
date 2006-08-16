From: Herbert Xu <herbert@gondor.apana.org.au>
Subject: Re: [PATCH 09/16] [IPv6] address: Convert address notification to use rtnl_notify()
Date: Wed, 16 Aug 2006 21:12:40 +1000
Message-ID: <20060816111240.GA28846@gondor.apana.org.au>
References: <20060815122300.GV14627@postel.suug.ch> <E1GDBbw-0006Kz-00@gondolin.me.apana.org.au> <20060816105856.GW14627@postel.suug.ch>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: hasso@estpak.ee, kuznet@ms2.inr.ac.ru, hadi@cyberus.ca,
	davem@davemloft.net, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from rhun.apana.org.au ([64.62.148.172]:25868 "EHLO
	arnor.apana.org.au") by vger.kernel.org with ESMTP id S1750950AbWHPLND
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 16 Aug 2006 07:13:03 -0400
To: Thomas Graf <tgraf@suug.ch>
Content-Disposition: inline
In-Reply-To: <20060816105856.GW14627@postel.suug.ch>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hi Thomas:

On Wed, Aug 16, 2006 at 12:58:56PM +0200, Thomas Graf wrote:
> 
> All route and tc notifications already use the pid so applications
> can decide whether the event was caused by them. A notification
> is a reply to a request so it doesn't even violate RFC 2367.

Actually most IPv4 notifications *do* set the pid to zero which is
the right thing to do for kernel-generated messages.

You're right though that the IPv6 notification modified by this patch
does set the pid to the netlink originator.  Looking back in history
it seems that this behaviour was only introduced last year to a subset
of notifications.

This inconsistency is very bad.  IMHO this change (made last year)
should be reverted so that all kernel generated (broadcast) notifications
have the originator set to zero to match the source address of the
message.

Any notification that sets the netlink pid to current->pid is
*completely* bogus.  Let me repeat this, the netlink pid is not
a process ID.

Cheers,
-- 
Visit Openswan at http://www.openswan.org/
Email: Herbert Xu ~{PmV>HI~} <herbert@gondor.apana.org.au>
Home Page: http://gondor.apana.org.au/~herbert/
PGP Key: http://gondor.apana.org.au/~herbert/pubkey.txt
