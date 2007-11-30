From: Herbert Xu <herbert@gondor.apana.org.au>
Subject: Re: [Bugme-new] [Bug 9440] New: Problem in joinning a socket to ipv6 multicast address in specific scenario
Date: Fri, 30 Nov 2007 23:02:19 +1100
Message-ID: <20071130120219.GA26848@gondor.apana.org.au>
References: <bug-9440-10286@http.bugzilla.kernel.org/> <20071122172342.721ee232.akpm@linux-foundation.org> <20071123105924.GB22062@2ka.mipt.ru> <20071128111814.GA10246@2ka.mipt.ru>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Andrew Morton <akpm@linux-foundation.org>, netdev@vger.kernel.org,
	bugme-daemon@bugzilla.kernel.org, aviad.yehezkel5@gmail.com,
	YOSHIFUJI Hideaki <yoshfuji@linux-ipv6.org>
To: Evgeniy Polyakov <johnpol@2ka.mipt.ru>
Return-path: <netdev-owner@vger.kernel.org>
Received: from rhun.apana.org.au ([64.62.148.172]:3639 "EHLO
	arnor.apana.org.au" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1755294AbXK3MCh (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 30 Nov 2007 07:02:37 -0500
Content-Disposition: inline
In-Reply-To: <20071128111814.GA10246@2ka.mipt.ru>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Wed, Nov 28, 2007 at 02:18:14PM +0300, Evgeniy Polyakov wrote:
> Hi.
> 
> Avaid provided test application, so bug got fixed.
> 
> IPv6 addrconf removes ipv6 inner device from netdev each time cmu
> changes and new value is less than IPV6_MIN_MTU (1280 bytes).
> When mtu is changed and new value is greater than IPV6_MIN_MTU,
> it does not add ipv6 addresses and inner device bac.
> 
> This patch fixes that.
> 
> Tested with Avaid's application, which works ok now.
> 
> Signed-off-by: Evgeniy Polyakov <johnpol@2ka.mipt.ru>

OK, this looks like a good change.  However, we should also
change NETDEV_UP as well to recreate idev if it isn't there
and the MTU is big enough.

Thanks,
-- 
Visit Openswan at http://www.openswan.org/
Email: Herbert Xu ~{PmV>HI~} <herbert@gondor.apana.org.au>
Home Page: http://gondor.apana.org.au/~herbert/
PGP Key: http://gondor.apana.org.au/~herbert/pubkey.txt
