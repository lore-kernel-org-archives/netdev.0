From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH net-next] net: sock: adapt SOCK_MIN_RCVBUF and
 SOCK_MIN_SNDBUF
Date: Wed, 19 Jun 2013 03:02:12 -0700
Message-ID: <1371636132.3252.292.camel@edumazet-glaptop>
References: <1371633518-32656-1-git-send-email-dborkman@redhat.com>
	 <1371635505.3252.285.camel@edumazet-glaptop> <51C18098.60709@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: davem@davemloft.net, netdev@vger.kernel.org
To: Daniel Borkmann <dborkman@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ea0-f172.google.com ([209.85.215.172]:58474 "EHLO
	mail-ea0-f172.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S933830Ab3FSKCR (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 19 Jun 2013 06:02:17 -0400
Received: by mail-ea0-f172.google.com with SMTP id q10so3132807eaj.3
        for <netdev@vger.kernel.org>; Wed, 19 Jun 2013 03:02:15 -0700 (PDT)
In-Reply-To: <51C18098.60709@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, 2013-06-19 at 11:57 +0200, Daniel Borkmann wrote:

> Ok, if you prefer, I can send an update.
> 

Yes please.

By the way, I used exactly :

-#define SOCK_MIN_SNDBUF 2048
+/* minimum tcp skb truesize is 2048 + sizeof(struct sk_buff) */
+#define TCP_SKB_MIN_TRUESIZE (2048 + sizeof(struct sk_buff))
+
+#define SOCK_MIN_SNDBUF (2 * TCP_SKB_MIN_TRUESIZE)


because SKB_TRUESIZE(2048) adds 
SKB_DATA_ALIGN(sizeof(struct skb_shared_info))

But in case of TCP skbs, the skb_shared_info is part of the 2048 bytes
allocation for skb->head
