From: Nicolas Dichtel <nicolas.dichtel@6wind.com>
Subject: Re: [Bug 194749] New: kernel bonding does not work in a network
 nameservice in versions above 3.10.0-229.20.1
Date: Fri, 3 Mar 2017 17:25:10 +0100
Message-ID: <73b3c51a-39f6-2250-a224-e7dca97cb105@6wind.com>
References: <20170302103219.74b675c5@xeon-e3>
 <CAM_iQpVm_WK9X+3Vsm0OrFCOd3Srn-s+xqe9fQtoT=30JZeVJQ@mail.gmail.com>
 <1601587594.2278.1488487199506.JavaMail.zimbra@polter.net>
 <4bd4e7b9-5546-2e85-bb08-42e45a13e1f3@6wind.com>
 <20170303160348.GA1888@nanopsycho.orion>
Reply-To: nicolas.dichtel@6wind.com
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252
Content-Transfer-Encoding: 8bit
Cc: Dan Geist <dan@polter.net>, Cong Wang <xiyou.wangcong@gmail.com>,
        Stephen Hemminger <stephen@networkplumber.org>,
        Linux Kernel Network Developers <netdev@vger.kernel.org>,
        chenweilong@huawei.com, Jiri Pirko <jiri@mellanox.com>
To: Jiri Pirko <jiri@resnulli.us>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wr0-f182.google.com ([209.85.128.182]:33692 "EHLO
        mail-wr0-f182.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751415AbdCCQZZ (ORCPT
        <rfc822;netdev@vger.kernel.org>); Fri, 3 Mar 2017 11:25:25 -0500
Received: by mail-wr0-f182.google.com with SMTP id u48so77151418wrc.0
        for <netdev@vger.kernel.org>; Fri, 03 Mar 2017 08:25:24 -0800 (PST)
In-Reply-To: <20170303160348.GA1888@nanopsycho.orion>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Le 03/03/2017 à 17:03, Jiri Pirko a écrit :
> Fri, Mar 03, 2017 at 04:19:13PM CET, nicolas.dichtel@6wind.com wrote:
>> Le 02/03/2017 à 21:39, Dan Geist a écrit :
[snip]
>>>> NETIF_F_NETNS_LOCAL was introduced for loopback device which
>>>> is created for each netns, it is not clear why we need to add it to bond
>>>> and bridge...
>>>
>>> Thank you for tracking this down. Without digging through the code to figure it out, does this imply that the existence of a bond interface is not possible AT ALL within a netns or simply that it may not be "migrated" between the global scope and a netns?
>> It means that the migration is not possible. I think the only reason to have
>> this flag on bonding and bridge is the lack of test and fix. There is probably
>> some work to be done to have this feature. But are there real use cases of
>> x-netns bonding or x-netns bridge?
> 
> If that use case exists I believe it is an abuse. Soft devices that are
> by definition in upper-lower relationships with other devices should not
> move to other namespaces. Prevents all kinds of issues. If you need a
> soft device like bridge of bond within a namespace, just create it there.
> 
Note that vlan supports x-netns. And I think that the corresponding use cases
are valid ;-)
But I agree that for bonding and bridge it seems wrong.
