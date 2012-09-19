From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH v3] net-tcp: TCP/IP stack bypass for loopback
 connections
Date: Wed, 19 Sep 2012 23:03:54 +0200
Message-ID: <1348088634.31352.26.camel@edumazet-glaptop>
References: <1347908305-13541-1-git-send-email-brutus@google.com>
	 <1347913239.26523.173.camel@edumazet-glaptop>
	 <20120919.163406.487082174277409074.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: brutus@google.com, edumazet@google.com, netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-bk0-f46.google.com ([209.85.214.46]:40951 "EHLO
	mail-bk0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751884Ab2ISVEC (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 19 Sep 2012 17:04:02 -0400
Received: by bkwj10 with SMTP id j10so784208bkw.19
        for <netdev@vger.kernel.org>; Wed, 19 Sep 2012 14:04:01 -0700 (PDT)
In-Reply-To: <20120919.163406.487082174277409074.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, 2012-09-19 at 16:34 -0400, David Miller wrote:

> I have an idea on how to handle this.
> 
> In drivers/net/loopback.c:loopback_tx(), skip the SKB orphan operation
> if there is a friend socket at skb->friend.
> 
> When sending such friend SKBs out at connection startup, arrange it
> such that the skb->destructor will zap the skb->friend pointer to
> NULL.
> 
> Also, in skb_orphan*(), if necessary, set skb->friend to NULL.
> 
> skb->sk will hold a reference to the socket, and since skb->friend
> will be equal, this will make sure a pointer to an unreferenced
> socket does not escape.

I now am wondering if we still need skb->friend field.

If skb->sk is not zeroed by a premature skb_orphan(), then

skb->sk->sk_friend gives the friend ?
