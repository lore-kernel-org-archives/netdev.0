From: Or Gerlitz <gerlitz.or@gmail.com>
Subject: Re: [PATCH net-next 1/4] net/flow_dissector: add support for
 dissection of misc ip header fields
Date: Sat, 27 May 2017 19:29:49 +0300
Message-ID: <CAJ3xEMgfOO4fvR3OGdQC0hSZDKyDWy=yEuYA-jW0qd-girV3yw@mail.gmail.com>
References: <1495718679-20693-1-git-send-email-ogerlitz@mellanox.com>
 <1495718679-20693-2-git-send-email-ogerlitz@mellanox.com> <CALx6S379RzD+t=mDHgs+u-BrWgd7Jt4W_C-kNarA7t+HwEJ3jQ@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Cc: Or Gerlitz <ogerlitz@mellanox.com>,
        "David S. Miller" <davem@davemloft.net>,
        Linux Kernel Network Developers <netdev@vger.kernel.org>,
        Saeed Mahameed <saeedm@mellanox.com>,
        Roi Dayan <roid@mellanox.com>, Paul Blakey <paulb@mellanox.com>
To: Tom Herbert <tom@herbertland.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-oi0-f41.google.com ([209.85.218.41]:35252 "EHLO
        mail-oi0-f41.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1750714AbdE0Q3v (ORCPT
        <rfc822;netdev@vger.kernel.org>); Sat, 27 May 2017 12:29:51 -0400
Received: by mail-oi0-f41.google.com with SMTP id l18so42881320oig.2
        for <netdev@vger.kernel.org>; Sat, 27 May 2017 09:29:50 -0700 (PDT)
In-Reply-To: <CALx6S379RzD+t=mDHgs+u-BrWgd7Jt4W_C-kNarA7t+HwEJ3jQ@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, May 25, 2017 at 6:42 PM, Tom Herbert <tom@herbertland.com> wrote:
> On Thu, May 25, 2017 at 6:24 AM, Or Gerlitz <ogerlitz@mellanox.com> wrote:
>> Add support for dissection of ip tos and ttl and ipv6 traffic-class
>> and hoplimit. Both are dissected into the same struct.

>> --- a/include/net/flow_dissector.h
>> +++ b/include/net/flow_dissector.h

>> +/**
>> + * struct flow_dissector_key_ip:
>> + * @tos: tos
>> + * @ttl: ttl
>> + */
>> +struct flow_dissector_key_ip {
>> +       __u8    tos;
>> +       __u8    ttl;
>> +};
>> +

> Looks like yet more complexity be piled onto flow dissector. Instead
> of splitting out individual fields can we just return a pointer to the
> IP header and let the caller extract the fields they're interested in?

Do you mean that struct flow_dissector_key_ip  will only contain
(union?) const struct iphdr * and const struct ipv6hdr * ? I wasn't
sure how would that further look on the kernel SW classification path
(the non offloaded case)
