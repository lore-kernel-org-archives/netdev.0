From: David Miller <davem@davemloft.net>
Subject: Re: [Patch net v2] ipv6: reorder ip6_route_dev_notifier after
 ipv6_dev_notf
Date: Mon, 08 May 2017 11:37:47 -0400 (EDT)
Message-ID: <20170508.113747.1274183761621757735.davem@davemloft.net>
References: <1493919363-19989-1-git-send-email-xiyou.wangcong@gmail.com>
        <11c2aeb4-cf2c-eded-0e56-789da2ba55ee@gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: xiyou.wangcong@gmail.com, netdev@vger.kernel.org,
        andreyknvl@google.com
To: dsahern@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:57642 "EHLO
        shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1750803AbdEHPhs (ORCPT
        <rfc822;netdev@vger.kernel.org>); Mon, 8 May 2017 11:37:48 -0400
In-Reply-To: <11c2aeb4-cf2c-eded-0e56-789da2ba55ee@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: David Ahern <dsahern@gmail.com>
Date: Thu, 4 May 2017 13:41:15 -0600

> On 5/4/17 11:36 AM, Cong Wang wrote:
>> For each netns (except init_net), we initialize its null entry
>> in 3 places:
>> 
>> 1) The template itself, as we use kmemdup()
>> 2) Code around dst_init_metrics() in ip6_route_net_init()
>> 3) ip6_route_dev_notify(), which is supposed to initialize it after
>>    loopback registers
>> 
>> Unfortunately the last one still happens in a wrong order because
>> we expect to initialize net->ipv6.ip6_null_entry->rt6i_idev to
>> net->loopback_dev's idev, so we have to do that after we add
>> idev to it. However, this notifier has priority == 0 same as
>> ipv6_dev_notf, and ipv6_dev_notf is registered after
>> ip6_route_dev_notifier so it is called actually after
>> ip6_route_dev_notifier.
>> 
>> Fix it by picking a smaller priority for ip6_route_dev_notifier.
>> Also, we have to release the refcnt accordingly when unregistering
>> loopback_dev because device exit functions are called before subsys
>> exit functions.
>> 
>> Cc: David Ahern <dsahern@gmail.com>
>> Signed-off-by: Cong Wang <xiyou.wangcong@gmail.com>
>> ---
> 
> Commit message needs a tie in to the problem that Andrey reported. It
> solves the same problem for namespaces other than init_net.

Cong, please update the commit message as David is requesting.

Thanks.
