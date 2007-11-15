From: "Templin, Fred L" <Fred.L.Templin@boeing.com>
Subject: RE: [PATCH 01/01] ipv6: RFC4214 Support (v2.2)
Date: Thu, 15 Nov 2007 10:06:48 -0800
Message-ID: <39C363776A4E8C4A94691D2BD9D1C9A1029EDC30@XCH-NW-7V2.nw.nos.boeing.com>
References: <4739D7F7.90300@hp.com><39C363776A4E8C4A94691D2BD9D1C9A1029EDC29@XCH-NW-7V2.nw.nos.boeing.com><39C363776A4E8C4A94691D2BD9D1C9A1029EDC2B@XCH-NW-7V2.nw.nos.boeing.com> <20071115.202208.126883108.yoshfuji@linux-ipv6.org>
Mime-Version: 1.0
Content-Type: text/plain;
	charset="iso-2022-jp"
Content-Transfer-Encoding: 7bit
Cc: <netdev@vger.kernel.org>, <vladislav.yasevich@hp.com>
To: =?iso-2022-jp?B?WU9TSElGVUpJIEhpZGVha2kgLyAbJEI1SEYjMVFMQBsoQg==?=
	<yoshfuji@linux-ipv6.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from stl-smtpout-01.boeing.com ([130.76.96.56]:38345 "EHLO
	stl-smtpout-01.boeing.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753039AbXKOSH2 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 15 Nov 2007 13:07:28 -0500
Content-class: urn:content-classes:message
In-Reply-To: <20071115.202208.126883108.yoshfuji@linux-ipv6.org>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Yoshifuji,

See below for follow-up:

> -----Original Message-----
> From: YOSHIFUJI Hideaki / 吉藤英明 [mailto:yoshfuji@linux-ipv6.org] 
> Sent: Thursday, November 15, 2007 3:22 AM
> To: Templin, Fred L
> Cc: netdev@vger.kernel.org; vladislav.yasevich@hp.com; 
> yoshfuji@linux-ipv6.org
> Subject: Re: [PATCH 01/01] ipv6: RFC4214 Support (v2.2)
> 
> In article 
> <39C363776A4E8C4A94691D2BD9D1C9A1029EDC2B@XCH-NW-7V2.nw.nos.bo
eing.com> (at Wed, 14 Nov 2007 22:44:17 -0800), "Templin, Fred L" > <Fred.L.Templin@boeing.com> says:
> 
> > --- linux-2.6.24-rc2/net/ipv6/addrconf.c.orig	
> 2007-11-08 11:59:35.000000000 -0800
> > +++ linux-2.6.24-rc2/net/ipv6/addrconf.c	2007-11-14 
> 22:17:28.000000000 -0800
> > @@ -1424,6 +1424,21 @@ static int addrconf_ifid_infiniband(u8 *
> >  	return 0;
> >  }
> >  
> > +static int addrconf_ifid_isatap(u8 *eui, __be32 addr)
> > +{
> > +
> > +	eui[0] = 0x02; eui[1] = 0; eui[2] = 0x5E; eui[3] = 0xFE;
> > +	memcpy (eui+4, &addr, 4);
> > +
> > +	if (ZERONET(addr) || PRIVATE_10(addr) || LOOPBACK(addr) ||
> > +	    LINKLOCAL_169(addr) || PRIVATE_172(addr) || 
> TEST_192(addr) ||
> > +	    ANYCAST_6TO4(addr) || PRIVATE_192(addr) || TEST_198(addr) ||
> > +	    MULTICAST(addr) || BADCLASS(addr))
> > +		eui[0] &= ~0x02;
> > +
> > +	return 0;
> > +}
> > +
> >  static int ipv6_generate_eui64(u8 *eui, struct net_device *dev)
> >  {
> >  	switch (dev->type) {
> 
> {
>   eui[0] = (ZERONET(addr) || PRIVATE_10(addr) || LOOPBACK(addr) ||
>             LINKLOCAL_169(addr) || PRIVATE_172(addr) || 
> TEST_192(addr) ||
>             ANYCAST_6TO4(addr) || PRIVATE_192(addr) || 
> TEST_198(addr) ||
>             MULTICAST(addr) || BADCLASS(addr)) ? 0 : 2;
>   eui[1] = 0;
>   eui[2] = 0x5E;
>   eui[3] = 0xFE;
>   memcpy (eui+4, &addr, 4);
> }

OK; I'll make this change.

> > @@ -2167,7 +2185,8 @@ static void addrconf_dev_config(struct n
> >  	    (dev->type != ARPHRD_FDDI) &&
> >  	    (dev->type != ARPHRD_IEEE802_TR) &&
> >  	    (dev->type != ARPHRD_ARCNET) &&
> > -	    (dev->type != ARPHRD_INFINIBAND)) {
> > +	    (dev->type != ARPHRD_INFINIBAND) &&
> > +	    !(dev->priv_flags & IFF_ISATAP)) {
> >  		/* Alas, we support only Ethernet autoconfiguration. */
> >  		return;
> >  	}
> 
> Because priv_flags are local to device type, you need to 
> check dev->type:
> 	(dev->type == ARPHRD_SIT && !(dev->priv_flags & IFF_ISATAP))
> or something like this.

OK.

> > +	struct ip_tunnel *t  = netdev_priv(ifp->idev->dev);
> > +	if (t->parms.i_key != INADDR_NONE) {
> > +		spin_lock(&ifp->lock);
> 
> I guess INADDR_ANY.

No; INADDR_NONE is correct. Non-zero router value is the way
'ip' tells the kernel that the interface is ISATAP. INADDR_NONE
means "ISATAP, but no router". The ISATAP router will never be
INADDR_ANY.

Thanks - Fred
fred.l.templin@boeing.com

> --yoshfuji
> 
