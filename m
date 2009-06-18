From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] ipv6: Keep index within tab_unreach[]
Date: Wed, 17 Jun 2009 19:20:39 -0700 (PDT)
Message-ID: <20090617.192039.171958637.davem@davemloft.net>
References: <4A37E715.4060504@gmail.com>
	<4A39A200.20603@hp.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: roel.kluin@gmail.com, netdev@vger.kernel.org,
	akpm@linux-foundation.org
To: brian.haley@hp.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:41753
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1758003AbZFRCUg (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 17 Jun 2009 22:20:36 -0400
In-Reply-To: <4A39A200.20603@hp.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Brian Haley <brian.haley@hp.com>
Date: Wed, 17 Jun 2009 22:10:08 -0400

> Roel Kluin wrote:
>> @@ -923,7 +923,7 @@ int icmpv6_err_convert(int type, int code, int *err)
>>  	switch (type) {
>>  	case ICMPV6_DEST_UNREACH:
>>  		fatal = 1;
>> -		if (code <= ICMPV6_PORT_UNREACH) {
>> +		if (code <= ICMPV6_PORT_UNREACH && code >= 0) {
>>  			*err  = tab_unreach[code].err;
>>  			fatal = tab_unreach[code].fatal;
>>  		}
> 
> The code value in the ICMPv6 header is a u8, so should always be positive, right?
> It doesn't hurt I guess though.

True.  Probably best to pass this thing in as a 'u8', rathern than as
an 'int'.
