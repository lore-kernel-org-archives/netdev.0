From: Herbert Xu <herbert@gondor.apana.org.au>
Subject: Re: rare bad TCP checksum with 2.6.19?
Date: Tue, 16 Jan 2007 07:10:01 +1100
Message-ID: <20070115201001.GA9510@gondor.apana.org.au>
References: <E1H6OJU-0001EC-00@gondolin.me.apana.org.au> <45AB82F1.9000409@tls.msk.ru>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from rhun.apana.org.au ([64.62.148.172]:1026 "EHLO
	arnor.apana.org.au" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1751454AbXAOUKD (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 15 Jan 2007 15:10:03 -0500
To: Michael Tokarev <mjt@tls.msk.ru>
Content-Disposition: inline
In-Reply-To: <45AB82F1.9000409@tls.msk.ru>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Mon, Jan 15, 2007 at 04:34:41PM +0300, Michael Tokarev wrote:
> 
> # ethtool -k eth0
> Offload parameters for eth0:
> Cannot get device rx csum settings: Operation not supported
> Cannot get device tx csum settings: Operation not supported
> Cannot get device scatter-gather settings: Operation not supported
> Cannot get device tcp segmentation offload settings: Operation not supported
> no offload info available
> 
> # ethtool -K eth0 rx off tx off tso off
> Cannot set device rx csum settings: Operation not supported
> 
> So I guess the problem is not related to hw checksumming offloading.

Nope, it just means that 8139too doesn't provide ethtool handlers to
disable checksum offloading.

So I suggest that you try doing the tcpdump on the receive side as
that should show the real checksum.

BTW, the reason tcpdump only shows some packets with bogus checksums
is because it cuts packets off at 100 bytes by default so for most
packets it can't verify the checksum at all.  If you run it with
-s 1600 you should see bogus checksums on every packet with payload.

Cheers,
-- 
Visit Openswan at http://www.openswan.org/
Email: Herbert Xu ~{PmV>HI~} <herbert@gondor.apana.org.au>
Home Page: http://gondor.apana.org.au/~herbert/
PGP Key: http://gondor.apana.org.au/~herbert/pubkey.txt
