From: Herbert Xu <herbert@gondor.apana.org.au>
Subject: Re: [PATCH 1/3 net-next] rhashtable: Avoid calculating hash again to
 unlock
Date: Sat, 14 Mar 2015 13:20:02 +1100
Message-ID: <20150314022002.GA10086@gondor.apana.org.au>
References: <cover.1426257747.git.tgraf@suug.ch>
 <533e5f99a1fc96e557baf4322bda126530236862.1426257747.git.tgraf@suug.ch>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: davem@davemloft.net, netdev@vger.kernel.org, daniel@iogearbox.net
To: Thomas Graf <tgraf@suug.ch>
Return-path: <netdev-owner@vger.kernel.org>
Received: from ringil.hengli.com.au ([178.18.16.133]:33074 "EHLO
	ringil.hengli.com.au" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751353AbbCNCUN (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 13 Mar 2015 22:20:13 -0400
Content-Disposition: inline
In-Reply-To: <533e5f99a1fc96e557baf4322bda126530236862.1426257747.git.tgraf@suug.ch>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, Mar 13, 2015 at 03:45:19PM +0100, Thomas Graf wrote:
> Caching the lock pointer avoids having to hash on the object
> again to unlock the bucket locks.
> 
> Signed-off-by: Thomas Graf <tgraf@suug.ch>

Looks good to me.  I originally avoided doing this because I
thought I had to hold every bucket lock from the first table to
the last with multiple rehashing.  However, my new scheme only
requires the "first" table and the last table to be locked so
caching it is fine.

Cheers,
-- 
Email: Herbert Xu <herbert@gondor.apana.org.au>
Home Page: http://gondor.apana.org.au/~herbert/
PGP Key: http://gondor.apana.org.au/~herbert/pubkey.txt
