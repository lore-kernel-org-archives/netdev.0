From: Mahesh Bandewar <maheshb@google.com>
Subject: Re: [PATCH next v3 1/3] ipvlan: scrub skb before routing in L3 mode.
Date: Thu, 18 Feb 2016 17:06:23 -0800
Message-ID: <CAF2d9jgdBD6+PUKJ6BBB9h6mD7vTmuCNS5hupBSFcXs+K_Vobw@mail.gmail.com>
References: <1455767550-16896-1-git-send-email-mahesh@bandewar.net>
 <CAM_iQpXUv1s1xw9g9uox25fYrRXpTjFLE5_OwUYE_tCZAoGF3w@mail.gmail.com>
 <CAF2d9jjPc6pwuZZiuLCc27ex+Hqc9-x0MdyyaR=ErwVV===DEQ@mail.gmail.com> <CAM_iQpWnXjumJE8_7vqFa-rfw6zgRp+hw1e-duzmaqvWDsJ6Cw@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: Mahesh Bandewar <mahesh@bandewar.net>,
	David Miller <davem@davemloft.net>,
	Eric Dumazet <edumazet@google.com>,
	netdev <netdev@vger.kernel.org>
To: Cong Wang <xiyou.wangcong@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-yw0-f172.google.com ([209.85.161.172]:33561 "EHLO
	mail-yw0-f172.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1947496AbcBSBGn (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 18 Feb 2016 20:06:43 -0500
Received: by mail-yw0-f172.google.com with SMTP id u200so56070997ywf.0
        for <netdev@vger.kernel.org>; Thu, 18 Feb 2016 17:06:43 -0800 (PST)
In-Reply-To: <CAM_iQpWnXjumJE8_7vqFa-rfw6zgRp+hw1e-duzmaqvWDsJ6Cw@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, Feb 18, 2016 at 4:44 PM, Cong Wang <xiyou.wangcong@gmail.com> wrote:
> On Thu, Feb 18, 2016 at 4:39 PM, Mahesh Bandewar <maheshb@google.com> wrote:
>> [snip]
>>>> -       skb_dst_drop(skb);
>>>> +       skb_scrub_packet(skb, true);
>>>
>>> At least this patch is still same with the previous version. Or am I
>>> missing anything?
>>
>>  xnet param is now set to 'true'.
>
> Oh, I was suggesting to set xnet based on the netns of both ipvlan
> device and physical device, not setting it to be true or false
> unconditionally.
>
Well, thought about that but don't know any use case / user who is
using the ipvlan slave devices in the same ns as master hence decided
to do it this way.

> Something like:
>
> xnet = !netns_eq(dev_net(ipvlan_dev), dev_net(phy_dev));
>
> (not real code, just to show my idea)
>
> Makes any sense?
Sure, it's not hard just did for the said reasons.
