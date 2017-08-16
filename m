From: Amine Kherbouche <amine.kherbouche@6wind.com>
Subject: Re: [PATCH 1/2] mpls: add handlers
Date: Wed, 16 Aug 2017 12:24:25 +0200
Message-ID: <c61b8725-3772-0028-52af-65b50fa4273d@6wind.com>
References: <1502396917-14848-1-git-send-email-amine.kherbouche@6wind.com>
 <1502396917-14848-2-git-send-email-amine.kherbouche@6wind.com>
 <20170811123405.GY773745@eidolon>
 <CAJieiUiDN0pk2GDb2+jBQzbjdPTpckSm23SCFGZ9mRHWfQ1H4w@mail.gmail.com>
 <c6fc221b-c0fa-1dbc-d1e2-a746b722dcd7@6wind.com>
 <CAJieiUijsyWjzNL=oFaGxtuos367v0VrpSaEqwHvVacrk5hcTA@mail.gmail.com>
 <20170815093745.GC773745@eidolon>
 <CAJieiUhp57grbrzNcdyJj+_iKp=rusLfrJjsRPfebAUFEqy89A@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8; format=flowed
Content-Transfer-Encoding: 7bit
Cc: "netdev@vger.kernel.org" <netdev@vger.kernel.org>
To: Roopa Prabhu <roopa@cumulusnetworks.com>,
        David Lamparter <equinox@diac24.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wr0-f174.google.com ([209.85.128.174]:35706 "EHLO
        mail-wr0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751643AbdHPKYf (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 16 Aug 2017 06:24:35 -0400
Received: by mail-wr0-f174.google.com with SMTP id 49so2836009wrw.2
        for <netdev@vger.kernel.org>; Wed, 16 Aug 2017 03:24:34 -0700 (PDT)
In-Reply-To: <CAJieiUhp57grbrzNcdyJj+_iKp=rusLfrJjsRPfebAUFEqy89A@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>



On 08/16/2017 07:30 AM, Roopa Prabhu wrote:
> On Tue, Aug 15, 2017 at 2:37 AM, David Lamparter <equinox@diac24.net> wrote:
>
> [snip]
>
>> I think the reverse is the better option, removing the vpls device
>> information and just going with the route table.  My approach to this
>> would be to add a new netlink route attribute "RTA_VPLS" which
>> identifies the vpls device, is stored in the route table, and provides
>> the device ptr needed here.
>> (The control word config should also be on the route.)
>>
>> My reason for thinking this is that the VPLS code needs exactly the same
>> information as does a normal MPLS route:  it attaches to an incoming
>> label (decapsulating packets instead of forwarding them), and for TX it
>> does the same operation of looking up a nexthop (possibly with ECMP
>> support) and adding a label stack.  The code should, in fact, probably
>> reuse the TX path.
>>
>> This also fits both an 1:1 and 1:n model pretty well.  Creating a VPLS
>> head-end netdevice doesn't even need any config.  It'd just work like:
>> - ip link add name vpls123 type vpls
>> - ip -f mpls route add \
>>         1234 \                              # incoming label for decap
>>         vpls vpls123 \                      # new attr: VPLS device
>>         as 2345 via inet 10.0.0.1 dev eth0  # outgoing label for encap
>>
>> For a 1:n model, one would simply add multiple routes on the same vpls
>> device.
>>
>
> this is a nice model too. But, i don't see how vlans and mac based
> learning will fit in here.
>
> modeling it same as how vxlan l2 overlay tunnels are done seems like a
> great fit.
> The vpls driver can learn mac's per pw tunnel labels. And this l2 fdb
> table per vpls device can also carry dst information similar to how
> vxlan driver does today.
>

I think this is a good idea too, I'll implement this concept in mpls and 
have a look at the way vxlan is done to be able to support the l2 part 
in vpls driver.

Thanks
