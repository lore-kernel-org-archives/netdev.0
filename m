From: Herbert Xu <herbert@gondor.apana.org.au>
Subject: Re: kernel BUG at net/core/skbuff.c in linux-2.6.21-rc6
Date: Thu, 19 Apr 2007 21:41:32 +1000
Message-ID: <E1HeV12-0002IS-00@gondolin.me.apana.org.au>
References: <E1HeHoZ-0000Y6-00@gondolin.me.apana.org.au>
Cc: paulus@samba.org, davem@davemloft.net, kaber@trash.net,
	poemann@gmail.com, linux-kernel@vger.kernel.org,
	netdev@vger.kernel.org
To: herbert@gondor.apana.org.au (Herbert Xu)
Return-path: <netdev-owner@vger.kernel.org>
Received: from rhun.apana.org.au ([64.62.148.172]:1102 "EHLO
	arnor.apana.org.au" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S2993231AbXDSLlw (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 19 Apr 2007 07:41:52 -0400
In-Reply-To: <E1HeHoZ-0000Y6-00@gondolin.me.apana.org.au>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Herbert Xu <herbert@gondor.apana.org.au> wrote:
> 
> Paul Mackerras <paulus@samba.org> wrote:
>> 
>> So this doesn't change process_input_packet(), which treats the case
>> where the first byte is 0xff (PPP_ALLSTATIONS) but the second byte is
>> 0x03 (PPP_UI) as indicating a packet with a PPP protocol number of
>> 0xff.  Arguably that's wrong since PPP protocol 0xff is reserved, and
>> the RFC does envision the possibility of receiving frames where the
>> control field has values other than 0x03.
> 
> Your fix is probably needed too.  However, I think the issue that Patrick
> was trying to fix is the case where p[0] != PPP_ALLSTATIONS and therefore
> we'd still have a problem there.

Nevermind, I mixed up != with == so your patch is all we need.

Thanks,
-- 
Visit Openswan at http://www.openswan.org/
Email: Herbert Xu ~{PmV>HI~} <herbert@gondor.apana.org.au>
Home Page: http://gondor.apana.org.au/~herbert/
PGP Key: http://gondor.apana.org.au/~herbert/pubkey.txt
