From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH net-next] tcp: tcp_v4_early_demux() fixes
Date: Tue, 24 Jul 2012 13:05:36 +0200
Message-ID: <1343127936.2626.11054.camel@edumazet-glaptop>
References: <1343126555.2626.11053.camel@edumazet-glaptop>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev <netdev@vger.kernel.org>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-bk0-f46.google.com ([209.85.214.46]:48143 "EHLO
	mail-bk0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753157Ab2GXLFl (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 24 Jul 2012 07:05:41 -0400
Received: by bkwj10 with SMTP id j10so6177637bkw.19
        for <netdev@vger.kernel.org>; Tue, 24 Jul 2012 04:05:40 -0700 (PDT)
In-Reply-To: <1343126555.2626.11053.camel@edumazet-glaptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, 2012-07-24 at 12:42 +0200, Eric Dumazet wrote:
> From: Eric Dumazet <edumazet@google.com>
> 
> 1) Remove a non needed pskb_may_pull() and fix a potential bug
> if skb->head was reallocated (iph & th pointers were not reloaded)
> 
> TCP stack will pull/check headers anyway.
> 
> 2) skb->dev->ifindex can be now replaced by skb->skb_iif
> 
> Signed-off-by: Eric Dumazet <edumazet@google.com>
> ---
>  net/ipv4/tcp_ipv4.c |    9 ++-------
>  1 file changed, 2 insertions(+), 7 deletions(-)

I'll send a v2, a fix is also needed in ip_rcv_finish()
