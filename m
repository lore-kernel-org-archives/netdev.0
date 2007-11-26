From: "Ian Brown" <ianbrn@gmail.com>
Subject: Re: DST_NOHASH flag and IPsec transformers routing tables - need some clarification
Date: Mon, 26 Nov 2007 15:15:43 +0200
Message-ID: <d0383f90711260515p6155bd7bt196016fb4d8d4cdf@mail.gmail.com>
References: <d0383f90711250636ha8a419emeab52c7107c1d480@mail.gmail.com>
	 <E1IwU4G-00062t-00@gondolin.me.apana.org.au>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: "Herbert Xu" <herbert@gondor.apana.org.au>
Return-path: <netdev-owner@vger.kernel.org>
Received: from rv-out-0910.google.com ([209.85.198.189]:60381 "EHLO
	rv-out-0910.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752731AbXKZNPo (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 26 Nov 2007 08:15:44 -0500
Received: by rv-out-0910.google.com with SMTP id k20so516202rvb
        for <netdev@vger.kernel.org>; Mon, 26 Nov 2007 05:15:43 -0800 (PST)
In-Reply-To: <E1IwU4G-00062t-00@gondolin.me.apana.org.au>
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hello,

Thanks!

This make things clear a bit.

What I understand from thee code (__dst_free() in dst.c) is that if we
are freeing a
dst_entry  (by calling __dst_free() ), than in case this dst_entry was
created as an IPsec dst_entry it has the DST_NOHASH flag set and this
dst_entry is the first in the list; all dst_entries in this
list represent IPsec transformations, except the last dst_entry in
this list; and in such a case, dst_free traverses the list
until the last dst_entry. And if this dst_entry is NOT created as an IPsec
dst_entry, than we freeing it and only it. But I am sorry, I still don't
understand the semantics; why is the name DST_NOHASH?;
NOHASH hints that we do not keep the
an entry in a hash. I doubt that such dst_entries , which are created with
IPsec and so has the DST_NOHASH flag set, are not kept in the routing cache?

Ian

On Nov 26, 2007 4:51 AM, Herbert Xu <herbert@gondor.apana.org.au> wrote:
> Ian Brown <ianbrn@gmail.com> wrote:
> >
> > 3) in net/core/dst.c:
> > struct dst_entry *dst_destroy(struct dst_entry * dst)
> >        {
> >        ...
> >        ...
> >  int nohash = dst->flags & DST_NOHASH;
> >        ...
> >        ...
> > }
>
> You were so close :)
>
> This is where it's used.  Look harder.
>
> Cheers,
> --
> Visit Openswan at http://www.openswan.org/
> Email: Herbert Xu ~{PmV>HI~} <herbert@gondor.apana.org.au>
> Home Page: http://gondor.apana.org.au/~herbert/
> PGP Key: http://gondor.apana.org.au/~herbert/pubkey.txt
>
