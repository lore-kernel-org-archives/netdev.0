From: Herbert Xu <herbert@gondor.apana.org.au>
Subject: Re: IPv4/IPv6 sysctl unregistration deadlock
Date: Fri, 27 Feb 2009 08:59:45 +0800
Message-ID: <20090227005945.GB20081@gondor.apana.org.au>
References: <49A4D5D5.5090602@trash.net> <20090225061902.GA32430@gondor.apana.org.au> <49A4E3F8.4050406@trash.net> <49A4F0D7.20304@trash.net> <20090225084321.GA1101@gondor.apana.org.au> <m163ixk9t2.fsf@fess.ebiederm.org> <20090226062257.GA11511@gondor.apana.org.au> <m14oyhis31.fsf@fess.ebiederm.org> <20090226084924.16cb3e08@nehalam>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: "Eric W. Biederman" <ebiederm@xmission.com>,
	Patrick McHardy <kaber@trash.net>,
	Linux Netdev List <netdev@vger.kernel.org>,
	"David S. Miller" <davem@davemloft.net>
To: Stephen Hemminger <shemminger@vyatta.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from rhun.apana.org.au ([64.62.148.172]:42314 "EHLO
	arnor.apana.org.au" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1752634AbZB0A75 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 26 Feb 2009 19:59:57 -0500
Content-Disposition: inline
In-Reply-To: <20090226084924.16cb3e08@nehalam>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, Feb 26, 2009 at 08:49:24AM -0800, Stephen Hemminger wrote:
>
> -	rtnl_lock();
> +	if (!rtnl_trylock())
> +		return -ERESTARTSYS;

This is going to spin instead of sleep on contention, is that
intended?

Cheers,
-- 
Visit Openswan at http://www.openswan.org/
Email: Herbert Xu ~{PmV>HI~} <herbert@gondor.apana.org.au>
Home Page: http://gondor.apana.org.au/~herbert/
PGP Key: http://gondor.apana.org.au/~herbert/pubkey.txt
