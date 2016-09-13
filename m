From: Sowmini Varadhan <sowmini05@gmail.com>
Subject: Re: icmpv6: issue with routing table entries from link local addresses
Date: Mon, 12 Sep 2016 22:03:55 -0400
Message-ID: <CACP96tTFX7nyGz6uARYxemvE7-WDxvX7Wj+Jf95PC0Advy7ynw@mail.gmail.com>
References: <20160912142732.GI26782@targo.k4n.de> <b6804e09-403f-64ff-257b-6c5fda7f8047@stressinduktion.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: quoted-printable
Cc: =?UTF-8?Q?Andreas_H=C3=BCbner?= <andreas@k4n.de>,
        netdev <netdev@vger.kernel.org>,
        "d. caratti" <davide.caratti@gmail.com>,
        Sowmini Varadhan <sowmini.varadhan@oracle.com>
To: Hannes Frederic Sowa <hannes@stressinduktion.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-oi0-f47.google.com ([209.85.218.47]:33530 "EHLO
        mail-oi0-f47.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1752778AbcIMCD5 (ORCPT
        <rfc822;netdev@vger.kernel.org>); Mon, 12 Sep 2016 22:03:57 -0400
Received: by mail-oi0-f47.google.com with SMTP id y2so352624881oie.0
        for <netdev@vger.kernel.org>; Mon, 12 Sep 2016 19:03:56 -0700 (PDT)
In-Reply-To: <b6804e09-403f-64ff-257b-6c5fda7f8047@stressinduktion.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, Sep 12, 2016 at 1:26 PM, Hannes Frederic Sowa
<hannes@stressinduktion.org> wrote:
> Hello,
>
> On 12.09.2016 16:27, Andreas H=C3=BCbner wrote:

>>
>> I have the following setup:
>>   - 2 directly connected hosts (A+B), both have only link local addresse=
s
>>     configured (interface on both hosts is eth0)
           :
>>       fe80::/64 dev eth1  proto kernel  metric 256
>>       fe80::/64 dev eth0  proto kernel  metric 256
           :
>> The issue I currently have is, that the echo reply that host B should
>> generate is never sent back to host A. If I change the order of the
>> routing table entries on host B, everything works fine.
>> (host A is connected on eth0)
   :
> This shouldn't be the case. We certainly carry over the ifindex of the
> received packet into the routing lookup of the outgoing packet, thus the
> appropriate rule, with outgoing ifindex should be selected.

Like Hannes,  I too would first check "is B sending out the echo-resp? on
which interface?".

But a couple of unexpected things I noticed in linux: the link-local
prefix should have a prefixlen of /10 according to
http://www.iana.org/assignments/ipv6-address-space/ipv6-address-space.xhtml
but "ip -6 route show"  lists this as a /64..

moreover, even though I cannot use "ip [-6] route add.." to add the
same prefix multiple times (with different nexthop and/or interface)
unless I explicitly mark them as ECMP with /sbin/ip, it seems like you
can create the same onlink prefix on multiple interfaces, but the
kernel will not treat this as an ECMP group (and sometimes this
can produce inconsistent results depending on the order of
route addition, e.g., for ipv4 rp_filter checks). I dont know if some
variant of  this (latter observation) may be the reason for the behavior
that  Andreas reports.

--Sowmini
