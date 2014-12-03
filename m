From: Mahesh Bandewar <maheshb@google.com>
Subject: Re: [PATCH net-next v3] rtnetlink: delay RTM_DELLINK notification
 until after ndo_uninit()
Date: Wed, 3 Dec 2014 11:08:43 -0800
Message-ID: <CAF2d9jh2-iFO5VA6=O=L=BjQ=WgtBgviV=BvJH5QHZKuydQgvg@mail.gmail.com>
References: <1417591497-24246-1-git-send-email-maheshb@google.com> <1417592357.5303.130.camel@edumazet-glaptop2.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Cc: netdev <netdev@vger.kernel.org>,
	David Miller <davem@davemloft.net>,
	Eric Dumazet <edumazet@google.com>,
	Roopa Prabhu <roopa@cumulusnetworks.com>,
	Toshiaki Makita <makita.toshiaki@lab.ntt.co.jp>
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-oi0-f50.google.com ([209.85.218.50]:58696 "EHLO
	mail-oi0-f50.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750891AbaLCTJE (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 3 Dec 2014 14:09:04 -0500
Received: by mail-oi0-f50.google.com with SMTP id a141so11305290oig.9
        for <netdev@vger.kernel.org>; Wed, 03 Dec 2014 11:09:03 -0800 (PST)
In-Reply-To: <1417592357.5303.130.camel@edumazet-glaptop2.roam.corp.google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, Dec 2, 2014 at 11:39 PM, Eric Dumazet <eric.dumazet@gmail.com> wrote:
> On Tue, 2014-12-02 at 23:24 -0800, Mahesh Bandewar wrote:
>
>> +EXPORT_SYMBOL(rtmsg_ifinfo_build_skb);
>> +
>> +void rtmsg_ifinfo_send(struct sk_buff *skb, struct net_device *dev, gfp_t flags)
>> +{
>> +     struct net *net = dev_net(dev);
>> +
>> +     rtnl_notify(skb, net, 0, RTNLGRP_LINK, NULL, flags);
>> +}
>> +EXPORT_SYMBOL(rtmsg_ifinfo_send);
>> +
>> +void rtmsg_ifinfo(int type, struct net_device *dev, unsigned int change,
>> +               gfp_t flags)
>> +{
>> +     struct sk_buff *skb;
>> +
>> +     skb = rtmsg_ifinfo_build_skb(type, dev, change, flags);
>> +     if (skb)
>> +             rtmsg_ifinfo_send(skb, dev, flags);
>>  }
>>  EXPORT_SYMBOL(rtmsg_ifinfo);
>
> One last point :
>
> Only rtmsg_ifinfo() needs the EXPORT_SYMBOL(...)
>
> rtmsg_ifinfo_build_skb() and rtmsg_ifinfo_send() are used from core networking stack,
> not a module.
>
Thanks Eric. If we ever need that in a module in the future, we can
add that later. Will remove them.
>
>
