From: YOSHIFUJI Hideaki <hideaki.yoshifuji@miraclelinux.com>
Subject: Re: icmpv6: issue with routing table entries from link local
 addresses
Date: Tue, 13 Sep 2016 12:01:18 +0900
Message-ID: <4986ff01-5157-390c-7d58-764e17b67322@miraclelinux.com>
References: <20160912142732.GI26782@targo.k4n.de>
 <b6804e09-403f-64ff-257b-6c5fda7f8047@stressinduktion.org>
 <CACP96tTFX7nyGz6uARYxemvE7-WDxvX7Wj+Jf95PC0Advy7ynw@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 8bit
Cc: hideaki.yoshifuji@miraclelinux.com,
        =?UTF-8?Q?Andreas_H=c3=bcbner?= <andreas@k4n.de>,
        netdev <netdev@vger.kernel.org>,
        "d. caratti" <davide.caratti@gmail.com>,
        Sowmini Varadhan <sowmini.varadhan@oracle.com>
To: Sowmini Varadhan <sowmini05@gmail.com>,
        Hannes Frederic Sowa <hannes@stressinduktion.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pf0-f172.google.com ([209.85.192.172]:33711 "EHLO
        mail-pf0-f172.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1750953AbcIMDBX (ORCPT
        <rfc822;netdev@vger.kernel.org>); Mon, 12 Sep 2016 23:01:23 -0400
Received: by mail-pf0-f172.google.com with SMTP id g202so58836862pfb.0
        for <netdev@vger.kernel.org>; Mon, 12 Sep 2016 20:01:22 -0700 (PDT)
In-Reply-To: <CACP96tTFX7nyGz6uARYxemvE7-WDxvX7Wj+Jf95PC0Advy7ynw@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Sowmini Varadhan wrote:
> On Mon, Sep 12, 2016 at 1:26 PM, Hannes Frederic Sowa
> <hannes@stressinduktion.org> wrote:
>> Hello,
>>
>> On 12.09.2016 16:27, Andreas Hübner wrote:
> 
>>>
>>> I have the following setup:
>>>   - 2 directly connected hosts (A+B), both have only link local addresses
>>>     configured (interface on both hosts is eth0)
>            :
>>>       fe80::/64 dev eth1  proto kernel  metric 256
>>>       fe80::/64 dev eth0  proto kernel  metric 256
>            :
>>> The issue I currently have is, that the echo reply that host B should
>>> generate is never sent back to host A. If I change the order of the
>>> routing table entries on host B, everything works fine.
>>> (host A is connected on eth0)
>    :
>> This shouldn't be the case. We certainly carry over the ifindex of the
>> received packet into the routing lookup of the outgoing packet, thus the
>> appropriate rule, with outgoing ifindex should be selected.
> 
> Like Hannes,  I too would first check "is B sending out the echo-resp? on
> which interface?".
> 
> But a couple of unexpected things I noticed in linux: the link-local
> prefix should have a prefixlen of /10 according to
> http://www.iana.org/assignments/ipv6-address-space/ipv6-address-space.xhtml
> but "ip -6 route show"  lists this as a /64..

Do not be confused; link-local address for ethernet is described by
IPv6 over FOO document (e.g., RFC2464 for Ethernet).  The address
(fe80::/64 for Ethernet, for example) is defined inside the link-local
scope unicast address space (/10).

-- 
Hideaki Yoshifuji <hideaki.yoshifuji@miraclelinux.com>
Technical Division, MIRACLE LINUX CORPORATION
