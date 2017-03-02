From: David Miller <davem@davemloft.net>
Subject: Re: [Patch net v3] ipv6: check for ip6_null_entry in
 __ip6_del_rt_siblings()
Date: Thu, 02 Mar 2017 12:45:03 -0800 (PST)
Message-ID: <20170302.124503.746554950603549261.davem@davemloft.net>
References: <1488240463-12000-1-git-send-email-xiyou.wangcong@gmail.com>
        <8a8f59e9-c2b4-d630-4cc7-faf7172773be@cumulusnetworks.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: xiyou.wangcong@gmail.com, netdev@vger.kernel.org,
        andreyknvl@google.com, eric.dumazet@gmail.com
To: dsa@cumulusnetworks.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:38250 "EHLO
        shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751016AbdCBUyV (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 2 Mar 2017 15:54:21 -0500
In-Reply-To: <8a8f59e9-c2b4-d630-4cc7-faf7172773be@cumulusnetworks.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: David Ahern <dsa@cumulusnetworks.com>
Date: Wed, 1 Mar 2017 15:03:45 -0800

> On 2/27/17 4:07 PM, Cong Wang wrote:
>> Andrey reported a NULL pointer deref bug in ipv6_route_ioctl()
>> -> ip6_route_del() -> __ip6_del_rt_siblings() code path. This is
>> because ip6_null_entry is returned in this path since ip6_null_entry
>> is kinda default for a ipv6 route table root node. Quote from
>> David Ahern:
>> 
>>  ip6_null_entry is the root of all ipv6 fib tables making it integrated
>>  into the table ...
>> 
>> We should ignore any attempt of trying to delete it, like we do in
>> __ip6_del_rt() path and several others.
>> 
>> Reported-by: Andrey Konovalov <andreyknvl@google.com>
>> Fixes: 0ae8133586ad ("net: ipv6: Allow shorthand delete of all nexthops in multipath route")
>> Cc: David Ahern <dsa@cumulusnetworks.com>
>> Cc: Eric Dumazet <eric.dumazet@gmail.com>
>> Signed-off-by: Cong Wang <xiyou.wangcong@gmail.com>
>> ---
>>  net/ipv6/route.c | 14 +++++++++-----
>>  1 file changed, 9 insertions(+), 5 deletions(-)
> 
> 
> Acked-by: David Ahern <dsa@cumulusnetworks.com>

Applied, thanks.
