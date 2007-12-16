From: Herbert Xu <herbert@gondor.apana.org.au>
Subject: Re: oops with 2.6.23.1, marvel, software raid, reiserfs and samba
Date: Sun, 16 Dec 2007 19:56:56 +0800
Message-ID: <E1J3s76-000166-00@gondolin.me.apana.org.au>
References: <20071216030516.1562a5d0.akpm@linux-foundation.org>
Cc: jeff@jeffunit.com, linux-kernel@vger.kernel.org,
	netdev@vger.kernel.org, davem@davemloft.net
To: akpm@linux-foundation.org (Andrew Morton)
Return-path: <netdev-owner@vger.kernel.org>
Received: from rhun.apana.org.au ([64.62.148.172]:1645 "EHLO
	arnor.apana.org.au" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1757031AbXLPL5F (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 16 Dec 2007 06:57:05 -0500
In-Reply-To: <20071216030516.1562a5d0.akpm@linux-foundation.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Andrew Morton <akpm@linux-foundation.org> wrote:
>
>> Dec  7 17:20:53 sata_fileserver kernel: Code: 6c 39 df 74 59 8d b6 00 
>> 00 00 00 85 db 74 4f 8b 55 cc 8d 43 20 8b 0a 3b 48 18 0f 88 f4 05 00 
>> 00 89 ce 2b 70 18 8b 83 90 00 00 00 <0f> b6 50 0d 89 d0 83 e0 02 3c 
>> 01 8b 43 50 83 d6 ff 39 c6 0f 82

This means that skb->network_header == NULL so this line crashes:

	if (tcp_hdr(skb)->syn)
		offset--;

> That's a networking crash.  Do the oops traces which you're getting all look
> like this one?

What's spooky is that I just did a google and we've had reports
since 1998 all crashing on exactly the same line in tcp_recvmsg.

Cheers,
-- 
Visit Openswan at http://www.openswan.org/
Email: Herbert Xu ~{PmV>HI~} <herbert@gondor.apana.org.au>
Home Page: http://gondor.apana.org.au/~herbert/
PGP Key: http://gondor.apana.org.au/~herbert/pubkey.txt
