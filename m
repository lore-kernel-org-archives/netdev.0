From: Herbert Xu <herbert@gondor.apana.org.au>
Subject: Re: [PATCH 1/4] sctp: Fix crc32c calculations on big-endian arhes.
Date: Fri, 23 Jan 2009 16:28:49 +1100
Message-ID: <20090123052849.GA25937@gondor.apana.org.au>
References: <1232663768-4028-2-git-send-email-vladislav.yasevich@hp.com> <20090123051956.GA25803@gondor.apana.org.au>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, linux-sctp@vger.kernel.org,
	davem@davemloft.net
To: Vlad Yasevich <vladislav.yasevich@hp.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from rhun.apana.org.au ([64.62.148.172]:58090 "EHLO
	arnor.apana.org.au" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1750793AbZAWF2x (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 23 Jan 2009 00:28:53 -0500
Content-Disposition: inline
In-Reply-To: <20090123051956.GA25803@gondor.apana.org.au>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, Jan 23, 2009 at 04:19:56PM +1100, Herbert Xu wrote:
> Vlad Yasevich <vladislav.yasevich@hp.com> wrote:
> >
> > diff --git a/include/net/sctp/checksum.h b/include/net/sctp/checksum.h
> > index b799fb2..2fec3c3 100644
> > --- a/include/net/sctp/checksum.h
> > +++ b/include/net/sctp/checksum.h
> > @@ -79,5 +79,5 @@ static inline __be32 sctp_update_cksum(__u8 *buffer, __u16 length, __be32 crc32)
> > 
> > static inline __be32 sctp_end_cksum(__be32 crc32)
> > {
> > -       return ~crc32;
> > +       return (__force __be32)~cpu_to_le32((__force u32)crc32);
> > }
> 
> Ouch, surely there is a better way to do this?

In fact this looks wrong.  Has this code actually been tested
on big-endian?

Cheers,
-- 
Visit Openswan at http://www.openswan.org/
Email: Herbert Xu ~{PmV>HI~} <herbert@gondor.apana.org.au>
Home Page: http://gondor.apana.org.au/~herbert/
PGP Key: http://gondor.apana.org.au/~herbert/pubkey.txt
