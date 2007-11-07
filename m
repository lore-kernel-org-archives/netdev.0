From: YOSHIFUJI Hideaki / =?iso-2022-jp?B?GyRCNUhGIzFRTEAbKEI=?=
	<yoshfuji@linux-ipv6.org>
Subject: Re: [PATCH 02/05] ipv6: RFC4214 Support
Date: Thu, 08 Nov 2007 04:47:45 +0900 (JST)
Message-ID: <20071108.044745.123583545.yoshfuji@linux-ipv6.org>
References: <39C363776A4E8C4A94691D2BD9D1C9A1029EDBF2@XCH-NW-7V2.nw.nos.boeing.com>
	<20071108.034840.124896893.yoshfuji@linux-ipv6.org>
	<39C363776A4E8C4A94691D2BD9D1C9A1029EDBF4@XCH-NW-7V2.nw.nos.boeing.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@axxeo.de, netdev@vger.kernel.org, yoshfuji@linux-ipv6.org
To: Fred.L.Templin@boeing.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from yue.linux-ipv6.org ([203.178.140.15]:38816 "EHLO
	yue.st-paulia.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754039AbXKGTrl (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 7 Nov 2007 14:47:41 -0500
In-Reply-To: <39C363776A4E8C4A94691D2BD9D1C9A1029EDBF4@XCH-NW-7V2.nw.nos.boeing.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

In article <39C363776A4E8C4A94691D2BD9D1C9A1029EDBF4@XCH-NW-7V2.nw.nos.boeing.com> (at Wed, 7 Nov 2007 10:52:47 -0800), "Templin, Fred L" <Fred.L.Templin@boeing.com> says:

> > > > > > +	if (((ipv4 >= 0x01000000) && (ipv4 < 0x0a000000)) ||
> > > > > > +	    ((ipv4 >= 0x0b000000) && (ipv4 < 0x7f000000)) ||
> > > > > > +	    ((ipv4 >= 0x80000000) && (ipv4 < 0xa9fe0000)) ||
> > > > > > +	    ((ipv4 >= 0xa9ff0000) && (ipv4 < 0xac100000)) ||
> > > > > > +	    ((ipv4 >= 0xac200000) && (ipv4 < 0xc0a80000)) ||
> > > > > > +	    ((ipv4 >= 0xc0a90000) && (ipv4 < 0xc6120000)) ||
> > > > > > +	    ((ipv4 >= 0xc6140000) && (ipv4 < 
> > 0xe0000000))) eui[0] |=
> > > > > > 0x2;

> Maybe it is I who did not understand. Can you suggest a clean solution?

You could write each element as LOOPBACK(), MULTICAST()
etc.
	eui[0] = (!ZERONETO(a) &&
	          !PRIVATE_10(a) &&
		  !LINKLOCAL(a) &&
		  !PRIVATE_172(a) &&
		  !PRIVATE_192(a) &&
		  !NETICDEVBENCH(a) &&
		  !MULTICAST(a)) ? 2 : 0;

--yoshfuji
