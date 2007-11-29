From: Herbert Xu <herbert@gondor.apana.org.au>
Subject: Re: [PATCH] Fix inet_diag.ko register vs rcv race
Date: Thu, 29 Nov 2007 23:37:34 +1100
Message-ID: <20071129123733.GC30420@gondor.apana.org.au>
References: <474C1717.4040607@openvz.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Arnaldo Carvalho de Melo <acme@redhat.com>,
	Linux Netdev List <netdev@vger.kernel.org>, devel@openvz.org
To: Pavel Emelyanov <xemul@openvz.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from rhun.apana.org.au ([64.62.148.172]:3127 "EHLO
	arnor.apana.org.au" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1754230AbXK2Mhh (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 29 Nov 2007 07:37:37 -0500
Content-Disposition: inline
In-Reply-To: <474C1717.4040607@openvz.org>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Tue, Nov 27, 2007 at 04:09:43PM +0300, Pavel Emelyanov wrote:
> The following race is possible when one cpu unregisters the handler
> while other one is trying to receive a message and call this one:

Good catch! But I think we need a bit more to close this fully.

Dumps can resume asynchronously which means that they won't be
holding inet_diag_mutex.  We can fix that pretty easily by
giving that as our cb_mutex.

So could you add that to your patch and resubmit?

Arnaldo, synchronize_rcu() doesn't work on its own.  Whoever accesses
the object that it's supposed to protect has to use the correct RCU
primitives for this to work.

Synchronisation is like tango, it always takes two to make it work :)

Thanks,
-- 
Visit Openswan at http://www.openswan.org/
Email: Herbert Xu ~{PmV>HI~} <herbert@gondor.apana.org.au>
Home Page: http://gondor.apana.org.au/~herbert/
PGP Key: http://gondor.apana.org.au/~herbert/pubkey.txt
