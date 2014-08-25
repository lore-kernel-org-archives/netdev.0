From: Hannes Frederic Sowa <hannes@stressinduktion.org>
Subject: Re: [PATCH 0/2] Add TLS record layer encryption module
Date: Mon, 25 Aug 2014 15:12:50 +0200
Message-ID: <1408972370.8545.12.camel@localhost>
References: <1406626353-23309-1-git-send-email-cristian.stoica@freescale.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: herbert@gondor.apana.org.au, linux-crypto@vger.kernel.org,
	davem@davemloft.net, linux-kernel@vger.kernel.org,
	netdev <netdev@vger.kernel.org>
To: Cristian Stoica <cristian.stoica@freescale.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from out2-smtp.messagingengine.com ([66.111.4.26]:35906 "EHLO
	out2-smtp.messagingengine.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1754486AbaHYNMx (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 25 Aug 2014 09:12:53 -0400
Received: from compute2.internal (compute2.nyi.internal [10.202.2.42])
	by gateway2.nyi.internal (Postfix) with ESMTP id A3DE9206EA
	for <netdev@vger.kernel.org>; Mon, 25 Aug 2014 09:12:52 -0400 (EDT)
In-Reply-To: <1406626353-23309-1-git-send-email-cristian.stoica@freescale.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi,

On Di, 2014-07-29 at 12:32 +0300, Cristian Stoica wrote:
> This set of patches introduces support for TLS 1.0 record layer
> encryption/decryption with a corresponding algorithm called
> tls10(hmac(<hash>),cbc(<cipher>)).
> 
> Similarly to authenc.c on which it is based, this module mixes the base
> algorithms in software to produce an algorithm that does record layer
> encryption and decryption for TLS1.0.
> Any combination of hw and sw base algorithms is possible, but the purpose
> is to take advantage of hardware acceleration for TLS record layer offloading
> when hardware acceleration is present.
> 
> This is a software alternative to forthcoming Freescale caam patches that
> will add support for one-pass hardware-only TLS record layer offloading.
> 
> Performance figures depend largely on several factors including hardware
> support and record layer size. For user-space applications the
> kernel/user-space interface is also important. That said, we have done several
> performance tests using openssl and cryptodev on Freescale QorIQ platforms.
> On P4080, for a single stream of records larger than 512 bytes, the performance
> improved from about 22Mbytes/s to 64Mbytes/s while also reducing CPU load.
> 
> The purpose of this module is to enable TLS kernel offloading on hw platforms
> that have acceleration for AES/SHA1 but do not have direct support for TLS
> record layer.
> 
> (minor dependency on pending patch
>   crypto: testmgr.c: white space fix-ups on test_aead)
> 
> Cristian Stoica (2):
>   crypto: add support for TLS 1.0 record encryption
>   crypto: add TLS 1.0 test vectors for AES-CBC-HMAC-SHA1
> 
>  crypto/Kconfig           |  20 ++
>  crypto/Makefile          |   1 +
>  crypto/authenc.c         |   5 +-
>  crypto/tcrypt.c          |   5 +
>  crypto/testmgr.c         |  41 +++-
>  crypto/testmgr.h         | 217 +++++++++++++++++++
>  crypto/tls.c             | 528 +++++++++++++++++++++++++++++++++++++++++++++++
>  include/crypto/authenc.h |   3 +
>  8 files changed, 808 insertions(+), 12 deletions(-)
>  create mode 100644 crypto/tls.c
> 

Maybe could you add netdev@vger.kernel.org to Cc on your next
submission?

It would be great if this feature would be made available in some way
that user space does TLS handshaking over a socket and symmetric keys
could later be installed via e.g. setsockopt and kernel offloads tls
processing over this socket.

Alert message handling seems problematic, though and might require some
out-of-band interface.

Thanks,
Hannes
