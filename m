From: "Ian Brown" <ianbrn@gmail.com>
Subject: Re: DST_NOHASH flag and IPsec transformers routing tables - need some clarification
Date: Wed, 28 Nov 2007 15:55:19 +0200
Message-ID: <d0383f90711280555s6fa62802w92bcd026f78bb5ac@mail.gmail.com>
References: <d0383f90711260515p6155bd7bt196016fb4d8d4cdf@mail.gmail.com>
	 <E1IwphB-0000Ff-00@gondolin.me.apana.org.au>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: "Herbert Xu" <herbert@gondor.apana.org.au>
Return-path: <netdev-owner@vger.kernel.org>
Received: from py-out-1112.google.com ([64.233.166.181]:8206 "EHLO
	py-out-1112.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750802AbXK1Nzc (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 28 Nov 2007 08:55:32 -0500
Received: by py-out-1112.google.com with SMTP id u77so2943627pyb
        for <netdev@vger.kernel.org>; Wed, 28 Nov 2007 05:55:31 -0800 (PST)
In-Reply-To: <E1IwphB-0000Ff-00@gondolin.me.apana.org.au>
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Thanks!
I had though about this in the last two days and a half, and there is
still something which I cannot
understand and it bothers me (while trying vainlesly to sleep).

I am talking about IPV4:

  - Can anyone explain in 2-3 sentences what is the reason that there
is no need for caching
dst_entries which are created by IPsec (using xfrm API) ?
I can understand , in case there is a linked list of such dst_enties,
that there is no need to cache them all because
you can access them by traversing the list with the child pointer of
dst_entry. But what about the head of the list,  which is the first
dst_entry (which is created by IPsec and its input/output methods are
in fact IPsec transformers)? is there
no need to cache this entry ? because as I understand it , next
sk_buff with the same dest IP will have to get this same
dst_entry (the head of the list). So why not cache this head of the
list of dst_entries ?

Regards,
Ian


On Nov 27, 2007 3:57 AM, Herbert Xu <herbert@gondor.apana.org.au> wrote:
> Ian Brown <ianbrn@gmail.com> wrote:
> >
> > NOHASH hints that we do not keep the
> > an entry in a hash. I doubt that such dst_entries , which are created with
> > IPsec and so has the DST_NOHASH flag set, are not kept in the routing cache?
>
> Exactly, they're not in the routing cache (for IPv4 anyway,
> there is no cache at all for IPv6).
>
>
> Cheers,
> --
> Visit Openswan at http://www.openswan.org/
> Email: Herbert Xu ~{PmV>HI~} <herbert@gondor.apana.org.au>
> Home Page: http://gondor.apana.org.au/~herbert/
> PGP Key: http://gondor.apana.org.au/~herbert/pubkey.txt
>
