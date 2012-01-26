From: Herbert Xu <herbert@gondor.apana.org.au>
Subject: Re: [PATCH 4/3] sha512: reduce stack usage even on i386
Date: Thu, 26 Jan 2012 13:35:02 +1100
Message-ID: <20120126023502.GA10696@gondor.apana.org.au>
References: <AE90C24D6B3A694183C094C60CF0A2F6D8AF43@saturn3.aculab.com> <1326709382.2255.4.camel@edumazet-HP-Compaq-6005-Pro-SFF-PC> <CACVxJT_cZAdxNOFTpK5seUXFZU+YB3zbe6LF1nnyzo32ae14xw@mail.gmail.com> <20120118180210.GA22733@p183.telecom.by>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: David Laight <David.Laight@aculab.com>,
	Linus Torvalds <torvalds@linux-foundation.org>,
	linux-crypto@vger.kernel.org, netdev@vger.kernel.org,
	ken@codelabs.ch, Steffen Klassert <steffen.klassert@secunet.com>,
	security@kernel.org, Eric Dumazet <eric.dumazet@gmail.com>
To: Alexey Dobriyan <adobriyan@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from helcar.apana.org.au ([209.40.204.226]:36577 "EHLO
	fornost.hengli.com.au" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751356Ab2AZCfR (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 25 Jan 2012 21:35:17 -0500
Content-Disposition: inline
In-Reply-To: <20120118180210.GA22733@p183.telecom.by>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, Jan 18, 2012 at 09:02:10PM +0300, Alexey Dobriyan wrote:
> Fix still excessive stack usage on i386.
> 
> There is too much loop unrolling going on, despite W[16] being used,
> gcc screws up this for some reason. So, don't be smart, use simple code
> from SHA-512 definition, this keeps code size _and_ stack usage back
> under control even on i386:
> 
> 	-14b:   81 ec 9c 03 00 00       sub    $0x39c,%esp
> 	+149:   81 ec 64 01 00 00       sub    $0x164,%esp
> 
> 	$ size ../sha512_generic-i386-00*
> 	   text    data     bss     dec     hex filename
> 	  15521     712       0   16233    3f69 ../sha512_generic-i386-000.o
> 	   4225     712       0    4937    1349 ../sha512_generic-i386-001.o
> 
> Signed-off-by: Alexey Dobriyan <adobriyan@gmail.com>
> Cc: stable@vger.kernel.org

Hmm, your patch doesn't apply against my crypto tree.  Please
regenerate.

Thanks,
-- 
Email: Herbert Xu <herbert@gondor.apana.org.au>
Home Page: http://gondor.apana.org.au/~herbert/
PGP Key: http://gondor.apana.org.au/~herbert/pubkey.txt
