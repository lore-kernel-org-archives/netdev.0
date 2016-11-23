From: Alexei Starovoitov <alexei.starovoitov@gmail.com>
Subject: Re: [PATCH net-next 1/1] ipv6: sr: add option to control lwtunnel support
Date: Tue, 22 Nov 2016 16:16:09 -0800
Message-ID: <CAADnVQ+MdPeZv1FpzD=omH1ftr2vW3uYiqdLL3Y_teaZj=tEbQ@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: david.lebrun@uclouvain.be,
        "netdev@vger.kernel.org" <netdev@vger.kernel.org>,
        Lorenzo Colitti <lorenzo@google.com>,
        Roopa Prabhu <roopa@cumulusnetworks.com>,
        Eric Dumazet <eric.dumazet@gmail.com>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wm0-f43.google.com ([74.125.82.43]:35209 "EHLO
        mail-wm0-f43.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751245AbcKWAQc (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 22 Nov 2016 19:16:32 -0500
Received: by mail-wm0-f43.google.com with SMTP id a197so52577115wmd.0
        for <netdev@vger.kernel.org>; Tue, 22 Nov 2016 16:16:31 -0800 (PST)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, Nov 16, 2016 at 8:32 AM, David Miller <davem@davemloft.net> wrote:
> From: David Lebrun <david.lebrun@uclouvain.be>
> Date: Tue, 15 Nov 2016 16:14:04 +0100
>
>> This patch adds a new option CONFIG_IPV6_SEG6_LWTUNNEL to enable/disable
>> support of encapsulation with the lightweight tunnels. When this option
>> is enabled, CONFIG_LWTUNNEL is automatically selected.
>>
>> Fix commit 6c8702c60b88 ("ipv6: sr: add support for SRH encapsulation and injection with lwtunnels")
>>
>> Without a proper option to control lwtunnel support for SR-IPv6, if
>> CONFIG_LWTUNNEL=n then the IPv6 initialization fails as a consequence
>> of seg6_iptunnel_init() failure with EOPNOTSUPP:
>>
>> NET: Registered protocol family 10
>> IPv6: Attempt to unregister permanent protocol 6
>> IPv6: Attempt to unregister permanent protocol 136
>> IPv6: Attempt to unregister permanent protocol 17
>> NET: Unregistered protocol family 10
>>
>> Tested (compiling, booting, and loading ipv6 module when relevant)
>> with possible combinations of CONFIG_IPV6={y,m,n},
>> CONFIG_IPV6_SEG6_LWTUNNEL={y,n} and CONFIG_LWTUNNEL={y,n}.
>>
>> Reported-by: Lorenzo Colitti <lorenzo@google.com>
>> Suggested-by: Roopa Prabhu <roopa@cumulusnetworks.com>
>> Signed-off-by: David Lebrun <david.lebrun@uclouvain.be>
>
> Applied.

ipv6 seems to be still broken in the latest net-next
when CONFIG_LWTUNNEL is not set:
# ping 127.0.0.1
ping: socket: Address family not supported by protocol
# ping -4 127.0.0.1
PING localhost.localdomain (127.0.0.1) 56(84) bytes of data.
64 bytes from localhost.localdomain (127.0.0.1): icmp_seq=1 ttl=64 time=0.067 ms

it works with CONFIG_LWTUNNEL=y

Roopa, David, please take a look.

Thanks!
