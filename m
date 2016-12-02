From: Erik Nordmark <nordmark@arista.com>
Subject: Re: [PATCH net-next v3] ipv6 addrconf: Implemented enhanced DAD
 (RFC7527)
Date: Thu, 1 Dec 2016 21:41:30 -0800
Message-ID: <ff997367-17cd-d484-17b4-6a09b1f9e74f@arista.com>
References: <1480549159-8142-1-git-send-email-nordmark@arista.com>
 <1764849a-e853-21f8-a6e5-f2280b3b8a88@stressinduktion.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, Bob Gilligan <gilligan@arista.com>
To: Hannes Frederic Sowa <hannes@stressinduktion.org>,
        davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pf0-f175.google.com ([209.85.192.175]:33463 "EHLO
        mail-pf0-f175.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1752385AbcLBFmo (ORCPT
        <rfc822;netdev@vger.kernel.org>); Fri, 2 Dec 2016 00:42:44 -0500
Received: by mail-pf0-f175.google.com with SMTP id d2so50715120pfd.0
        for <netdev@vger.kernel.org>; Thu, 01 Dec 2016 21:42:43 -0800 (PST)
In-Reply-To: <1764849a-e853-21f8-a6e5-f2280b3b8a88@stressinduktion.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 12/1/16 2:28 PM, Hannes Frederic Sowa wrote:
> Reviewed-by: Hannes Frederic Sowa <hannes@stressinduktion.org>

Thanks - I'll add that.
Also got a warning from the kbuild test robot for route.c which I'll fix.

>
> Thanks!
>> @@ -794,6 +808,17 @@ static void ndisc_recv_ns(struct sk_buff *skb)
>>   have_ifp:
>>   		if (ifp->flags & (IFA_F_TENTATIVE|IFA_F_OPTIMISTIC)) {
>>   			if (dad) {
>> +				if (nonce != 0 && ifp->dad_nonce == nonce) {
>> +					u8 *np = (u8 *)&nonce;
>> +					/* Matching nonce if looped back */
>> +					ND_PRINTK(2, notice,
>> +						  "%s: IPv6 DAD loopback for address %pI6c nonce %02x:%02x:%02x:%02x:%02x:%02x ignored\n",
>> +						  ifp->idev->dev->name,
>> +						  &ifp->addr,
>> +						  np[0], np[1], np[2], np[3],
>> +						  np[4], np[5]);
>> +					goto out;
>> +				}
>>   				/*
>>   				 * We are colliding with another node
>>   				 * who is doing DAD
>>
> I think it could be a "%pM" because it looks like a MAC address, but
> better leave it like that. :)

It is 6 bytes, but it isn't a mac address so I'll leave it.

Thanks,
   Erik
