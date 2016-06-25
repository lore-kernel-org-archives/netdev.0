From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: tcp md5: one more crypto-sg-on-the-stack instance
Date: Sat, 25 Jun 2016 06:11:50 +0200
Message-ID: <1466827910.6850.123.camel@edumazet-glaptop3.roam.corp.google.com>
References: <CALCETrXezCXy4N7wMjYdr+U1A9Avda5bVxTxOQZswinh62gbvw@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: Herbert Xu <herbert@gondor.apana.org.au>,
	Network Development <netdev@vger.kernel.org>
To: Andy Lutomirski <luto@amacapital.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wm0-f49.google.com ([74.125.82.49]:36548 "EHLO
	mail-wm0-f49.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751044AbcFYELx (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 25 Jun 2016 00:11:53 -0400
Received: by mail-wm0-f49.google.com with SMTP id f126so41757115wma.1
        for <netdev@vger.kernel.org>; Fri, 24 Jun 2016 21:11:53 -0700 (PDT)
In-Reply-To: <CALCETrXezCXy4N7wMjYdr+U1A9Avda5bVxTxOQZswinh62gbvw@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, 2016-06-24 at 18:51 -0700, Andy Lutomirski wrote:
> Hi all-
> 
> tcp_md5_hash_header does crypto using an sg that points to the stack.
> This will break with virtually mapped stacks.  It also looks like it's
> probably much slower than it deserves to be (it's trying to compute
> the MD5 hash of a few tens of bytes -- going through a scatterlist is
> a lot of overhead for an otherwise very fast operation).

I guess nobody cares about TCP MD5 speed really.

> 
> I don't suppose one of you could fix it or at least advise as to how
> it should be fixed.

Simply extend tcp_md5sig_pool to contain a copy of the TCP headers ?

At most 40 bytes of extra per cpu storage is not a big problem.
