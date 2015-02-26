From: Eyal Birger <eyal.birger@gmail.com>
Subject: Re: [PATCH net-next 4/7] net: packet: use skb->dev as storage for skb
 orig len instead of skb->cb[]
Date: Thu, 26 Feb 2015 06:03:40 +0200
Message-ID: <CAHsH6GtJauVJULMXpHbrVvQxdm6zdfHKbKvTgJQi2MvdjCrpvQ@mail.gmail.com>
References: <1424916612-744-1-git-send-email-eyal.birger@gmail.com>
	<1424916612-744-5-git-send-email-eyal.birger@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: Willem de Bruijn <willemb@google.com>,
	Eric Dumazet <edumazet@google.com>,
	Shmulik Ladkani <shmulik.ladkani@gmail.com>,
	marcel@holtmann.org,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	Eyal Birger <eyal.birger@gmail.com>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-yh0-f49.google.com ([209.85.213.49]:33995 "EHLO
	mail-yh0-f49.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752769AbbBZEDl (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 25 Feb 2015 23:03:41 -0500
Received: by yhai57 with SMTP id i57so3269636yha.1
        for <netdev@vger.kernel.org>; Wed, 25 Feb 2015 20:03:41 -0800 (PST)
In-Reply-To: <1424916612-744-5-git-send-email-eyal.birger@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

>
>         sll->sll_halen = dev_parse_header(skb, sll->sll_addr);
>
> -       PACKET_SKB_CB(skb)->origlen = skb->len;
> +       *PACKET_SKB_ORIGLEN(skb) = skb->len;
>
>         if (pskb_trim(skb, snaplen))
>                 goto drop_n_acct;
>
>         skb_set_owner_r(skb, sk);
> -       skb->dev = NULL;
>         skb_dst_drop(skb);

There is a problem here. skb->dev must still be valid on the call to
skb_set_owner_r().

Sorry about that. I'll spin a second version along with any other
comments raised on this series.

Eyal.
