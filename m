From: Herbert Xu <herbert@gondor.apana.org.au>
Subject: Re: rare bad TCP checksum with 2.6.19?
Date: Tue, 16 Jan 2007 14:38:49 +1100
Message-ID: <20070116033849.GA12856@gondor.apana.org.au>
References: <E1H6OJU-0001EC-00@gondolin.me.apana.org.au> <45AB82F1.9000409@tls.msk.ru> <20070115201001.GA9510@gondor.apana.org.au> <45ABF620.3070405@tls.msk.ru> <20070116032739.GA12746@gondor.apana.org.au>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from rhun.apana.org.au ([64.62.148.172]:3133 "EHLO
	arnor.apana.org.au" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S932175AbXAPDiw (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 15 Jan 2007 22:38:52 -0500
To: Michael Tokarev <mjt@tls.msk.ru>
Content-Disposition: inline
In-Reply-To: <20070116032739.GA12746@gondor.apana.org.au>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Tue, Jan 16, 2007 at 02:27:39PM +1100, Herbert Xu wrote:
> 
> I'm sorry but this dump does NOT look like it was taken from an
> intermediate box.  I verified two bad checksums (chosen randomly)
> and they were both correct but partial checksums.  This means that
> this dump was most likely taken from the sending host.

I did see one strange bit:

02:39:51.758803 IP (tos 0x0, ttl  63, id 41084, offset 0, flags [DF], length: 102) 192.168.1.1.25 > 81.13.94.6.21350: FP [bad tcp cksum 81b0 (->9ee8)!] 4271854025:4271
854075(50) ack 3772789166 win 272 <nop,nop,timestamp 145420525 6279830>
        0x0000:  4500 0066 a07c 4000 3f06 2a59 c0a8 0101  E..f.|@.?.*Y....
        0x0010:  510d 5e06 0019 5366 fe9f 51c9 e0e0 31ae  Q.^...Sf..Q...1.
        0x0020:  8019 0110 81b0 0000 0101 080a 08aa f0ed  ................
        0x0030:  005f d296 3235 3020 322e 302e 3020 4f6b  ._..250.2.0.0.Ok
        0x0040:  3a20 7175 6575 6564 2061 7320 3631 3345  :.queued.as.613E
        0x0050:  4137 4637 440d 0a32 3231 2032 2e30 2e30  A7F7D..221.2.0.0
        0x0060:  2042 7965 0d0a                           .Bye..

Most of the bad checksums are from 81.13.94.6, which I presume is
the host you were dumping on.  However, this packet is destined
for it instead and yet it too has a partial (but correct) checksum.

So the question is where in your network is 192.168.1.1 and how is
your network setup in terms of NAT?

Cheers,
-- 
Visit Openswan at http://www.openswan.org/
Email: Herbert Xu ~{PmV>HI~} <herbert@gondor.apana.org.au>
Home Page: http://gondor.apana.org.au/~herbert/
PGP Key: http://gondor.apana.org.au/~herbert/pubkey.txt
