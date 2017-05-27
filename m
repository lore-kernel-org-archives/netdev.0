From: Or Gerlitz <gerlitz.or@gmail.com>
Subject: Re: [PATCH net-next 1/4] net/flow_dissector: add support for
 dissection of misc ip header fields
Date: Sat, 27 May 2017 23:56:12 +0300
Message-ID: <CAJ3xEMhpwe9XXDU-6x1MLbAub9tZ6XMfh22zQj3sTshpTejGsQ@mail.gmail.com>
References: <1495718679-20693-1-git-send-email-ogerlitz@mellanox.com>
 <1495718679-20693-2-git-send-email-ogerlitz@mellanox.com> <CALx6S36uJrFA+TO7RDaRAxZi0vuEEc90_TnWP8a2yNP+V3X2qQ@mail.gmail.com>
 <CAJ3xEMgsYi_=0Sv7Wd9GajN5Oym3dKdw3QNDpU9jJR+T6z3Pmw@mail.gmail.com> <CALx6S35LoybyU-NN8RTk4YMOmuOZTkJeZ6GVBnWbX6rtd2uM6Q@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Cc: Or Gerlitz <ogerlitz@mellanox.com>,
        "David S. Miller" <davem@davemloft.net>,
        Linux Kernel Network Developers <netdev@vger.kernel.org>,
        Saeed Mahameed <saeedm@mellanox.com>,
        Roi Dayan <roid@mellanox.com>, Paul Blakey <paulb@mellanox.com>
To: Tom Herbert <tom@herbertland.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-oi0-f46.google.com ([209.85.218.46]:34616 "EHLO
        mail-oi0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1750743AbdE0U4N (ORCPT
        <rfc822;netdev@vger.kernel.org>); Sat, 27 May 2017 16:56:13 -0400
Received: by mail-oi0-f46.google.com with SMTP id b204so45940162oii.1
        for <netdev@vger.kernel.org>; Sat, 27 May 2017 13:56:13 -0700 (PDT)
In-Reply-To: <CALx6S35LoybyU-NN8RTk4YMOmuOZTkJeZ6GVBnWbX6rtd2uM6Q@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sat, May 27, 2017 at 8:18 PM, Tom Herbert <tom@herbertland.com> wrote:

> I think the problem is I don't know what you're dealing with. The only
> thing I can derive from the commit log is that tos and ttl are being
> extracted, but I don't know why they are needed.

The current case for matching on TTL I am dealing with is for using
TC/flower for offloading OVS in flow based VM traffic routing env
(Open-Stack and ODL
DVR - Distributed Virtual Routing) -- where packet headers are
re-written to set the next hop MACs and the TTL is changed. Fields
which are modified are also matched beforhand, and here comes the
matching on TTL.

> I do know this is
> adding complexity to an already overly complex function, and this
> introduces new conditionals and code into the primary use case of
> flow_dissector which is to create a key for deriving skb->hash. I
> don't see that the cost of this patch has been justified.

I hear what you're saying, but part of the rules is that everything to
be offloaded can also be carried out in the kernel SW data-path, so
here comes the touching that area. I have used the minimal foot print
I could and set the code to run in a separate helper called from the
main dissection function.


>> When we did the the flower patches for being able to classify on both
>> the inner and outer fields (say outer src/dst ip, tunnel key) for what
>> related to the  macs/ips/ports/etc -- I don't think we touched the
>> existing dissection, I will look on that to see if I am wrong..
