From: "Andy Gospodarek" <andy@greyhouse.net>
Subject: Re: [Bugme-new] [Bug 9543] New: RTNL: assertion failed at net/ipv6/addrconf.c (2164)/RTNL: assertion failed at net/ipv4/devinet.c (1055)
Date: Sat, 15 Dec 2007 10:09:28 -0500
Message-ID: <bdfc5d6e0712150709k2dc0a845n84c494c519298f8d@mail.gmail.com>
References: <E1J2Rgs-0006mz-00@gondolin.me.apana.org.au>
	 <28503.1197481615@death>
	 <Pine.LNX.4.64.0712141707090.30334@bizon.gios.gov.pl>
	 <20071214182638.GC25879@gospo.usersys.redhat.com>
	 <Pine.LNX.4.64.0712141955080.12202@bizon.gios.gov.pl>
	 <20071214224722.GA8728@gospo.usersys.redhat.com>
	 <20071215041052.GA25324@gondor.apana.org.au>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: "Krzysztof Oledzki" <olel@ans.pl>,
	"Jay Vosburgh" <fubar@us.ibm.com>,
	"Andrew Morton" <akpm@linux-foundation.org>,
	bugme-daemon@bugzilla.kernel.org, shemminger@linux-foundation.org,
	davem@davemloft.net, netdev@vger.kernel.org
To: "Herbert Xu" <herbert@gondor.apana.org.au>
Return-path: <netdev-owner@vger.kernel.org>
Received: from fk-out-0910.google.com ([209.85.128.190]:15554 "EHLO
	fk-out-0910.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1757677AbXLOPJb (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 15 Dec 2007 10:09:31 -0500
Received: by fk-out-0910.google.com with SMTP id z23so409721fkz.5
        for <netdev@vger.kernel.org>; Sat, 15 Dec 2007 07:09:30 -0800 (PST)
In-Reply-To: <20071215041052.GA25324@gondor.apana.org.au>
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Dec 14, 2007 11:10 PM, Herbert Xu <herbert@gondor.apana.org.au> wrote:
> On Fri, Dec 14, 2007 at 05:47:22PM -0500, Andy Gospodarek wrote:
> >
> > I'm guessing if we go back to using a write-lock for bond->lock this
> > will go back to working again, but I'm not totally convinced since there
> > are plenty of places where we used a read-lock with it.
>
> Sorry I forgot to cc you earlier Andy.
>
> But to fix this you need make sure that all read locks on bond->lock
> in process context disable BH.  This is because at least one write
> lock can be taken from BH context.

I agree with you completely, Herbet, which is why I was surprised that
my first apparently did not resolve the issue.  I felt it should
have....

> You don't need to turn the read locks into write locks however.
>
> This is also something that we can undo once the set_multicast
> interface has been fixed to not take the tx lock.
>
> Cheers,
> --
> Visit Openswan at http://www.openswan.org/
> Email: Herbert Xu ~{PmV>HI~} <herbert@gondor.apana.org.au>
> Home Page: http://gondor.apana.org.au/~herbert/
> PGP Key: http://gondor.apana.org.au/~herbert/pubkey.txt
>
