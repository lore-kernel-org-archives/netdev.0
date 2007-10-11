From: "Santiago Font Arquer" <sfa.linux@gmail.com>
Subject: Re: PROBLEM: skb_clone SMP race?
Date: Thu, 11 Oct 2007 09:35:52 +0200
Message-ID: <dfad5c650710110035o2577ccc3x2565f29b99adf4e5@mail.gmail.com>
References: <dfad5c650710100200s1369fd96x50ffc5fbffb2e6d9@mail.gmail.com>
	 <E1IfnRx-0003Vu-00@gondolin.me.apana.org.au>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org
To: "Herbert Xu" <herbert@gondor.apana.org.au>
Return-path: <netdev-owner@vger.kernel.org>
Received: from rv-out-0910.google.com ([209.85.198.188]:62786 "EHLO
	rv-out-0910.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752762AbXJKHfw convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 11 Oct 2007 03:35:52 -0400
Received: by rv-out-0910.google.com with SMTP id k20so422650rvb
        for <netdev@vger.kernel.org>; Thu, 11 Oct 2007 00:35:52 -0700 (PDT)
In-Reply-To: <E1IfnRx-0003Vu-00@gondolin.me.apana.org.au>
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Thank you.
I was thinking about something like that when I said "not find
explicit checks", but I was confused because the sk_buff code is
plenty of explicit checks and I understood those checks as a try to
make the code self-protected against wrong uses: "I, sk_buff, offer
you this interface. Don=B4t worry too much about my internals: I will
complain on your mistakes"

The fact the name of the functionality is generic "fast_clone" and not
specific "tcp_fast_clone" drove me to think: "Ok, the allocation of
fast-clonable skbs is NOW only in ONE place inside TCP code and sure
that they have the implicit checks to avoid this race when they call
skb_clone, but -NOW- and -ONE- are not a big guarantee..."

A newbie's thought. :)



2007/10/11, Herbert Xu <herbert@gondor.apana.org.au>:
> Santiago Font Arquer <sfa.linux@gmail.com> wrote:
> >
> >   If an skb with fast clone available (first "if" true) has
> > references in different CPUs (skb->users>1) (I do not find explicit
> > checks for this to be impossible), if skb_clone is called
> > simultaneously over that skb, both callers can get the same clone (=
the
> > "fast" clone) and different problems follow: wrong "clone_skb->user=
s"
> > (1 as expected by the caller, but it should be, to be true, 2),
> > fclone_ref set to 3 involving further problems, ...
>
> Fast clones are only used by TCP where the original skb is
> never given to the outside world.  This plus the fact that
> a given TCP socket is single-threaded makes it safe.
>
> Cheers,
> --
> Visit Openswan at http://www.openswan.org/
> Email: Herbert Xu ~{PmV>HI~} <herbert@gondor.apana.org.au>
> Home Page: http://gondor.apana.org.au/~herbert/
> PGP Key: http://gondor.apana.org.au/~herbert/pubkey.txt
>
