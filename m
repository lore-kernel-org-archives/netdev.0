From: Herbert Xu <herbert@gondor.apana.org.au>
Subject: Re: [Bugme-new] [Bug 9543] New: RTNL: assertion failed at net/ipv6/addrconf.c (2164)/RTNL: assertion failed at net/ipv4/devinet.c (1055)
Date: Sat, 15 Dec 2007 12:10:52 +0800
Message-ID: <20071215041052.GA25324@gondor.apana.org.au>
References: <E1J2Rgs-0006mz-00@gondolin.me.apana.org.au> <28503.1197481615@death> <Pine.LNX.4.64.0712141707090.30334@bizon.gios.gov.pl> <20071214182638.GC25879@gospo.usersys.redhat.com> <Pine.LNX.4.64.0712141955080.12202@bizon.gios.gov.pl> <20071214224722.GA8728@gospo.usersys.redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Krzysztof Oledzki <olel@ans.pl>, Jay Vosburgh <fubar@us.ibm.com>,
	Andrew Morton <akpm@linux-foundation.org>,
	bugme-daemon@bugzilla.kernel.org, shemminger@linux-foundation.org,
	davem@davemloft.net, netdev@vger.kernel.org
To: Andy Gospodarek <andy@greyhouse.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from rhun.apana.org.au ([64.62.148.172]:1617 "EHLO
	arnor.apana.org.au" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1753344AbXLOELt (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 14 Dec 2007 23:11:49 -0500
Content-Disposition: inline
In-Reply-To: <20071214224722.GA8728@gospo.usersys.redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, Dec 14, 2007 at 05:47:22PM -0500, Andy Gospodarek wrote:
>
> I'm guessing if we go back to using a write-lock for bond->lock this
> will go back to working again, but I'm not totally convinced since there
> are plenty of places where we used a read-lock with it.

Sorry I forgot to cc you earlier Andy.

But to fix this you need make sure that all read locks on bond->lock
in process context disable BH.  This is because at least one write
lock can be taken from BH context.

You don't need to turn the read locks into write locks however.

This is also something that we can undo once the set_multicast
interface has been fixed to not take the tx lock.

Cheers,
-- 
Visit Openswan at http://www.openswan.org/
Email: Herbert Xu ~{PmV>HI~} <herbert@gondor.apana.org.au>
Home Page: http://gondor.apana.org.au/~herbert/
PGP Key: http://gondor.apana.org.au/~herbert/pubkey.txt
