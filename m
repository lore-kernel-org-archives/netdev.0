From: Herbert Xu <herbert@gondor.apana.org.au>
Subject: Re: [PATCH 3/4] xfrm: remove policy lock when accessing
	policy->walk.dead
Date: Wed, 31 Mar 2010 21:55:05 +0800
Message-ID: <20100331135505.GC14082@gondor.apana.org.au>
References: <1270030626-16687-1-git-send-email-timo.teras@iki.fi> <1270030626-16687-5-git-send-email-timo.teras@iki.fi> <20100331110345.GC12845@gondor.apana.org.au> <1270040773.26743.12.camel@bigi> <20100331131131.GA13793@gondor.apana.org.au> <20100331132622.GA13908@gondor.apana.org.au> <1270042356.26743.30.camel@bigi> <1270042795.26743.31.camel@bigi>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Timo Teras <timo.teras@iki.fi>, netdev@vger.kernel.org,
	"David S. Miller" <davem@davemloft.net>
To: jamal <hadi@cyberus.ca>
Return-path: <netdev-owner@vger.kernel.org>
Received: from ringil.hengli.com.au ([216.59.3.182]:53494 "EHLO
	arnor.apana.org.au" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S933390Ab0CaNzV (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 31 Mar 2010 09:55:21 -0400
Content-Disposition: inline
In-Reply-To: <1270042795.26743.31.camel@bigi>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, Mar 31, 2010 at 09:39:55AM -0400, jamal wrote:
> 
> This is not realistic today in the presence of selinux policies
> which may reject the flush etc. So we make the sequence become:
> 1) user space -> kernel: flush
> 2) kernel: flush
> 3) kernel -> user space: flush response to originater from #1
> 4) if there were no errors then:
> kernel -> user space: flush event to ALL listeners

Eliding the notification if SELinux says so is fine, but eliding
it because the table is empty is wrong.

The flush did not fail just because the table was empty to begin
with.

Cheers,
-- 
Visit Openswan at http://www.openswan.org/
Email: Herbert Xu ~{PmV>HI~} <herbert@gondor.apana.org.au>
Home Page: http://gondor.apana.org.au/~herbert/
PGP Key: http://gondor.apana.org.au/~herbert/pubkey.txt
