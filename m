From: Dan Carpenter <dan.carpenter@oracle.com>
Subject: Re: [patch] isdn: mISDN: set ->family in ->getname()
Date: Tue, 23 Apr 2013 11:02:14 +0300
Message-ID: <20130423080213.GA30376@mwanda>
References: <20130423062414.GC15893@elgon.mountain>
 <51763AD7.10102@bfs.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Karsten Keil <isdn@linux-pingi.de>,
	"David S. Miller" <davem@davemloft.net>, netdev@vger.kernel.org,
	kernel-janitors@vger.kernel.org
To: walter harms <wharms@bfs.de>
Return-path: <netdev-owner@vger.kernel.org>
Received: from aserp1040.oracle.com ([141.146.126.69]:35095 "EHLO
	aserp1040.oracle.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755214Ab3DWICS (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 23 Apr 2013 04:02:18 -0400
Content-Disposition: inline
In-Reply-To: <51763AD7.10102@bfs.de>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, Apr 23, 2013 at 09:40:07AM +0200, walter harms wrote:
> 
> 
> Am 23.04.2013 08:24, schrieb Dan Carpenter:
> > The "maddr->family" variable was not set but instead it leaked stack
> > information to userspace.
> > 
> > Signed-off-by: Dan Carpenter <dan.carpenter@oracle.com>
> > 
> > diff --git a/drivers/isdn/mISDN/socket.c b/drivers/isdn/mISDN/socket.c
> > index 8b07f83..a838864 100644
> > --- a/drivers/isdn/mISDN/socket.c
> > +++ b/drivers/isdn/mISDN/socket.c
> > @@ -578,6 +578,7 @@ data_sock_getname(struct socket *sock, struct sockaddr *addr,
> >  	lock_sock(sk);
> >  
> >  	*addr_len = sizeof(*maddr);
> > +	maddr->family = AF_ISDN;
> >  	maddr->dev = _pms(sk)->dev->id;
> >  	maddr->channel = _pms(sk)->ch.nr;
> >  	maddr->sapi = _pms(sk)->ch.addr & 0xff;
> 
> just nitpicking ...
> net/nfc/llcp/sock.c has a memset(..0,..) for the struct. Is this
> an options here also ?
> (just to make sure everything is 0 in the beginning)

In net/nfc/llcp/sock.c the struct has a hole after ->sa_family so
the memset() isn't optional.

These ->getname() patches were from manually auditing all the
->getname() functions.  I've tried to follow the local style in my
patches.  Quite a few of these use __packed structs to avoid holes
and the need for the memset().

regards,
dan carpenter
