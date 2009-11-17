From: Herbert Xu <herbert@gondor.apana.org.au>
Subject: Re: [RFC] dev->refcnt long term holder
Date: Tue, 17 Nov 2009 16:37:49 +0800
Message-ID: <20091117083748.GA12743@gondor.apana.org.au>
References: <4B019381.2010509@gmail.com> <20091116110207.08b60c81@nehalam> <4B01ADF5.8090904@gmail.com> <20091117.003019.196504832.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: eric.dumazet@gmail.com, shemminger@vyatta.com,
	netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from rhun.apana.org.au ([64.62.148.172]:35798 "EHLO
	arnor.apana.org.au" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1753794AbZKQIht (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 17 Nov 2009 03:37:49 -0500
Content-Disposition: inline
In-Reply-To: <20091117.003019.196504832.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, Nov 17, 2009 at 12:30:19AM -0800, David Miller wrote:
> 
> 1) PHY events in most drivers are handled in softirq (NAPI ->poll())
>    or a workqueue of some sort these days.  If we can make all of
>    the link state management softirq safe (it probably is, except
>    for perhaps RTNL), these case can be done synchronously always.

I think one of the reasons it's done this way is to call the function
netdev_state_change which needs to be in process context to walk
through the notifier list and do all the calls.

Cheers,
-- 
Visit Openswan at http://www.openswan.org/
Email: Herbert Xu ~{PmV>HI~} <herbert@gondor.apana.org.au>
Home Page: http://gondor.apana.org.au/~herbert/
PGP Key: http://gondor.apana.org.au/~herbert/pubkey.txt
