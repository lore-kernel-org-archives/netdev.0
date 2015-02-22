From: Scott Feldman <sfeldma@gmail.com>
Subject: Re: ARP resolving for switch drivers
Date: Sat, 21 Feb 2015 22:28:26 -0800
Message-ID: <CAE4R7bCV1+oA8i52i8g=+yEwsoApcAQq5-WeTxgN40v-ai7y+A@mail.gmail.com>
References: <20150222.011109.109641758308879034.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: Netdev <netdev@vger.kernel.org>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-qa0-f47.google.com ([209.85.216.47]:49527 "EHLO
	mail-qa0-f47.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753032AbbBVG21 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 22 Feb 2015 01:28:27 -0500
Received: by mail-qa0-f47.google.com with SMTP id v10so18149490qac.6
        for <netdev@vger.kernel.org>; Sat, 21 Feb 2015 22:28:26 -0800 (PST)
In-Reply-To: <20150222.011109.109641758308879034.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sat, Feb 21, 2015 at 10:11 PM, David Miller <davem@davemloft.net> wrote:
>
> Scott I looked into the current state of affairs and you should
> be able to use generic infrastructure to resolve a neighbour
> entry and even trigger the state machine.
>
> For ipv4:
>
>         n = __ipv4_neigh_lookup(dev, ip_addr);
>         if (!n)
>                 n = neigh_create(&arp_tbl, &ip_addr, dev, true);
>         if (!n)
>                 goto error;
>
>         if (!(n->nud_state & NUD_VALID))
>                 neigh_event_send(n, NULL);
>         else
>                 memcpy(&hw_entry->mac_addr, n->ha, dev_addr_len);
>
> If you have to take the neigh_event_send() path, you have to wait for
> the notifier to be invoked.  And in the notifier you can fetch the
> MAC address.

Perfect!  I'll give this a try shortly and test and report back.
(Trying to beat down some remaining L2 issues first).

I saw similar code in IB, but I don't understand the IB use-case.

> You shouldn't have to hand craft ARP requests and listen for responses
> or anything like that.

Thanks Dave.

-scott
