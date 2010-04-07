From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [RFC] change dst_entry padding from using an array to using
 __attribute__
Date: Wed, 07 Apr 2010 18:55:29 +0200
Message-ID: <1270659329.8141.40.camel@edumazet-laptop>
References: <t2o97949e3e1004070946mfacef7c0la6bddc38d29720ae@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org
To: Laurent Chavey <chavey@google.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-bw0-f209.google.com ([209.85.218.209]:56900 "EHLO
	mail-bw0-f209.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1757863Ab0DGQzg (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 7 Apr 2010 12:55:36 -0400
Received: by bwz1 with SMTP id 1so1025870bwz.21
        for <netdev@vger.kernel.org>; Wed, 07 Apr 2010 09:55:34 -0700 (PDT)
In-Reply-To: <t2o97949e3e1004070946mfacef7c0la6bddc38d29720ae@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Le mercredi 07 avril 2010 =C3=A0 09:46 -0700, Laurent Chavey a =C3=A9cr=
it :
> what are the benefit(s)  of using an array to force a struct
> element to be aligned on 64 bytes / 32 bytes boundaries
> versus using gcc __attribute__.
>=20
>=20
> ------------------------------------
>=20
> struct dst_entry {
>=20
>        /*
>         * Align __refcnt to a 64 bytes alignment
>         * (L1_CACHE_SIZE would be too much)
>         */
> - #ifdef CONFIG_64BIT
> -       long                    __pad_to_align_refcnt[1];
> - #else
> -       long                    __pad_to_align_refcnt[0];
> - #endif
> +       atomic_t                __refcnt __attribute__
> ((aligned(64))); /* client references    */
> #undef __padding__
>        /*
>         * __refcnt wants to be on a different cache line from
>         * input/output/ops or performance tanks badly
>         */
>        atomic_t                __refcnt;       /* client references  =
  */
> };

We dont want a huge hole (say.. 120 bytes) being not noticed.

Some machines around have 4 millions dst entries.

This deserve us being not lazy :)

Thanks


