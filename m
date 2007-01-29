From: Herbert Xu <herbert@gondor.apana.org.au>
Subject: Re: [PATCH 2/3] Seperate DSACK from SACK fast path
Date: Mon, 29 Jan 2007 16:06:07 +1100
Message-ID: <E1HBOiV-0007bt-00@gondolin.me.apana.org.au>
References: <20070128052704.GH22455@galon.ev-en.org>
Cc: davem@davemloft.net, netdev@vger.kernel.org
To: baruch@ev-en.org (Baruch Even)
Return-path: <netdev-owner@vger.kernel.org>
Received: from rhun.apana.org.au ([64.62.148.172]:3580 "EHLO
	arnor.apana.org.au" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S933127AbXA2FG6 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 29 Jan 2007 00:06:58 -0500
In-Reply-To: <20070128052704.GH22455@galon.ev-en.org>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Baruch Even <baruch@ev-en.org> wrote:
>> 
>> > Since the SACK receive cache doesn't need the data to be in host
>> > order we also remove the ntohl in the checking loop.
>>  ...
>> > -   for (i = 0; i< num_sacks; i++) {
>> > -           __u32 start_seq = ntohl(sp[i].start_seq);
>> > -           __u32 end_seq =  ntohl(sp[i].end_seq);
>> > +   for (i = 0; i < num_sacks; i++) {
>> > +           __u32 start_seq = sp[i].start_seq;
>> > +           __u32 end_seq = sp[i].end_seq;
> 
> Yes. The only comparison we do with recv_sack_cache entries is != and
> that works for net-endian just fine.

In that case you need to use __be32 before Al Viro starts coming after
you :)
-- 
Visit Openswan at http://www.openswan.org/
Email: Herbert Xu ~{PmV>HI~} <herbert@gondor.apana.org.au>
Home Page: http://gondor.apana.org.au/~herbert/
PGP Key: http://gondor.apana.org.au/~herbert/pubkey.txt
