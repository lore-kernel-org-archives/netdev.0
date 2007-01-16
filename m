From: Herbert Xu <herbert@gondor.apana.org.au>
Subject: Re: rare bad TCP checksum with 2.6.19?
Date: Tue, 16 Jan 2007 22:50:53 +1100
Message-ID: <20070116115053.GA16529@gondor.apana.org.au>
References: <E1H6OJU-0001EC-00@gondolin.me.apana.org.au> <45AB82F1.9000409@tls.msk.ru> <20070115201001.GA9510@gondor.apana.org.au> <45ABF620.3070405@tls.msk.ru> <20070116032739.GA12746@gondor.apana.org.au> <20070116033849.GA12856@gondor.apana.org.au> <45AC8813.9000204@tls.msk.ru>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, Patrick McHardy <kaber@trash.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from rhun.apana.org.au ([64.62.148.172]:4911 "EHLO
	arnor.apana.org.au" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1750896AbXAPLvO (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 16 Jan 2007 06:51:14 -0500
To: Michael Tokarev <mjt@tls.msk.ru>
Content-Disposition: inline
In-Reply-To: <45AC8813.9000204@tls.msk.ru>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Tue, Jan 16, 2007 at 11:08:51AM +0300, Michael Tokarev wrote:
> 
> Ok.  Here's another trace, from that remote network that triggers
> this thing more-or-less reliable (every 2nd transfer at least) --
> http://www.corpit.ru/mjt/bh-bad-cksum-dmp.bin . It's a full session
> between 216.168.29.244 - the requesting/receiving side -- and
> 81.13.94.6 -- our sending side (the file being transferred is some
> trojan horse I found on a friend's PC, so be careful ;)

I'll have a look at this tomorrow.

Since you're certain that this is being seen on the wire, one
possibility is that we've got a bug somewhere that's zeroing
skb->ip_summed on a packet with a partial checksum.

One potential spot where this could happen is netfilter.
Patrick, do you know of any recent changes (this is happening
with 2.6.19) that might cause this?

Cheers,
-- 
Visit Openswan at http://www.openswan.org/
Email: Herbert Xu ~{PmV>HI~} <herbert@gondor.apana.org.au>
Home Page: http://gondor.apana.org.au/~herbert/
PGP Key: http://gondor.apana.org.au/~herbert/pubkey.txt
