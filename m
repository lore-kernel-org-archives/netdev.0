From: YOSHIFUJI Hideaki / =?iso-2022-jp?B?GyRCNUhGIzFRTEAbKEI=?=
	<yoshfuji@linux-ipv6.org>
Subject: Re: [PATCH 02/05] ipv6: RFC4214 Support
Date: Thu, 08 Nov 2007 03:12:14 +0900 (JST)
Message-ID: <20071108.031214.124029872.yoshfuji@linux-ipv6.org>
References: <39C363776A4E8C4A94691D2BD9D1C9A1029EDBE3@XCH-NW-7V2.nw.nos.boeing.com>
	<200711071658.59478.netdev@axxeo.de>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: Fred.L.Templin@boeing.com, netdev@vger.kernel.org,
	yoshfuji@linux-ipv6.org
To: netdev@axxeo.de
Return-path: <netdev-owner@vger.kernel.org>
Received: from yue.linux-ipv6.org ([203.178.140.15]:38797 "EHLO
	yue.st-paulia.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753916AbXKGSML (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 7 Nov 2007 13:12:11 -0500
In-Reply-To: <200711071658.59478.netdev@axxeo.de>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hello.

In article <200711071658.59478.netdev@axxeo.de> (at Wed, 7 Nov 2007 16:58:59 +0100), Ingo Oeser <netdev@axxeo.de> says:

> > +	eui[0] = 0;
> > +
> > +	/* Check for RFC3330 global address ranges */
> > +	if (((ipv4 >= 0x01000000) && (ipv4 < 0x0a000000)) ||
> > +	    ((ipv4 >= 0x0b000000) && (ipv4 < 0x7f000000)) ||
> > +	    ((ipv4 >= 0x80000000) && (ipv4 < 0xa9fe0000)) ||
> > +	    ((ipv4 >= 0xa9ff0000) && (ipv4 < 0xac100000)) ||
> > +	    ((ipv4 >= 0xac200000) && (ipv4 < 0xc0a80000)) ||
> > +	    ((ipv4 >= 0xc0a90000) && (ipv4 < 0xc6120000)) ||
> > +	    ((ipv4 >= 0xc6140000) && (ipv4 < 0xe0000000))) eui[0] |=
> > 0x2;
> > +
> 
> Instead of converting network to host byte order at runtime 
> and comparing the results to constants, let the compiler convert
> the constants to network byte order and compare in network order.
> 
> so use:
> 
>  if (((*addr >= htonl(0x01000000)) && (*addr < htonl(0x0a000000))) || ....
> 
> instead. The compiler will notice that "0x01000000" is a constant and will
> use "_constant_htonl()" automatically.

No, you cannot do this.
When you check the "range", you need to use host-byte order.

> > +
> > +static inline int ipv6_addr_is_isatap(const struct in6_addr *addr)
> > +{
> > +       return (addr->s6_addr32[2] == __constant_htonl(0x02005EFE) ||
> > +               addr->s6_addr32[2] == __constant_htonl(0x00005EFE));
> > +}
> > +#endif
> 
> The compiler will notice that "0x01000000" is a constant and will
> use "_constant_htonl()" automatically. Please use simply htonl().

Right.  And, maybe, you can write as follows:
	return ((addr->s6_addr32[2] | htonl(0x02000000)) == htonl(0x02005EFE));

--yoshfuji
