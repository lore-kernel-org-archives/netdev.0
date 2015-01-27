From: David Laight <David.Laight@ACULAB.COM>
Subject: RE: [PATCH 1/2] rhashtable: Introduce rhashtable_walk_*
Date: Tue, 27 Jan 2015 10:09:18 +0000
Message-ID: <063D6719AE5E284EB5DD2968C1650D6D1CAD3B6C@AcuExch.aculab.com>
References: <20150125232040.GA17936@gondor.apana.org.au>
 <E1YFWUl-0004gE-SH@gondolin.me.apana.org.au>
 <063D6719AE5E284EB5DD2968C1650D6D1CAD2C12@AcuExch.aculab.com>
 <20150126222259.GC30116@gondor.apana.org.au>
Mime-Version: 1.0
Content-Type: text/plain; charset="Windows-1252"
Content-Transfer-Encoding: 8BIT
Cc: Thomas Graf <tgraf@suug.ch>, Ying Xue <ying.xue@windriver.com>,
	"davem@davemloft.net" <davem@davemloft.net>,
	"kaber@trash.net" <kaber@trash.net>,
	"paulmck@linux.vnet.ibm.com" <paulmck@linux.vnet.ibm.com>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"netfilter-devel@vger.kernel.org" <netfilter-devel@vger.kernel.org>
To: 'Herbert Xu' <herbert@gondor.apana.org.au>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp-out6.electric.net ([192.162.217.187]:61287 "EHLO
	smtp-out6.electric.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754560AbbA0KJe convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 27 Jan 2015 05:09:34 -0500
In-Reply-To: <20150126222259.GC30116@gondor.apana.org.au>
Content-Language: en-US
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Herbert Xu 
> On Mon, Jan 26, 2015 at 10:09:24AM +0000, David Laight wrote:
> >
> > That doesn't look right to me.
> > Surely you shouldn't be calling rcu_read_lock() when the mutex
> > request is interrupted.
> >
> > So maybe:
> > 	err = mutex_lock_interruptible(&ht->mutex);
> > 	if (err)
> > 		return err;
> > 	rcu_read_lock();
> 
> No, we need to grab the RCU read lock while holding the mutex
> in order to prevent future resizes from happening once we release
> the mutex.

But if err is non-zero you don't hold the mutex.
Presumably the calling code also errors out immediately,
so the RCU lock isn't needed at all.

	David
