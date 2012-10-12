From: Karsten Keil <kkeil@linux-pingi.de>
Subject: Re: [patch] isdn: fix a wrapping bug in isdn_ppp_ioctl()
Date: Fri, 12 Oct 2012 09:49:52 +0200
Message-ID: <5077CBA0.3040707@linux-pingi.de>
References: <20121010093816.GA3669@elgon.mountain>  <1349864358.2386.27.camel@joe-AO722> <m21uh67csy.fsf@igel.home>  <1349874007.2386.42.camel@joe-AO722> <m2sj9m5sz5.fsf@igel.home>  <1349880119.2386.46.camel@joe-AO722>  <AE90C24D6B3A694183C094C60CF0A2F6026B7033@saturn3.aculab.com>  <1349882347.2386.47.camel@joe-AO722>  <AE90C24D6B3A694183C094C60CF0A2F6026B7034@saturn3.aculab.com> <1349884342.2035.1.camel@joe-AO722>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: David Laight <David.Laight@ACULAB.COM>,
	Andreas Schwab <schwab@linux-m68k.org>,
	Dan Carpenter <dan.carpenter@oracle.com>,
	Karsten Keil <isdn@linux-pingi.de>,
	"David S. Miller" <davem@davemloft.net>,
	Masanari Iida <standby24x7@gmail.com>, netdev@vger.kernel.org,
	kernel-janitors@vger.kernel.org
To: Joe Perches <joe@perches.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from moutng.kundenserver.de ([212.227.126.186]:63354 "EHLO
	moutng.kundenserver.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932482Ab2JLHuh (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 12 Oct 2012 03:50:37 -0400
In-Reply-To: <1349884342.2035.1.camel@joe-AO722>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi,
Am 10.10.2012 17:52, schrieb Joe Perches:
> On Wed, 2012-10-10 at 16:44 +0100, David Laight wrote:
>>> On Wed, 2012-10-10 at 15:59 +0100, David Laight wrote:
>>>> Seems to me the code is expecting 256 bits of data, not any multiple of int,
>>>> long or anything else.
>>>
>>> include/linux/isdn_ppp.h:#define PPPIOCGCOMPRESSORS _IOR('t',134,unsigned long [8])
>>
>> That doesn't mean the whole thing makes any sense on 64bit systems.
>> A whole load of historic code used 'long' to ensure 32bit.
>> Some of that might have crept into Linux sources.
> 
> Very true, but it's exported via copy_to_user.
> 
>> Since I suspect there are a maximum of 256 bits on both 32 and 64bit
>> systems, I wouldn't like to guess exactly how any particular 64bit
>> application chooses to check the bitmap.
>>
>> The ioctl constant may be wrong on 64 bit systems.
> 
> shrug.  Not much to do about it now.
> isdn isn't very active.
> 
> Karsten?  What do you think?
> 

I use ipppd as testbench to test remote connections via different PPP
clients running on a 64 bit system without problems so far - but I did
not use any compressions for some years, so maybe this code was never
tested on 64 bit and at least not on mixed 32/64 bit systems.
If I will find some time, I will check if the compression works.
I did not wrote this part, so I cannot say how the code should work
correctly out of the box, I  need to analyze this first by myself.

Karsten
