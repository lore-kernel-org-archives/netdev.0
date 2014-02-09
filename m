From: Herbert Xu <herbert@gondor.apana.org.au>
Subject: Re: Question about skb_segment()
Date: Sun, 9 Feb 2014 10:42:09 +0800
Message-ID: <20140209024209.GA17395@gondor.apana.org.au>
References: <87fvo71a0m.fsf@natisbad.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: David Miller <davem@davemloft.net>,
	Eric Dumazet <edumazet@google.com>, Willy Tarreau <w@1wt.eu>,
	netdev@vger.kernel.org
To: Arnaud Ebalard <arno@natisbad.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from ringil.hengli.com.au ([178.18.16.133]:50056 "EHLO
	ringil.hengli.com.au" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751290AbaBICmX (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 8 Feb 2014 21:42:23 -0500
Content-Disposition: inline
In-Reply-To: <87fvo71a0m.fsf@natisbad.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, Jan 29, 2014 at 09:12:57AM +0100, Arnaud Ebalard wrote:
> Hi Herbert,
> 
> I wonder if you could share some knowledge on the behaviour of
> skb_segment() as it is implemented in 3.13.0: when passed a GSO
> packet to be segmented, can the skb result have skb->next == NULL?
> 
> One would expect the number of segments of the result to usually match
> tcp_skb_pcount() of passed packet and hence having skb->next != NULL: 
> AFAICT, this what usually happens when skb_segment() is called in
> tcp_gso_segment() but I noticed some cases where the number of segments
> (length of chained sk_buff) is lower than the expected value and also
> have two backtraces resulting from a skb delivered with a NULL skb->next. 

Hi Arnaud:

This is definitely not expected.  You said that the crash is not
easily reproducible.  Are you able to easily reproduce the problem
where the number of segments produced is less than what is expected?

Can you print out the size of the segments produced in that case?

Thanks!
-- 
Email: Herbert Xu <herbert@gondor.apana.org.au>
Home Page: http://gondor.apana.org.au/~herbert/
PGP Key: http://gondor.apana.org.au/~herbert/pubkey.txt
