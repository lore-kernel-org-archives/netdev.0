From: Herbert Xu <herbert@gondor.apana.org.au>
Subject: Re: rhashtable: Add cap on number of elements in hash table
Date: Fri, 24 Apr 2015 16:04:01 +0800
Message-ID: <20150424080401.GA29453@gondor.apana.org.au>
References: <1429799923-28122-1-git-send-email-johannes@sipsolutions.net>
 <20150423.115919.1353583175267783165.davem@davemloft.net>
 <20150424005729.GA27075@gondor.apana.org.au>
 <1429858870.1852.7.camel@sipsolutions.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: David Miller <davem@davemloft.net>, netdev@vger.kernel.org,
	kaber@trash.net, tgraf@suug.ch
To: Johannes Berg <johannes@sipsolutions.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from helcar.hengli.com.au ([209.40.204.226]:56812 "EHLO
	helcar.hengli.com.au" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752242AbbDXIEJ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 24 Apr 2015 04:04:09 -0400
Content-Disposition: inline
In-Reply-To: <1429858870.1852.7.camel@sipsolutions.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, Apr 24, 2015 at 09:01:10AM +0200, Johannes Berg wrote:
>
> > As allowing >100% utilisation is potentially dangerous, the name
> > contains the word insecure.
> 
> Not sure I get this. So rhashtable is trying to actually never have
> collisions? How could that possibly work?

Of course it's not to eliminate collisions, but to limit the chain
length to something reasonable.  Using a hashtable at >100% capacity
is usually not reasonable.

> Since you're also doing what I did here, would it make sense to apply my
> patch to net and this one only to net-next?

That would make af_netlink a security hole again because you can now
add unlimited entries to a hash table limited to 64K entries.  Prior
to the rhashtable conversion you weren't allowed to have more than
64K entries in the table.  This was lost in the conversion and I was
trying to restore it.

> For my use case (which was testing/debug) I don't actually care that
> much, but perhaps that'd be an easier sell towards the end of the merge
> window :) It seems that my patch would mostly fix the *issue*, while
> yours actually adds a new parameter that's also not actually used yet.

Well if my patch is too complex then sure we can look at coming up
with a simpler fix but I think we need something that does not let
you add unlimited entries to af_netlink.

Cheers,
-- 
Email: Herbert Xu <herbert@gondor.apana.org.au>
Home Page: http://gondor.apana.org.au/~herbert/
PGP Key: http://gondor.apana.org.au/~herbert/pubkey.txt
