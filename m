From: "David Laight" <David.Laight@ACULAB.COM>
Subject: RE: [patch] isdn: fix a wrapping bug in isdn_ppp_ioctl()
Date: Wed, 10 Oct 2012 16:44:02 +0100
Message-ID: <AE90C24D6B3A694183C094C60CF0A2F6026B7034@saturn3.aculab.com>
References: <20121010093816.GA3669@elgon.mountain> <1349864358.2386.27.camel@joe-AO722> <m21uh67csy.fsf@igel.home> <1349874007.2386.42.camel@joe-AO722> <m2sj9m5sz5.fsf@igel.home> <1349880119.2386.46.camel@joe-AO722> <AE90C24D6B3A694183C094C60CF0A2F6026B7033@saturn3.aculab.com> <1349882347.2386.47.camel@joe-AO722>
Mime-Version: 1.0
Content-Type: text/plain;
	charset="Windows-1252"
Content-Transfer-Encoding: 8BIT
Cc: "Andreas Schwab" <schwab@linux-m68k.org>,
	"Dan Carpenter" <dan.carpenter@oracle.com>,
	"Karsten Keil" <isdn@linux-pingi.de>,
	"David S. Miller" <davem@davemloft.net>,
	"Masanari Iida" <standby24x7@gmail.com>, <netdev@vger.kernel.org>,
	<kernel-janitors@vger.kernel.org>
To: "Joe Perches" <joe@perches.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx0.aculab.com ([213.249.233.131]:57350 "HELO mx0.aculab.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with SMTP
	id S1751262Ab2JJPpK convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 10 Oct 2012 11:45:10 -0400
Received: from mx0.aculab.com ([127.0.0.1])
 by localhost (mx0.aculab.com [127.0.0.1]) (amavisd-new, port 10024) with SMTP
 id 27843-01 for <netdev@vger.kernel.org>;
 Wed, 10 Oct 2012 16:45:06 +0100 (BST)
Content-class: urn:content-classes:message
In-Reply-To: <1349882347.2386.47.camel@joe-AO722>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

> On Wed, 2012-10-10 at 15:59 +0100, David Laight wrote:
> > Seems to me the code is expecting 256 bits of data, not any multiple of int,
> > long or anything else.
> 
> include/linux/isdn_ppp.h:#define PPPIOCGCOMPRESSORS _IOR('t',134,unsigned long [8])

That doesn't mean the whole thing makes any sense on 64bit systems.
A whole load of historic code used 'long' to ensure 32bit.
Some of that might have crept into Linux sources.

Since I suspect there are a maximum of 256 bits on both 32 and 64bit
systems, I wouldn't like to guess exactly how any particular 64bit
application chooses to check the bitmap.

The ioctl constant may be wrong on 64 bit systems.

	David
