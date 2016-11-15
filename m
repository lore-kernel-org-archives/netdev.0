From: David Miller <davem@redhat.com>
Subject: Re: [PATCH] icmp: Restore resistence to abnormal messages
Date: Tue, 15 Nov 2016 11:56:57 -0500 (EST)
Message-ID: <20161115.115657.798577230951109692.davem@redhat.com>
References: <20161111202018.13795-1-googuy@gmail.com>
        <20161114.133646.1687576478968660327.davem@davemloft.net>
        <CAO1wt+b4OkJ4DmJ7_hUj_oKj4p_rRMuKUVpiBY7MSFMa=0WKQg@mail.gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=iso-8859-1
Content-Transfer-Encoding: 8BIT
Cc: kuznet@ms2.inr.ac.ru, jmorris@namei.org, yoshfuji@linux-ipv6.org,
        kaber@trash.net, netdev@vger.kernel.org,
        linux-kernel@vger.kernel.org
To: googuy@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:36486 "EHLO mx1.redhat.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1752176AbcKOQ5C (ORCPT <rfc822;netdev@vger.kernel.org>);
        Tue, 15 Nov 2016 11:57:02 -0500
In-Reply-To: <CAO1wt+b4OkJ4DmJ7_hUj_oKj4p_rRMuKUVpiBY7MSFMa=0WKQg@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Vicente Jiménez <googuy@gmail.com>
Date: Tue, 15 Nov 2016 17:49:43 +0100

> On Mon, Nov 14, 2016 at 7:36 PM, David Miller <davem@davemloft.net> wrote:
>> From: Vicente Jimenez Aguilar <googuy@gmail.com>
>> Date: Fri, 11 Nov 2016 21:20:18 +0100
>>
>>> @@ -819,6 +820,12 @@ static bool icmp_unreach(struct sk_buff *skb)
>>>                               /* fall through */
>>>                       case 0:
>>>                               info = ntohs(icmph->un.frag.mtu);
>>> +                             /* Handle weird case where next hop MTU is
>>> +                              * equal to or exceeding dropped packet size
>>> +                              */
>>> +                             old_mtu = ntohs(iph->tot_len);
>>> +                             if (info >= old_mtu)
>>> +                                     info = old_mtu - 2;
>>
>> This isn't something the old code did.
>>
>> The old code behaved much differently.
>>
> I don't wanted to restore old behavior just fix a strange case that
> was handle by this code where the next hop MTU reported by the router
> is equal or greater than the actual path MTU. Because router
> information is wrong, we need a way to guess a good packet size
> ignoring router data. The simplest strategy that avoid odd numbers is
> reducing dropped packet size by 2.

This whole approach seems arbitrary.

You haven't discussed in any way, what causes this in the first place.
And what about that cause makes simply subtracting by 2 work well or
not.

You have a very locallized, specific, situation on your end you want
to fix.  But we must accept changes that handle things generically and
in a way that would help more than just your specific case.
