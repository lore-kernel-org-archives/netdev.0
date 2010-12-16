From: Changli Gao <xiaosuo@gmail.com>
Subject: Re: [PATCH] net: increase skb->users instead of skb_clone()
Date: Thu, 16 Dec 2010 15:23:18 +0800
Message-ID: <AANLkTi=BX8AMaiwV3aDAVqRA=br00eRo-42vPNwZfwS6@mail.gmail.com>
References: <1292479045-3136-1-git-send-email-xiaosuo@gmail.com> <1292483902.2603.62.camel@edumazet-laptop>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Cc: "David S. Miller" <davem@davemloft.net>,
	Tom Herbert <therbert@google.com>,
	Jiri Pirko <jpirko@redhat.com>,
	Fenghua Yu <fenghua.yu@intel.com>,
	Junchang Wang <junchangwang@gmail.com>,
	Xinan Tang <xinan.tang@intel.com>, netdev@vger.kernel.org
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-fx0-f43.google.com ([209.85.161.43]:39401 "EHLO
	mail-fx0-f43.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752284Ab0LPHXj (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 16 Dec 2010 02:23:39 -0500
Received: by fxm18 with SMTP id 18so2964380fxm.2
        for <netdev@vger.kernel.org>; Wed, 15 Dec 2010 23:23:38 -0800 (PST)
In-Reply-To: <1292483902.2603.62.camel@edumazet-laptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, Dec 16, 2010 at 3:18 PM, Eric Dumazet <eric.dumazet@gmail.com> wrote:
>
> You beat me, but I was thinking of a different way, adding a new
> pt_prev->xmit_func(), handling all the details (no need for atomic ops
> on skb users if packet is not delivered at all).
>
> By the way, your patch is not 100% safe/OK, because af_packet rcv()
> handler writes on skb (skb_pull() and all)
>

But af_packet_rcv() restores skbs at last.

        if (skb_head != skb->data && skb_shared(skb)) {
                skb->data = skb_head;
                skb->len = skb_len;
        }

-- 
Regards,
Changli Gao(xiaosuo@gmail.com)
