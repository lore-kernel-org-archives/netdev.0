From: Brian Haley <brian.haley@hp.com>
Subject: Re: [PATCH] ipv6: Keep index within tab_unreach[]
Date: Thu, 18 Jun 2009 00:09:36 -0400
Message-ID: <4A39BE00.1050506@hp.com>
References: <4A37E715.4060504@gmail.com>	<4A39A200.20603@hp.com> <20090617.192039.171958637.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: roel.kluin@gmail.com, netdev@vger.kernel.org,
	akpm@linux-foundation.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from g4t0014.houston.hp.com ([15.201.24.17]:41149 "EHLO
	g4t0014.houston.hp.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750707AbZFREKA (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 18 Jun 2009 00:10:00 -0400
In-Reply-To: <20090617.192039.171958637.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

David Miller wrote:
> From: Brian Haley <brian.haley@hp.com>
> Date: Wed, 17 Jun 2009 22:10:08 -0400
> 
>> Roel Kluin wrote:
>>> @@ -923,7 +923,7 @@ int icmpv6_err_convert(int type, int code, int *err)
>>>  	switch (type) {
>>>  	case ICMPV6_DEST_UNREACH:
>>>  		fatal = 1;
>>> -		if (code <= ICMPV6_PORT_UNREACH) {
>>> +		if (code <= ICMPV6_PORT_UNREACH && code >= 0) {
>>>  			*err  = tab_unreach[code].err;
>>>  			fatal = tab_unreach[code].fatal;
>>>  		}
>> The code value in the ICMPv6 header is a u8, so should always be positive, right?
>> It doesn't hurt I guess though.
> 
> True.  Probably best to pass this thing in as a 'u8', rathern than as
> an 'int'.

"type" is a u8 too, but both seem to be passed as int's everywhere (rawv6,
tcp, sctp and dccp), and in the err_handler() func pointer in the inet6_protocol
struct.  I can try and cook something up in the next few days that changes
it all to u8's.

-Brian
