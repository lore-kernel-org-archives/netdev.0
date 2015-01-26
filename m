From: Herbert Xu <herbert@gondor.apana.org.au>
Subject: Re: [PATCH 1/2] rhashtable: Introduce rhashtable_walk_*
Date: Tue, 27 Jan 2015 09:23:00 +1100
Message-ID: <20150126222259.GC30116@gondor.apana.org.au>
References: <20150125232040.GA17936@gondor.apana.org.au>
 <E1YFWUl-0004gE-SH@gondolin.me.apana.org.au>
 <063D6719AE5E284EB5DD2968C1650D6D1CAD2C12@AcuExch.aculab.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Thomas Graf <tgraf@suug.ch>, Ying Xue <ying.xue@windriver.com>,
	"davem@davemloft.net" <davem@davemloft.net>,
	"kaber@trash.net" <kaber@trash.net>,
	"paulmck@linux.vnet.ibm.com" <paulmck@linux.vnet.ibm.com>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"netfilter-devel@vger.kernel.org" <netfilter-devel@vger.kernel.org>
To: David Laight <David.Laight@ACULAB.COM>
Return-path: <netdev-owner@vger.kernel.org>
Received: from helcar.apana.org.au ([209.40.204.226]:48822 "EHLO
	helcar.apana.org.au" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755187AbbAZWXf (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 26 Jan 2015 17:23:35 -0500
Content-Disposition: inline
In-Reply-To: <063D6719AE5E284EB5DD2968C1650D6D1CAD2C12@AcuExch.aculab.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, Jan 26, 2015 at 10:09:24AM +0000, David Laight wrote:
>
> That doesn't look right to me.
> Surely you shouldn't be calling rcu_read_lock() when the mutex
> request is interrupted.
> 
> So maybe:
> 	err = mutex_lock_interruptible(&ht->mutex);
> 	if (err)
> 		return err;
> 	rcu_read_lock();

No, we need to grab the RCU read lock while holding the mutex
in order to prevent future resizes from happening once we release
the mutex.

We don't want to hold the mutex which would stop other walks from
starting.

Cheers,
-- 
Email: Herbert Xu <herbert@gondor.apana.org.au>
Home Page: http://gondor.apana.org.au/~herbert/
PGP Key: http://gondor.apana.org.au/~herbert/pubkey.txt
