From: Alexey Dobriyan <adobriyan@gmail.com>
Subject: Re: [PATCH] Fix ESP SA loading (by default)
Date: Sat, 1 Nov 2008 14:38:35 +0300
Message-ID: <20081101113835.GA3127@x200.localdomain>
References: <20081101043737.GA1621@x200.localdomain> <20081101050458.GA17807@gondor.apana.org.au>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: davem@davemloft.net, netdev@vger.kernel.org
To: Herbert Xu <herbert@gondor.apana.org.au>
Return-path: <netdev-owner@vger.kernel.org>
Received: from ik-out-1112.google.com ([66.249.90.183]:42503 "EHLO
	ik-out-1112.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751348AbYKALfY (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 1 Nov 2008 07:35:24 -0400
Received: by ik-out-1112.google.com with SMTP id c29so531213ika.5
        for <netdev@vger.kernel.org>; Sat, 01 Nov 2008 04:35:22 -0700 (PDT)
Content-Disposition: inline
In-Reply-To: <20081101050458.GA17807@gondor.apana.org.au>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sat, Nov 01, 2008 at 01:04:58PM +0800, Herbert Xu wrote:
> On Sat, Nov 01, 2008 at 07:37:37AM +0300, Alexey Dobriyan wrote:
> > digest_null algorithm is now mandatory for ESP.
> > 
> > Steps to reproduce:
> > 
> > 	kernel with CONFIG_CRYPTO_NULL=n
> > 
> > 	#!/usr/sbin/setkey -f
> > 	flush;
> > 	spdflush;
> > 	add 192.168.0.1 192.168.0.42 esp 15701 -E 3des-cbc "123456789012123456789012";
> 
> You do realise that this is totally insecure against man-in-the-
> middle attacks, right?

It's a cut down example. This won't work either:

#!/usr/sbin/setkey -f
flush;
spdflush;

add 192.168.0.1 192.168.0.42 ah 15700 -A hmac-md5 "1234567890123456";
add 192.168.0.1 192.168.0.42 esp 15701 -E 3des-cbc "123456789012123456789012";

add 192.168.0.42 192.168.0.1 ah 24500 -A hmac-md5 "1234567890123456";
add 192.168.0.42 192.168.0.1 esp 24501 -E 3des-cbc "123456789012123456789012";

spdadd 192.168.0.42 192.168.0.1 any -P out ipsec
	esp/transport//require
	ah/transport//require;

spdadd 192.168.0.1 192.168.0.42 any -P in ipsec
	esp/transport//require
	ah/transport//require;
