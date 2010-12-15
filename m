From: Changli Gao <xiaosuo@gmail.com>
Subject: Re: [PATCH 5/5] net: add skb.old_queue_mapping
Date: Wed, 15 Dec 2010 10:59:53 +0800
Message-ID: <AANLkTimepLhRYAf6cJ_h1QKnM=kHngwdKa6BdD+JKuut@mail.gmail.com>
References: <1292251414-5154-1-git-send-email-xiaosuo@gmail.com>
 <1292251414-5154-5-git-send-email-xiaosuo@gmail.com> <1292259412.2759.57.camel@edumazet-laptop>
 <AANLkTinz-3HWnin8OhxxLuCncKgU_Fh8Wq9CcGe2jjXE@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Cc: Jamal Hadi Salim <hadi@cyberus.ca>,
	"David S. Miller" <davem@davemloft.net>, netdev@vger.kernel.org
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-fx0-f43.google.com ([209.85.161.43]:33424 "EHLO
	mail-fx0-f43.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754097Ab0LODAP (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 14 Dec 2010 22:00:15 -0500
Received: by fxm18 with SMTP id 18so1537743fxm.2
        for <netdev@vger.kernel.org>; Tue, 14 Dec 2010 19:00:14 -0800 (PST)
In-Reply-To: <AANLkTinz-3HWnin8OhxxLuCncKgU_Fh8Wq9CcGe2jjXE@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, Dec 14, 2010 at 7:58 AM, Changli Gao <xiaosuo@gmail.com> wrote:
>
> skb->cb can only be used in the same layer, so we can't use it to save
> a value crossing layers. A quick grep finds sch_netem just uses
> skb->cb. Maybe we can put all the skb->cb in the qdisc layer and
> old_queue_mapping in a structure as a new skb->cb. Is it OK? Thanks.
>

I can't do that. Below the qdisc layer, there is another user of
skb->cb GSO. Though we can set the GSO features of ifb to skip
gso_segments(), it is too tricky and weak.

-- 
Regards,
Changli Gao(xiaosuo@gmail.com)
