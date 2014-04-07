From: Tom Herbert <therbert@google.com>
Subject: Re: [PATCH next-next 5/6] net: Call skb_checksum_init in IPv6
Date: Mon, 7 Apr 2014 13:46:46 -0700
Message-ID: <CA+mtBx8ezm2CEbRefqZ_0bUz6APmz-ha_f_PkuN4_R_mX73gPA@mail.gmail.com>
References: <alpine.DEB.2.02.1404041721050.21509@tomh.mtv.corp.google.com>
	<20140407.131512.2218385912431719305.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: Linux Netdev List <netdev@vger.kernel.org>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ig0-f177.google.com ([209.85.213.177]:56575 "EHLO
	mail-ig0-f177.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754572AbaDGUqr (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 7 Apr 2014 16:46:47 -0400
Received: by mail-ig0-f177.google.com with SMTP id ur14so201491igb.4
        for <netdev@vger.kernel.org>; Mon, 07 Apr 2014 13:46:47 -0700 (PDT)
In-Reply-To: <20140407.131512.2218385912431719305.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, Apr 7, 2014 at 10:15 AM, David Miller <davem@davemloft.net> wrote:
> From: Tom Herbert <therbert@google.com>
> Date: Fri, 4 Apr 2014 17:28:09 -0700 (PDT)
>
>> @@ -62,6 +62,14 @@ __sum16 csum_ipv6_magic(const struct in6_addr *saddr,
>>  EXPORT_SYMBOL(csum_ipv6_magic);
>>  #endif
>>
>> +__wsum ip6_pseudo_compute(struct sk_buff *skb, int proto)
>> +{
>> +     return ~csum_unfold(csum_ipv6_magic(&ipv6_hdr(skb)->saddr,
>> +                                         &ipv6_hdr(skb)->daddr,
>> +                                         skb->len, proto, 0));
>> +}
>> +EXPORT_SYMBOL(ip6_pseudo_compute);
>
> Similarly to the ipv4 case this should really be inline.
>
> I see what the problem is, you've made this now a callback so now it
> can't be really inlined any more.
>
> That's really a terrible negative to this set of changes, please see
> if you can avoid that and inline all of this exactly how it is done
> now in the input paths.
>
Okay, but it's going to be hard to do without resorting to macro's I think...

> Thanks.
