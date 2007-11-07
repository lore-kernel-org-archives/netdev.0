From: "Templin, Fred L" <Fred.L.Templin@boeing.com>
Subject: RE: [PATCH 02/05] ipv6: RFC4214 Support
Date: Wed, 7 Nov 2007 10:52:47 -0800
Message-ID: <39C363776A4E8C4A94691D2BD9D1C9A1029EDBF4@XCH-NW-7V2.nw.nos.boeing.com>
References: <200711071658.59478.netdev@axxeo.de><20071108.031214.124029872.yoshfuji@linux-ipv6.org><39C363776A4E8C4A94691D2BD9D1C9A1029EDBF2@XCH-NW-7V2.nw.nos.boeing.com> <20071108.034840.124896893.yoshfuji@linux-ipv6.org>
Mime-Version: 1.0
Content-Type: text/plain;
	charset="iso-2022-jp"
Content-Transfer-Encoding: 7bit
Cc: <netdev@axxeo.de>, <netdev@vger.kernel.org>
To: =?iso-2022-jp?B?WU9TSElGVUpJIEhpZGVha2kgLyAbJEI1SEYjMVFMQBsoQg==?=
	<yoshfuji@linux-ipv6.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from blv-smtpout-01.boeing.com ([130.76.32.69]:47139 "EHLO
	blv-smtpout-01.boeing.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753578AbXKGSx0 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 7 Nov 2007 13:53:26 -0500
Content-class: urn:content-classes:message
In-Reply-To: <20071108.034840.124896893.yoshfuji@linux-ipv6.org>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

 

> -----Original Message-----
> From: YOSHIFUJI Hideaki / 吉藤英明 [mailto:yoshfuji@linux-ipv6.org] 
> Sent: Wednesday, November 07, 2007 10:49 AM
> To: Templin, Fred L
> Cc: netdev@axxeo.de; netdev@vger.kernel.org; yoshfuji@linux-ipv6.org
> Subject: Re: [PATCH 02/05] ipv6: RFC4214 Support
> 
> In article 
> <39C363776A4E8C4A94691D2BD9D1C9A1029EDBF2@XCH-NW-7V2.nw.nos.bo
> eing.com> (at Wed, 7 Nov 2007 10:24:50 -0800), "Templin, Fred 
> L" <Fred.L.Templin@boeing.com> says:
> 
> >  
> > 
> > > -----Original Message-----
> > > From: YOSHIFUJI Hideaki / 吉藤英明 [mailto:yoshfuji@linux-ipv6.org] 
> > > Sent: Wednesday, November 07, 2007 10:12 AM
> > > To: netdev@axxeo.de
> > > Cc: Templin, Fred L; netdev@vger.kernel.org; 
> yoshfuji@linux-ipv6.org
> > > Subject: Re: [PATCH 02/05] ipv6: RFC4214 Support
> > > 
> > > Hello.
> > > 
> > > In article <200711071658.59478.netdev@axxeo.de> (at Wed, 7 
> > > Nov 2007 16:58:59 +0100), Ingo Oeser <netdev@axxeo.de> says:
> > > 
> > > > > +	eui[0] = 0;
> > > > > +
> > > > > +	/* Check for RFC3330 global address ranges */
> > > > > +	if (((ipv4 >= 0x01000000) && (ipv4 < 0x0a000000)) ||
> > > > > +	    ((ipv4 >= 0x0b000000) && (ipv4 < 0x7f000000)) ||
> > > > > +	    ((ipv4 >= 0x80000000) && (ipv4 < 0xa9fe0000)) ||
> > > > > +	    ((ipv4 >= 0xa9ff0000) && (ipv4 < 0xac100000)) ||
> > > > > +	    ((ipv4 >= 0xac200000) && (ipv4 < 0xc0a80000)) ||
> > > > > +	    ((ipv4 >= 0xc0a90000) && (ipv4 < 0xc6120000)) ||
> > > > > +	    ((ipv4 >= 0xc6140000) && (ipv4 < 
> 0xe0000000))) eui[0] |=
> > > > > 0x2;
> > > > > +
> > > > 
> > > > Instead of converting network to host byte order at runtime 
> > > > and comparing the results to constants, let the compiler convert
> > > > the constants to network byte order and compare in 
> network order.
> > > > 
> > > > so use:
> > > > 
> > > >  if (((*addr >= htonl(0x01000000)) && (*addr < 
> > > htonl(0x0a000000))) || ....
> > > > 
> > > > instead. The compiler will notice that "0x01000000" is a 
> > > constant and will
> > > > use "_constant_htonl()" automatically.
> > > 
> > > No, you cannot do this.
> > > When you check the "range", you need to use host-byte order.
> > 
> > I think the original poster was correct on this one; the addr comes
> > in in network byte order, and the constants are depicted in host
> > byte order. So, the suggested fix was to have htonl(const) to make
> > all of the constants into network byte order while leaving addr
> > alone.
> 
> I don't understand.
> 
> For example, 1.0.0.11 is valid IPv4 global address.
> In little-endian, this is not in the range of
> 0x00000001 <= addr <= 0x0000000a (addr is 0x0b000001).

Maybe it is I who did not understand. Can you suggest a clean solution?

Fred
fred.l.templin@boeing.com
