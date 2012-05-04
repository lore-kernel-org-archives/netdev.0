From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH net-next] net: skb_peek()/skb_peek_tail() cleanups
Date: Fri, 04 May 2012 15:01:31 +0200
Message-ID: <1336136491.3752.318.camel@edumazet-glaptop>
References: <1335839506.11396.17.camel@edumazet-glaptop>
	 <20120501.094127.190023878792795840.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-bk0-f46.google.com ([209.85.214.46]:37730 "EHLO
	mail-bk0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750880Ab2EDNBg (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 4 May 2012 09:01:36 -0400
Received: by bkcji2 with SMTP id ji2so2183592bkc.19
        for <netdev@vger.kernel.org>; Fri, 04 May 2012 06:01:35 -0700 (PDT)
In-Reply-To: <20120501.094127.190023878792795840.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, 2012-05-01 at 09:41 -0400, David Miller wrote:
> From: Eric Dumazet <eric.dumazet@gmail.com>
> Date: Tue, 01 May 2012 04:31:46 +0200
> 
> > From: Eric Dumazet <edumazet@google.com>
> > 
> > remove useless casts and rename variables for less confusion.
> > 
> > Signed-off-by: Eric Dumazet <edumazet@google.com>
> 
> Applied, I really need to get back to completing the list_head
> conversion :-/

Actually doubly linked lists everywhere has a performance issue.

When we dequeue one skb, we must bring in cpu cache the next skb as
well, to perform the unlink.

In some places it would be better to not have a double linked list, and
only perform a prefetch(skb->next).
