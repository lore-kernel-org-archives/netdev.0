From: Herbert Xu <herbert@gondor.apana.org.au>
Subject: Re: IPv4/IPv6 sysctl unregistration deadlock
Date: Thu, 26 Feb 2009 14:22:57 +0800
Message-ID: <20090226062257.GA11511@gondor.apana.org.au>
References: <49A4D5D5.5090602@trash.net> <20090225061902.GA32430@gondor.apana.org.au> <49A4E3F8.4050406@trash.net> <49A4F0D7.20304@trash.net> <20090225084321.GA1101@gondor.apana.org.au> <m163ixk9t2.fsf@fess.ebiederm.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Patrick McHardy <kaber@trash.net>,
	Linux Netdev List <netdev@vger.kernel.org>,
	"David S. Miller" <davem@davemloft.net>
To: "Eric W. Biederman" <ebiederm@xmission.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from rhun.apana.org.au ([64.62.148.172]:56325 "EHLO
	arnor.apana.org.au" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1750836AbZBZGXI (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 26 Feb 2009 01:23:08 -0500
Content-Disposition: inline
In-Reply-To: <m163ixk9t2.fsf@fess.ebiederm.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, Feb 25, 2009 at 10:10:33PM -0800, Eric W. Biederman wrote:
>
> How does adding a rename operation to sysctl sound?

Yes that would definitely help.  Of course for the unregister case
we'd still need either an async removal or a no-op as Patrick
suggested.

> I am a little concerned that if we have this issue with sysctl
> we also have it with proc and sysfs as well.

Indeed.  /proc should be OK because it's all read-only so we don't
take the RTNL anywhere.  But sysfs may well have the same issue.

I think we should watch out for any more attempts at adding
netdev name-based sysfs nodes and nip them in the bud.

Thanks,
-- 
Visit Openswan at http://www.openswan.org/
Email: Herbert Xu ~{PmV>HI~} <herbert@gondor.apana.org.au>
Home Page: http://gondor.apana.org.au/~herbert/
PGP Key: http://gondor.apana.org.au/~herbert/pubkey.txt
