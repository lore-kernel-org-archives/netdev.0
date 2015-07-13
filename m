From: Eric Dumazet <edumazet@google.com>
Subject: Re: [PATCH] netlink: enable skb header refcounting before sending
 first broadcast
Date: Mon, 13 Jul 2015 10:28:19 +0200
Message-ID: <CANn89iLFCJWqmfvwOUB_7VUk_7jHHvOHZR6=fufDr848thSrHQ@mail.gmail.com>
References: <20150710115141.12980.88829.stgit@buzz>
	<20150713072352.GA8485@gondor.apana.org.au>
	<1436774742.9402.3.camel@edumazet-glaptop2.roam.corp.google.com>
	<20150713081040.GB8971@gondor.apana.org.au>
	<1436775754.9402.6.camel@edumazet-glaptop2.roam.corp.google.com>
	<20150713082544.GA9176@gondor.apana.org.au>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: Eric Dumazet <eric.dumazet@gmail.com>,
	Konstantin Khlebnikov <khlebnikov@yandex-team.ru>,
	netdev <netdev@vger.kernel.org>,
	"David S. Miller" <davem@davemloft.net>
To: Herbert Xu <herbert@gondor.apana.org.au>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wi0-f182.google.com ([209.85.212.182]:34879 "EHLO
	mail-wi0-f182.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751327AbbGMI2U (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 13 Jul 2015 04:28:20 -0400
Received: by wiga1 with SMTP id a1so62021171wig.0
        for <netdev@vger.kernel.org>; Mon, 13 Jul 2015 01:28:19 -0700 (PDT)
In-Reply-To: <20150713082544.GA9176@gondor.apana.org.au>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, Jul 13, 2015 at 10:25 AM, Herbert Xu
<herbert@gondor.apana.org.au> wrote:
> On Mon, Jul 13, 2015 at 10:22:34AM +0200, Eric Dumazet wrote:
>>
>> It should worry, in case multiple threads are using MSG_PEEK on same udp
>> socket ;)
>
> That should be fine because we already hold a spinlock on the
> queue.
>

Except that udp checksum are checked outside of spinlock protection.
