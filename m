From: David Ahern <dsa@cumulusnetworks.com>
Subject: Re: net: GPF in rt6_nexthop_info
Date: Tue, 28 Feb 2017 17:49:20 -0800
Message-ID: <0123e480-d82f-a161-f62f-3fd6f7dec175@cumulusnetworks.com>
References: <CACT4Y+b44zwroCAg8QhNZQ5PX-ObhoKQW6VCFC9rt46JijYPYQ@mail.gmail.com>
 <1488287417.9415.237.camel@edumazet-glaptop3.roam.corp.google.com>
 <1a390cbd-1d99-a739-ed94-e0c9d1eecb4a@cumulusnetworks.com>
 <CANn89iK3qKO6-rr+pNwuk7p--SB9a1sjar00TRN=T_uuh+QZuw@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 7bit
Cc: Eric Dumazet <eric.dumazet@gmail.com>,
        Dmitry Vyukov <dvyukov@google.com>,
        David Miller <davem@davemloft.net>,
        Hideaki YOSHIFUJI <yoshfuji@linux-ipv6.org>,
        netdev <netdev@vger.kernel.org>,
        LKML <linux-kernel@vger.kernel.org>,
        Cong Wang <xiyou.wangcong@gmail.com>,
        Yuchung Cheng <ycheng@google.com>,
        Willem de Bruijn <willemb@google.com>,
        syzkaller <syzkaller@googlegroups.com>
To: Eric Dumazet <edumazet@google.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pg0-f44.google.com ([74.125.83.44]:35916 "EHLO
        mail-pg0-f44.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751435AbdCAB6Y (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 28 Feb 2017 20:58:24 -0500
Received: by mail-pg0-f44.google.com with SMTP id s67so13899298pgb.3
        for <netdev@vger.kernel.org>; Tue, 28 Feb 2017 17:58:21 -0800 (PST)
In-Reply-To: <CANn89iK3qKO6-rr+pNwuk7p--SB9a1sjar00TRN=T_uuh+QZuw@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 2/28/17 3:14 PM, Eric Dumazet wrote:
> On Tue, Feb 28, 2017 at 3:09 PM, David Ahern <dsa@cumulusnetworks.com> wrote:
>> On 2/28/17 5:10 AM, Eric Dumazet wrote:
>>> David, rt->rt6i_idev can be NULL.
>>
>> Do you know of an example where rt6i_idev can be NULL - besides the
>> null_entry rt which is null only because of init order?
> 
> 
> I might have been mistaken, but many points in net/ipv6/route.c test
> rt->rt6i_idev being NULL or not before dereferencing it.
> 
> Maybe other rts (other than null_entry) share this property.
> 

Seen those and always been confused that an L3 route object does not
require the L3 addr struct for the device.

Code wise the struct is allocated for all net devices at registration as
long as mtu >= 1280. If it is not allocated, routes referencing the
device fail with ENODEV (idev check in ip6_route_info_create). Putting
that together I can't see how a standard ipv6 rt other than the
null_entry can reference a null rt6i_idev.
