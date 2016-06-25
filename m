From: Andy Lutomirski <luto@amacapital.net>
Subject: tcp md5: one more crypto-sg-on-the-stack instance
Date: Fri, 24 Jun 2016 18:51:17 -0700
Message-ID: <CALCETrXezCXy4N7wMjYdr+U1A9Avda5bVxTxOQZswinh62gbvw@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: Eric Dumazet <eric.dumazet@gmail.com>
To: Herbert Xu <herbert@gondor.apana.org.au>,
	Network Development <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-vk0-f47.google.com ([209.85.213.47]:35924 "EHLO
	mail-vk0-f47.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751037AbcFYBvh (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 24 Jun 2016 21:51:37 -0400
Received: by mail-vk0-f47.google.com with SMTP id u64so172340527vkf.3
        for <netdev@vger.kernel.org>; Fri, 24 Jun 2016 18:51:37 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi all-

tcp_md5_hash_header does crypto using an sg that points to the stack.
This will break with virtually mapped stacks.  It also looks like it's
probably much slower than it deserves to be (it's trying to compute
the MD5 hash of a few tens of bytes -- going through a scatterlist is
a lot of overhead for an otherwise very fast operation).

I don't suppose one of you could fix it or at least advise as to how
it should be fixed.

Thanks,
Andy
