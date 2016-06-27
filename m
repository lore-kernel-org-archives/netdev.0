From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH v2 net-next] tcp: md5: use kmalloc() backed scratch areas
Date: Mon, 27 Jun 2016 23:25:10 +0200
Message-ID: <1467062710.6850.176.camel@edumazet-glaptop3.roam.corp.google.com>
References: <CALCETrXezCXy4N7wMjYdr+U1A9Avda5bVxTxOQZswinh62gbvw@mail.gmail.com>
	 <1466827910.6850.123.camel@edumazet-glaptop3.roam.corp.google.com>
	 <1466828771.6850.124.camel@edumazet-glaptop3.roam.corp.google.com>
	 <1466829439.6850.126.camel@edumazet-glaptop3.roam.corp.google.com>
	 <1466870975.6850.139.camel@edumazet-glaptop3.roam.corp.google.com>
	 <1467046313.6850.171.camel@edumazet-glaptop3.roam.corp.google.com>
	 <CAM_iQpU8H-decpeKbFd05Wt9mWsdpb+Yp=VLNrTHv8gPnJCWbQ@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: Andy Lutomirski <luto@amacapital.net>,
	David Miller <davem@davemloft.net>,
	Herbert Xu <herbert@gondor.apana.org.au>,
	Network Development <netdev@vger.kernel.org>
To: Cong Wang <xiyou.wangcong@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wm0-f53.google.com ([74.125.82.53]:38189 "EHLO
	mail-wm0-f53.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751940AbcF0VZN (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 27 Jun 2016 17:25:13 -0400
Received: by mail-wm0-f53.google.com with SMTP id r201so593860wme.1
        for <netdev@vger.kernel.org>; Mon, 27 Jun 2016 14:25:12 -0700 (PDT)
In-Reply-To: <CAM_iQpU8H-decpeKbFd05Wt9mWsdpb+Yp=VLNrTHv8gPnJCWbQ@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, 2016-06-27 at 11:31 -0700, Cong Wang wrote:

> Not a problem of your patch, but it seems these allocations never
> get freed once we start using tcp md5. Maybe we should free them
> when the last socket using tcp md5 is gone?

If we constantly allocate-deallocate these tiny blocks for occasional
TCP MD5 use, it becomes quite expensive.

With current code, only first TCP MD5 usage trigger an extra setup cost.
