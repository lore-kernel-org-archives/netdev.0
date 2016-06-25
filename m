From: Andy Lutomirski <luto@amacapital.net>
Subject: Re: [PATCH net-next] tcp: md5: do not use stack storage in crypto operations
Date: Sat, 25 Jun 2016 12:35:36 -0700
Message-ID: <CALCETrU3XGhfAAWdLzP38WLEH4i0YcnMZ_Sb7Taf4iRgO1cvZQ@mail.gmail.com>
References: <CALCETrXezCXy4N7wMjYdr+U1A9Avda5bVxTxOQZswinh62gbvw@mail.gmail.com>
 <1466827910.6850.123.camel@edumazet-glaptop3.roam.corp.google.com>
 <1466828771.6850.124.camel@edumazet-glaptop3.roam.corp.google.com>
 <1466829439.6850.126.camel@edumazet-glaptop3.roam.corp.google.com> <1466870975.6850.139.camel@edumazet-glaptop3.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: David Miller <davem@davemloft.net>,
	Herbert Xu <herbert@gondor.apana.org.au>,
	Network Development <netdev@vger.kernel.org>
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-vk0-f52.google.com ([209.85.213.52]:34759 "EHLO
	mail-vk0-f52.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751631AbcFYTf5 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 25 Jun 2016 15:35:57 -0400
Received: by mail-vk0-f52.google.com with SMTP id c2so159122269vkg.1
        for <netdev@vger.kernel.org>; Sat, 25 Jun 2016 12:35:57 -0700 (PDT)
In-Reply-To: <1466870975.6850.139.camel@edumazet-glaptop3.roam.corp.google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sat, Jun 25, 2016 at 9:09 AM, Eric Dumazet <eric.dumazet@gmail.com> wrote:
> From: Eric Dumazet <edumazet@google.com>
>
> Some arches have virtually mapped kernel stacks, or will soon have.
>
> tcp_md5_hash_header() uses an automatic variable to copy tcp header
> before mangling th->check and calling crypto function, which might
> be problematic on such arches.
>
> So use percpu storage as we already do for the pseudo header,
> and reduce number of crypto functions calls, as these headers
> are ridiculously small.

Thanks!

Should this go in via net-next or -tip?

--Andy
