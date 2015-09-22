From: David Ahern <dsa@cumulusnetworks.com>
Subject: Re: [RFC net-next 4/4] net: ipv6: Initial support for VRFs
Date: Mon, 21 Sep 2015 18:18:07 -0600
Message-ID: <56009E3F.90607@cumulusnetworks.com>
References: <1442878378-13322-1-git-send-email-dsa@cumulusnetworks.com>
 <1442878378-13322-5-git-send-email-dsa@cumulusnetworks.com>
 <CALx6S37hPDG1FLYXfLJgYcionA2oj+v1dLFaCVoP91qVrUUh7A@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Linux Kernel Network Developers <netdev@vger.kernel.org>,
	Shrijeet Mukherjee <shm@cumulusnetworks.com>,
	Roopa Prabhu <roopa@cumulusnetworks.com>
To: Tom Herbert <tom@herbertland.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-io0-f178.google.com ([209.85.223.178]:33976 "EHLO
	mail-io0-f178.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756633AbbIVASC (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 21 Sep 2015 20:18:02 -0400
Received: by iofb144 with SMTP id b144so1066147iof.1
        for <netdev@vger.kernel.org>; Mon, 21 Sep 2015 17:18:01 -0700 (PDT)
In-Reply-To: <CALx6S37hPDG1FLYXfLJgYcionA2oj+v1dLFaCVoP91qVrUUh7A@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 9/21/15 6:08 PM, Tom Herbert wrote:
>> diff --git a/net/ipv6/datagram.c b/net/ipv6/datagram.c
>> index 9aadd57808a5..11980ee57507 100644
>> --- a/net/ipv6/datagram.c
>> +++ b/net/ipv6/datagram.c
>> @@ -142,6 +142,10 @@ static int __ip6_datagram_connect(struct sock *sk, struct sockaddr *uaddr, int a
>>                          err = -EINVAL;
>>                          goto out;
>>                  }
>> +       } else if (sk->sk_bound_dev_if &&
>> +                  netif_index_is_l3_master(sock_net(sk),
>
> I suppose I have the same issues with this that were put in the IPv4
> code path. Core IPv6 code should not care about any specific network
> interfaces other than maybe loopback. Generalizing VPF to be l3m
> doesn't really address this point. Have you looked at abstracting more
> of this into the ndo functions (i.e. for source address selection) or
> routing lookup?

Socket binding to an interface makes the socket layer care somewhat 
about references to a device. For this case and the ipv4 version the 
flag needs to be set here because of what the connect function means for 
datagram sockets. Once you go down a layer (to L3/routing) there is no 
proper place to add this flag to the lookups.
