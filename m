From: Feng Gao <gfree.wind@gmail.com>
Subject: Re: [PATCH net 1/1] net: batman-adv: Treat NET_XMIT_CN as transmit successfully
Date: Mon, 21 Nov 2016 19:01:12 +0800
Message-ID: <CA+6hz4qFrZpC7CYRq1OFJP8y_Zj1LG3qaFZGJNW8rNf=E__4bA@mail.gmail.com>
References: <1479688779-1328-1-git-send-email-fgao@ikuai8.com> <850ff61e-8f94-9316-ed1f-c7d3e8faf95b@cogentembedded.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: mareklindner@neomailbox.ch, sw@simonwunderlich.de, a@unstable.cc,
        "David S. Miller" <davem@davemloft.net>,
        b.a.t.m.a.n@lists.open-mesh.org,
        Linux Kernel Network Developers <netdev@vger.kernel.org>
To: Sergei Shtylyov <sergei.shtylyov@cogentembedded.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-vk0-f51.google.com ([209.85.213.51]:34859 "EHLO
        mail-vk0-f51.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1752452AbcKULBO (ORCPT
        <rfc822;netdev@vger.kernel.org>); Mon, 21 Nov 2016 06:01:14 -0500
Received: by mail-vk0-f51.google.com with SMTP id w194so215571579vkw.2
        for <netdev@vger.kernel.org>; Mon, 21 Nov 2016 03:01:14 -0800 (PST)
In-Reply-To: <850ff61e-8f94-9316-ed1f-c7d3e8faf95b@cogentembedded.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi Sergei,

On Mon, Nov 21, 2016 at 6:44 PM, Sergei Shtylyov
<sergei.shtylyov@cogentembedded.com> wrote:
> Hello.
>
> On 11/21/2016 3:39 AM, fgao@ikuai8.com wrote:
>
>> From: Gao Feng <fgao@ikuai8.com>
>>
>> The tc could return NET_XMIT_CN as one congestion notification, but
>> it does not mean the packe is lost. Other modules like ipvlan,
>
>
>    Packet.

Thanks, it was typo.

>
>> macvlan, and others treat NET_XMIT_CN as success too.
>>
>> So batman-adv should add the NET_XMIT_CN check.
>>
>> Signed-off-by: Gao Feng <fgao@ikuai8.com>
>
>
> [...]
>
>> diff --git a/net/batman-adv/routing.c b/net/batman-adv/routing.c
>> index 7e8dc64..8edd324 100644
>> --- a/net/batman-adv/routing.c
>> +++ b/net/batman-adv/routing.c
>> @@ -706,7 +706,7 @@ static int batadv_route_unicast_packet(struct sk_buff
>> *skb,
>>                 goto out;
>>
>>         /* translate transmit result into receive result */
>> -       if (res == NET_XMIT_SUCCESS) {
>> +       if (res == NET_XMIT_SUCCESS || ret == NET_XMIT_CN) {

Thanks again.
I didn't find it during myself's review and compile process.

>
>
>    Not 'res == NET_XMIT_CN'?
>
>>                 /* skb was transmitted and consumed */
>>                 batadv_inc_counter(bat_priv, BATADV_CNT_FORWARD);
>>                 batadv_add_counter(bat_priv, BATADV_CNT_FORWARD_BYTES,
>
> [...]
>
> MBR, Sergei
>

I have sent the v2 patch which corrects these two typos.

Best Regards
Feng
