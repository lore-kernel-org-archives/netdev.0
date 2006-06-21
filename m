From: Herbert Xu <herbert@gondor.apana.org.au>
Subject: Re: Locking validator output on DCCP
Date: Wed, 21 Jun 2006 10:34:13 +1000
Message-ID: <20060621003413.GA31915@gondor.apana.org.au>
References: <5640c7e00606201640wa1ad17fl46a32ceb49513867@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev <netdev@vger.kernel.org>,
	DCCP Mailing List <dccp@vger.kernel.org>,
	Arnaldo Carvalho de Melo <arnaldo.melo@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from rhun.apana.org.au ([64.62.148.172]:60684 "EHLO
	arnor.apana.org.au") by vger.kernel.org with ESMTP id S932216AbWFUAe1
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 20 Jun 2006 20:34:27 -0400
To: Ian McDonald <ian.mcdonald@jandi.co.nz>,
	Ingo Molnar <mingo@elte.hu>
Content-Disposition: inline
In-Reply-To: <5640c7e00606201640wa1ad17fl46a32ceb49513867@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Tue, Jun 20, 2006 at 11:40:05PM +0000, Ian McDonald wrote:
> 
> I am getting this when I am using DCCP with 2.6.17-rc6-mm2 with Ingo's
> lock dependency patch:
> 
> Jun 21 09:38:58 localhost kernel: [  102.068588]
> Jun 21 09:38:58 localhost kernel: [  102.068592]
> =============================================
> Jun 21 09:38:58 localhost kernel: [  102.068602] [ INFO: possible
> recursive locking detected ]
> Jun 21 09:38:58 localhost kernel: [  102.068608]
> ---------------------------------------------
> Jun 21 09:38:58 localhost kernel: [  102.068615] idle/0 is trying to
> acquire lock:
> Jun 21 09:38:58 localhost kernel: [  102.068620]
> (&sk->sk_lock.slock#3){-+..}, at: [<c0245511>] sk_clone+0x5a/0x190
> Jun 21 09:38:58 localhost kernel: [  102.068644]
> Jun 21 09:38:58 localhost kernel: [  102.068646] but task is already
> holding lock:
> Jun 21 09:38:58 localhost kernel: [  102.068651]
> (&sk->sk_lock.slock#3){-+..}, at: [<c024650d>]
> sk_receive_skb+0xe6/0xfe

...
 
> As I read this it is not a recursive lock as sk_clone is occurring
> second and is actually creating a new socket so they are trying to
> lock on different sockets.
> 
> Can someone tell me whether I am correct in my thinking or not? If I
> am then I will work out how to tell the lock validator not to worry
> about it.

I agree, this looks bogus.  Ingo, could you please take a look?

Thanks,
-- 
Visit Openswan at http://www.openswan.org/
Email: Herbert Xu ~{PmV>HI~} <herbert@gondor.apana.org.au>
Home Page: http://gondor.apana.org.au/~herbert/
PGP Key: http://gondor.apana.org.au/~herbert/pubkey.txt
