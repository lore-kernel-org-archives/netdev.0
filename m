From: =?UTF-8?B?TWFoZXNoIEJhbmRld2FyICjgpK7gpLngpYfgpLYg4KSs4KSC4KSh4KWH4KS14KS+4KSwKQ==?=
        <maheshb@google.com>
Subject: Re: [PATCH net] ipvlan: fix crash
Date: Sun, 18 Dec 2016 10:10:38 -0800
Message-ID: <CAF2d9jjWPEJn55y8hPUkihFyv+fHX_2i0jRbnrfgybZ1pHOByg@mail.gmail.com>
References: <1482027379-30785-1-git-send-email-mahesh@bandewar.net> <20161217.235452.1604434909844387069.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: mahesh@bandewar.net, linux-netdev <netdev@vger.kernel.org>,
        Eric Dumazet <edumazet@google.com>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-yb0-f181.google.com ([209.85.213.181]:35075 "EHLO
        mail-yb0-f181.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1752995AbcLRSK7 (ORCPT
        <rfc822;netdev@vger.kernel.org>); Sun, 18 Dec 2016 13:10:59 -0500
Received: by mail-yb0-f181.google.com with SMTP id d128so51975062ybh.2
        for <netdev@vger.kernel.org>; Sun, 18 Dec 2016 10:10:59 -0800 (PST)
In-Reply-To: <20161217.235452.1604434909844387069.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sat, Dec 17, 2016 at 8:54 PM, David Miller <davem@davemloft.net> wrote:
> From: Mahesh Bandewar <mahesh@bandewar.net>
> Date: Sat, 17 Dec 2016 18:16:19 -0800
>
>> diff --git a/drivers/net/ipvlan/ipvlan_core.c b/drivers/net/ipvlan/ipvlan_core.c
>> index b4e990743e1d..4294fc1f5564 100644
>> --- a/drivers/net/ipvlan/ipvlan_core.c
>> +++ b/drivers/net/ipvlan/ipvlan_core.c
>> @@ -660,6 +660,9 @@ rx_handler_result_t ipvlan_handle_frame(struct sk_buff **pskb)
>>       if (!port)
>>               return RX_HANDLER_PASS;
>>
>> +     if (unlikely(!pskb_may_pull(skb, sizeof(struct ethhdr))))
>> +             goto out;
>> +
>>       switch (port->mode) {
>
> ipvlan only allows non-loopback ethernet devices to register
> this RX handler.
>
> Such situations being tested here should therefore be completely
> impossible.
>
Yes, correct. This happens when the master device is set in loopback mode.

> Every such device must send the SKB through eth_type_trans(), which
> unconditionally accesses the ethernet header, therefore it must
> be pulled into the linear SKB area already, long before this RX
> handler is invoked.
>
> If this really can legitimately happen, you must explain how so.
>
OK, will update the commit log.

> Just showing the crash that later happens in some (completely
> unrelated BTW) ipvlan multicast workqueue handling function, is
> really an insufficient commit log message for a bug like this.
