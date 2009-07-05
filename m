From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] ipv6: Keep index within tab_unreach[]
Date: Sun, 05 Jul 2009 15:52:15 -0700 (PDT)
Message-ID: <20090705.155215.20761447.davem@davemloft.net>
References: <4A37E715.4060504@gmail.com>
	<20090705034655.GA7635@gondor.apana.org.au>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: roel.kluin@gmail.com, netdev@vger.kernel.org,
	akpm@linux-foundation.org
To: herbert@gondor.apana.org.au
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:35390
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1754611AbZGEWwI (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 5 Jul 2009 18:52:08 -0400
In-Reply-To: <20090705034655.GA7635@gondor.apana.org.au>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Herbert Xu <herbert@gondor.apana.org.au>
Date: Sun, 5 Jul 2009 11:46:55 +0800

> Roel Kluin <roel.kluin@gmail.com> wrote:
>> Ensure that index `code' remains within array tab_unreach[]
>> 
>> Signed-off-by: Roel Kluin <roel.kluin@gmail.com>
>> ---
>> diff --git a/net/ipv6/icmp.c b/net/ipv6/icmp.c
>> index 36dff88..8f850de 100644
>> --- a/net/ipv6/icmp.c
>> +++ b/net/ipv6/icmp.c
>> @@ -923,7 +923,7 @@ int icmpv6_err_convert(int type, int code, int *err)
>>        switch (type) {
>>        case ICMPV6_DEST_UNREACH:
>>                fatal = 1;
>> -               if (code <= ICMPV6_PORT_UNREACH) {
>> +               if (code <= ICMPV6_PORT_UNREACH && code >= 0) {
> 
> Why not make code unsigned?

type and code should both be "u8"'s, we made a similar
conversio of a family of ipv6 function arguments recently.

Actually, it's already there and done to this very function.

Herbert, this is just an ancient patch that has been superceded
by the very change you are suggestions :-)
