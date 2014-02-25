From: Florian Fainelli <f.fainelli@gmail.com>
Subject: Re: bcmgenet's custom ->ndo_select_queue()
Date: Mon, 24 Feb 2014 16:37:08 -0800
Message-ID: <CAGVrzcbuCpBLYDA7dW1hegBvcr8-KVtnvPj+otEzkOrAu6ccXw@mail.gmail.com>
References: <20140224.193229.2076944569180242866.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: netdev <netdev@vger.kernel.org>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pd0-f171.google.com ([209.85.192.171]:60213 "EHLO
	mail-pd0-f171.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752569AbaBYAht (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 24 Feb 2014 19:37:49 -0500
Received: by mail-pd0-f171.google.com with SMTP id r10so1492121pdi.30
        for <netdev@vger.kernel.org>; Mon, 24 Feb 2014 16:37:48 -0800 (PST)
In-Reply-To: <20140224.193229.2076944569180242866.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

2014-02-24 16:32 GMT-08:00 David Miller <davem@davemloft.net>:
>
> While fixing a build warning:
>
> drivers/net/ethernet/broadcom/genet/bcmgenet.c:2293:2: warning: initialization from incompatible pointer type [enabled by default]
>
> I see that bcmgenet's implementation is:
>
>         return netif_is_multiqueue(dev) ? skb->queue_mapping : 0;
>
> That makes no sense at all.
>
> You should only define an overriding function here if you want to do
> something uniqueue, and not use the default.
>
> If you don't assign the queue mapping, it's not even going to be
> set when your select_queue method is called.  In _FACT_ that's the
> reason it is called, to get the queue mapping set.
>
> I'm just deleting this completely, I hope you don't mind.

Not at all, this was in the downstream driver but it definitively
looks suspicious. Thanks!
-- 
Florian
