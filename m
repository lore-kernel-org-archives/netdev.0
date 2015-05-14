From: Herbert Xu <herbert@gondor.apana.org.au>
Subject: Re: netlink & rhashtable status
Date: Thu, 14 May 2015 13:03:25 +0800
Message-ID: <20150514050325.GA5754@gondor.apana.org.au>
References: <1431522271.566.132.camel@edumazet-glaptop2.roam.corp.google.com>
 <1431533884.566.148.camel@edumazet-glaptop2.roam.corp.google.com>
 <20150514025333.GA3853@gondor.apana.org.au>
 <1431573463.27831.32.camel@edumazet-glaptop2.roam.corp.google.com>
 <20150514033448.GA5080@gondor.apana.org.au>
 <1431575890.27831.34.camel@edumazet-glaptop2.roam.corp.google.com>
 <1431576818.27831.36.camel@edumazet-glaptop2.roam.corp.google.com>
 <20150514041628.GA5428@gondor.apana.org.au>
 <20150514042151.GA5482@gondor.apana.org.au>
 <1431578321.27831.43.camel@edumazet-glaptop2.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: David Miller <davem@davemloft.net>, Thomas Graf <tgraf@suug.ch>,
	netdev <netdev@vger.kernel.org>
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from helcar.hengli.com.au ([209.40.204.226]:47041 "EHLO
	helcar.hengli.com.au" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751625AbbENFDd (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 14 May 2015 01:03:33 -0400
Content-Disposition: inline
In-Reply-To: <1431578321.27831.43.camel@edumazet-glaptop2.roam.corp.google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, May 13, 2015 at 09:38:41PM -0700, Eric Dumazet wrote:
>
> And only one of the socket is listed twice (ffff881f6eceb000)
> 
> Apparently this is the one _after_ kernel socket.
> 
> Does it ring a bell ?

No that's just a walker bug.  In netlink_seq_next when we come
around the loop after ++i, we fail to refresh the ht pointer so
we walk the previous table again.

This bug was introduced in 3.18:

commit 78fd1d0ab072d4d9b5f0b7c14a1516665170b565
Author: Thomas Graf <tgraf@suug.ch>
Date:   Tue Oct 21 22:05:38 2014 +0200

    netlink: Re-add locking to netlink_lookup() and seq walker

This should have zero impact on functionality though.

Cheers,
-- 
Email: Herbert Xu <herbert@gondor.apana.org.au>
Home Page: http://gondor.apana.org.au/~herbert/
PGP Key: http://gondor.apana.org.au/~herbert/pubkey.txt
