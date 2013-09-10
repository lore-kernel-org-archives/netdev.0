From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH net-next] net: sk_buff: memset(skb,0) after alloc in
 skb_clone
Date: Tue, 10 Sep 2013 05:40:32 -0700
Message-ID: <1378816832.26319.75.camel@edumazet-glaptop>
References: <1378788533-5609-1-git-send-email-govindarajulu90@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: davem@davemloft.net, netdev@vger.kernel.org
To: Govindarajulu Varadarajan <govindarajulu90@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f45.google.com ([209.85.220.45]:36935 "EHLO
	mail-pa0-f45.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751313Ab3IJMkd (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 10 Sep 2013 08:40:33 -0400
Received: by mail-pa0-f45.google.com with SMTP id bg4so7661261pad.4
        for <netdev@vger.kernel.org>; Tue, 10 Sep 2013 05:40:33 -0700 (PDT)
In-Reply-To: <1378788533-5609-1-git-send-email-govindarajulu90@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, 2013-09-10 at 10:18 +0530, Govindarajulu Varadarajan wrote:
> The following patch memset the skb to 0 after alloc. We do this in
> __alloc_skb_head, __alloc_skb, build_skb. We are missing this in
> skb_clone.
> 
> The following call to __skb_clone in skb_clone does not copy all the
> members of sk_buff. If we donot clear the skb to 0, we will have some
> uninitialized members in new skb.

Which ones exactly ?

I would rather make sure all fields are properly copied.

Your patch is incomplete, because it doesn't handle the fast clone case.
