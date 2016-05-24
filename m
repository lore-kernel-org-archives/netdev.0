From: Tom Herbert <tom@herbertland.com>
Subject: Re: [RFC PATCH 1/7] fou: Get net from sock_net if dev_net unavailable
Date: Tue, 24 May 2016 15:40:29 -0700
Message-ID: <CALx6S36fGc2TRGBZeoXgZsxsMOi5nsms_zykHm09ZcYhAybqdA@mail.gmail.com>
References: <1464043706-2843932-1-git-send-email-tom@herbertland.com>
	<1464043706-2843932-2-git-send-email-tom@herbertland.com>
	<20160524.150136.139892523857598607.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: Linux Kernel Network Developers <netdev@vger.kernel.org>,
	Kernel Team <kernel-team@fb.com>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-io0-f196.google.com ([209.85.223.196]:33048 "EHLO
	mail-io0-f196.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752569AbcEXWka (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 24 May 2016 18:40:30 -0400
Received: by mail-io0-f196.google.com with SMTP id s67so3456368ios.0
        for <netdev@vger.kernel.org>; Tue, 24 May 2016 15:40:30 -0700 (PDT)
In-Reply-To: <20160524.150136.139892523857598607.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, May 24, 2016 at 3:01 PM, David Miller <davem@davemloft.net> wrote:
> From: Tom Herbert <tom@herbertland.com>
> Date: Mon, 23 May 2016 15:48:20 -0700
>
>> diff --git a/net/ipv4/fou.c b/net/ipv4/fou.c
>> index 5f9207c..96260c6 100644
>> --- a/net/ipv4/fou.c
>> +++ b/net/ipv4/fou.c
>> @@ -807,13 +807,20 @@ int __fou_build_header(struct sk_buff *skb, struct ip_tunnel_encap *e,
>>                      u8 *protocol, __be16 *sport, int type)
>>  {
>>       int err;
>> +     struct net *net;
>>
>
> Please order local variables from longest to shortest line.
>
>>       err = iptunnel_handle_offloads(skb, type);
>>       if (err)
>>               return err;
>>
>> -     *sport = e->sport ? : udp_flow_src_port(dev_net(skb->dev),
>> -                                             skb, 0, 0, false);
>> +     if (skb->dev)
>> +             net = dev_net(skb->dev);
>> +     else if (skb->sk)
>> +             net = sock_net(skb->sk);
>
> This is getting rediculous.  Why not just put the net namespace pointer into
> the tunnel encap object?

Thanks, in this case it will be easier to just pass net in as an argument.

Tom
