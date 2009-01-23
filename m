From: Herbert Xu <herbert@gondor.apana.org.au>
Subject: Re: [PATCH 1/4] sctp: Fix crc32c calculations on big-endian arhes.
Date: Sat, 24 Jan 2009 09:17:15 +1100
Message-ID: <20090123221715.GC806@gondor.apana.org.au>
References: <1232663768-4028-2-git-send-email-vladislav.yasevich@hp.com> <20090123051956.GA25803@gondor.apana.org.au> <20090123052849.GA25937@gondor.apana.org.au> <20090123092449.GA27399@gondor.apana.org.au> <4979D9BC.5000609@hp.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, linux-sctp@vger.kernel.org,
	davem@davemloft.net
To: Vlad Yasevich <vladislav.yasevich@hp.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from rhun.apana.org.au ([64.62.148.172]:57662 "EHLO
	arnor.apana.org.au" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1756640AbZAWWRU (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 23 Jan 2009 17:17:20 -0500
Content-Disposition: inline
In-Reply-To: <4979D9BC.5000609@hp.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, Jan 23, 2009 at 09:52:44AM -0500, Vlad Yasevich wrote:
>
> I'll give it some thought.  It would clean up all the __force
> casts, but it will be a little misleading to define a packet
> checksum as little endian. :)

Not at all! Just because something is on the network doesn't
mean that it's big-endian.  In this case, we're using the little-
endian CRC32C implementation for the checksum so it makes perfect
sense for it to be marked as __le32.

Network-order just has to be fixed in endian, i.e., either big
or small, you just need to stick with the one you choose regardless
of the endianness of the host.

Cheers,
-- 
Visit Openswan at http://www.openswan.org/
Email: Herbert Xu ~{PmV>HI~} <herbert@gondor.apana.org.au>
Home Page: http://gondor.apana.org.au/~herbert/
PGP Key: http://gondor.apana.org.au/~herbert/pubkey.txt
