From: Andy Lutomirski <luto@amacapital.net>
Subject: Re: [PATCH v2 net-next] tcp: md5: use kmalloc() backed scratch areas
Date: Mon, 27 Jun 2016 10:58:42 -0700
Message-ID: <CALCETrUSi3T5JXMunEO9RM5ZEz=aA2xtf9encEVYGxJF4mbhKg@mail.gmail.com>
References: <CALCETrXezCXy4N7wMjYdr+U1A9Avda5bVxTxOQZswinh62gbvw@mail.gmail.com>
 <1466827910.6850.123.camel@edumazet-glaptop3.roam.corp.google.com>
 <1466828771.6850.124.camel@edumazet-glaptop3.roam.corp.google.com>
 <1466829439.6850.126.camel@edumazet-glaptop3.roam.corp.google.com>
 <1466870975.6850.139.camel@edumazet-glaptop3.roam.corp.google.com> <1467046313.6850.171.camel@edumazet-glaptop3.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: David Miller <davem@davemloft.net>,
	Herbert Xu <herbert@gondor.apana.org.au>,
	Network Development <netdev@vger.kernel.org>
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-vk0-f50.google.com ([209.85.213.50]:34609 "EHLO
	mail-vk0-f50.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751639AbcF0R7C (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 27 Jun 2016 13:59:02 -0400
Received: by mail-vk0-f50.google.com with SMTP id c2so211926561vkg.1
        for <netdev@vger.kernel.org>; Mon, 27 Jun 2016 10:59:02 -0700 (PDT)
In-Reply-To: <1467046313.6850.171.camel@edumazet-glaptop3.roam.corp.google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, Jun 27, 2016 at 9:51 AM, Eric Dumazet <eric.dumazet@gmail.com> wrote:
> From: Eric Dumazet <edumazet@google.com>
>
> Some arches have virtually mapped kernel stacks, or will soon have.
>
> tcp_md5_hash_header() uses an automatic variable to copy tcp header
> before mangling th->check and calling crypto function, which might
> be problematic on such arches.
>
> David says that using percpu storage is also problematic on non SMP
> builds.
>
> Just use kmalloc() to allocate scratch areas.

Seems reasonable.

I wonder if it's worth switching from ahash to shash, though.  It
would probably be simpler and faster.

--Andy
