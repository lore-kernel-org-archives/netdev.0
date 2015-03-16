From: Herbert Xu <herbert@gondor.apana.org.au>
Subject: Re: [v1 PATCH 0/14] rhashtable: Kill shift/Key netlink
 namespace/Merge jhash
Date: Mon, 16 Mar 2015 15:33:59 +1100
Message-ID: <20150316043359.GA29124@gondor.apana.org.au>
References: <20150315104306.GA21999@gondor.apana.org.au>
 <20150316.000113.1803291537029624713.davem@davemloft.net>
 <20150316041805.GA28946@gondor.apana.org.au>
 <20150316.003049.1368221798557474722.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: tgraf@suug.ch, netdev@vger.kernel.org, eric.dumazet@gmail.com
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from ringil.hengli.com.au ([178.18.16.133]:57816 "EHLO
	ringil.hengli.com.au" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750899AbbCPEeD (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 16 Mar 2015 00:34:03 -0400
Content-Disposition: inline
In-Reply-To: <20150316.003049.1368221798557474722.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, Mar 16, 2015 at 12:30:49AM -0400, David Miller wrote:
>
> > Well if everybody used jhash the indirect call would go away...
> 
> The other issue is that some hashes are per-ns and thus don't
> need the namespace hash and comparison, whilst others do.

That's just a matter of what goes into the key.  IOW if your
table is global then you include the namespace in the hash,
otherwise you don't.  It shouldn't change the hash function.

Have a look at what I did to netlink in patch 9.  If you wanted
a per-namespace hash table it is as simple as getting rid of
obj_hashfn and just reducing the key to have just the portid.

Cheers,
-- 
Email: Herbert Xu <herbert@gondor.apana.org.au>
Home Page: http://gondor.apana.org.au/~herbert/
PGP Key: http://gondor.apana.org.au/~herbert/pubkey.txt
