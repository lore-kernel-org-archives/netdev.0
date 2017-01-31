From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] rtnetlink: Handle IFLA_MASTER parameter when
 processing rtnl_newlink
Date: Tue, 31 Jan 2017 15:49:22 -0500 (EST)
Message-ID: <20170131.154922.106030849115718252.davem@davemloft.net>
References: <20170130232346.29761-1-theuns.verwoerd@alliedtelesis.co.nz>
        <CAM_iQpW1+UK+ykB3s-yqi+ozR-BuRTvQ6hX1XmkMvAXSWEgkrg@mail.gmail.com>
        <6a71762b-3e3b-06e6-9b9b-9b00cdbb2cf8@cumulusnetworks.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: xiyou.wangcong@gmail.com, theuns.verwoerd@alliedtelesis.co.nz,
        netdev@vger.kernel.org
To: dsa@cumulusnetworks.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:46920 "EHLO
        shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1750807AbdAaUta (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 31 Jan 2017 15:49:30 -0500
In-Reply-To: <6a71762b-3e3b-06e6-9b9b-9b00cdbb2cf8@cumulusnetworks.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: David Ahern <dsa@cumulusnetworks.com>
Date: Tue, 31 Jan 2017 13:25:32 -0700

> On 1/30/17 11:49 PM, Cong Wang wrote:
>> On Mon, Jan 30, 2017 at 3:23 PM, Theuns Verwoerd
>> <theuns.verwoerd@alliedtelesis.co.nz> wrote:
>>> @@ -2653,6 +2653,11 @@ static int rtnl_newlink(struct sk_buff *skb, struct nlmsghdr *nlh)
>>>                         if (err < 0)
>>>                                 goto out_unregister;
>>>                 }
>>> +               if (tb[IFLA_MASTER]) {
>>> +                       err = do_set_master(dev, nla_get_u32(tb[IFLA_MASTER]));
>>> +                       if (err)
>>> +                               goto out_unregister;
>>> +               }
>>>  out:
>>>                 if (link_net)
>>>                         put_net(link_net);
>> 
>> Not sure if it is too late to call do_set_master() after
>> dev_change_net_namespace().
>> 
> 
> The master device index is relative to a namespace. If both are given then the namespace change must be done first.

Right and this is exactly how do_setlink() handles this.
