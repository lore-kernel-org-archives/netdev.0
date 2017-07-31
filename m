From: David Ahern <dsahern@gmail.com>
Subject: Re: Long stalls creating a new netns after a netns with a SMB client
 exits
Date: Mon, 31 Jul 2017 17:55:52 -0600
Message-ID: <d98c6c4f-b27c-5cf2-70d7-1afd2876945f@gmail.com>
References: <CA+pO-2cm7bz861KvPMpugP8rVwf6rU8QYrVq7PVO-ZXx2kh1fw@mail.gmail.com>
 <CAM_iQpW+gSgCDWdGoHvN0wObda_g40FcyCBem5VVJ4XLHNMRaQ@mail.gmail.com>
 <CA+pO-2cUUy=_Krwnvt5GL-DUsu+oBOHwhF-TE8sqW=7PFMBrbA@mail.gmail.com>
 <4a56fd38-11f6-4824-bdab-d0f2d46cdf51@gmail.com>
 <CA+pO-2c+uR_3bfEkNAErJp9H4ngwMjeWp=rSKFJxPrgXZpD38g@mail.gmail.com>
 <CAM_iQpW4im2sk3-SXh0fgA9fNp1rN5=+UrwP2wATd=hh1CVo7Q@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 7bit
Cc: Linux Kernel Network Developers <netdev@vger.kernel.org>
To: Cong Wang <xiyou.wangcong@gmail.com>,
        Rolf Neugebauer <rolf.neugebauer@docker.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pf0-f195.google.com ([209.85.192.195]:36535 "EHLO
        mail-pf0-f195.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751808AbdGaXzy (ORCPT
        <rfc822;netdev@vger.kernel.org>); Mon, 31 Jul 2017 19:55:54 -0400
Received: by mail-pf0-f195.google.com with SMTP id t83so129109pfj.3
        for <netdev@vger.kernel.org>; Mon, 31 Jul 2017 16:55:54 -0700 (PDT)
In-Reply-To: <CAM_iQpW4im2sk3-SXh0fgA9fNp1rN5=+UrwP2wATd=hh1CVo7Q@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 7/31/17 4:01 PM, Cong Wang wrote:
>>> diff --git a/net/ipv4/tcp_ipv4.c b/net/ipv4/tcp_ipv4.c
>>> index 3a19ea28339f..37db087b6c97 100644
>>> --- a/net/ipv4/tcp_ipv4.c
>>> +++ b/net/ipv4/tcp_ipv4.c
>>> @@ -1855,7 +1855,7 @@ void inet_sk_rx_dst_set(struct sock *sk, const
>>> struct sk_buff *skb)
>>>  {
>>>         struct dst_entry *dst = skb_dst(skb);
>>>
>>> -       if (dst && dst_hold_safe(dst)) {
>>> +       if (0 && dst && dst_hold_safe(dst)) {
>>>                 sk->sk_rx_dst = dst;
>>>                 inet_sk(sk)->rx_dst_ifindex = skb->skb_iif;
>>>         }
>>
>>
>> This removes the 200s stall (the test is IPv4/TCP based)
> 
> 
> Interesting. This means we have a kernel socket which holds
> the dst refcnt.

Right now there is no tracking that I am aware of for a dst cached on
the socket (outside of walking all sockets). I have been bitten by it
several times in trying to make various changes. It's basically a hidden
reference for the device.
