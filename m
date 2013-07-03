From: Neal Cardwell <ncardwell@google.com>
Subject: Re: [PATCH] net: sock: fix TCP_SKB_MIN_TRUESIZE
Date: Wed, 3 Jul 2013 08:31:52 -0700
Message-ID: <CADVnQyn_W6hzvVKwAG1y2B=QNgSZN=3ymM3bMBmMLpo-PMbFPw@mail.gmail.com>
References: <1371639080-10699-1-git-send-email-dborkman@redhat.com>
	<1371644355.3252.307.camel@edumazet-glaptop>
	<20130619.211721.1594350084165223337.davem@davemloft.net>
	<1372852942.4979.67.camel@edumazet-glaptop>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Cc: David Miller <davem@davemloft.net>,
	Netdev <netdev@vger.kernel.org>,
	Daniel Borkmann <dborkman@redhat.com>
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ee0-f44.google.com ([74.125.83.44]:45932 "EHLO
	mail-ee0-f44.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752514Ab3GCPby (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 3 Jul 2013 11:31:54 -0400
Received: by mail-ee0-f44.google.com with SMTP id c13so167893eek.3
        for <netdev@vger.kernel.org>; Wed, 03 Jul 2013 08:31:52 -0700 (PDT)
In-Reply-To: <1372852942.4979.67.camel@edumazet-glaptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, Jul 3, 2013 at 5:02 AM, Eric Dumazet <eric.dumazet@gmail.com> wrote:
> From: Eric Dumazet <edumazet@google.com>
>
> commit eea86af6b1e18d ("net: sock: adapt SOCK_MIN_RCVBUF and
> SOCK_MIN_SNDBUF") forgot the sk_buff alignment taken into account
> in __alloc_skb() : skb->truesize = SKB_TRUESIZE(size);
>
> While above commit fixed the sender issue, the receiver is still
> dropping the second packet (on loopback device), because the receiver
> socket can not really hold two skbs :
> First packet truesize already is above sk_rcvbuf, so even TCP coalescing
> cannot help.
>
> On a typical 64bit build, each tcp skb truesize is 2304, instead of 2272
>
> Signed-off-by: Eric Dumazet <edumazet@google.com>
> Cc: Daniel Borkmann <dborkman@redhat.com>
> Cc: Neal Cardwell <ncardwell@google.com>
> ---

Acked-by: Neal Cardwell <ncardwell@google.com>
Tested-by: Neal Cardwell <ncardwell@google.com>

neal
