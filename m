From: David Ahern <dsahern@gmail.com>
Subject: Re: [Patch net v2] ipv6: reorder ip6_route_dev_notifier after
 ipv6_dev_notf
Date: Thu, 4 May 2017 13:41:15 -0600
Message-ID: <11c2aeb4-cf2c-eded-0e56-789da2ba55ee@gmail.com>
References: <1493919363-19989-1-git-send-email-xiyou.wangcong@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252
Content-Transfer-Encoding: 7bit
Cc: andreyknvl@google.com
To: Cong Wang <xiyou.wangcong@gmail.com>, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pg0-f66.google.com ([74.125.83.66]:34471 "EHLO
        mail-pg0-f66.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751375AbdEDTlT (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 4 May 2017 15:41:19 -0400
Received: by mail-pg0-f66.google.com with SMTP id u187so1459199pgb.1
        for <netdev@vger.kernel.org>; Thu, 04 May 2017 12:41:18 -0700 (PDT)
In-Reply-To: <1493919363-19989-1-git-send-email-xiyou.wangcong@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 5/4/17 11:36 AM, Cong Wang wrote:
> For each netns (except init_net), we initialize its null entry
> in 3 places:
> 
> 1) The template itself, as we use kmemdup()
> 2) Code around dst_init_metrics() in ip6_route_net_init()
> 3) ip6_route_dev_notify(), which is supposed to initialize it after
>    loopback registers
> 
> Unfortunately the last one still happens in a wrong order because
> we expect to initialize net->ipv6.ip6_null_entry->rt6i_idev to
> net->loopback_dev's idev, so we have to do that after we add
> idev to it. However, this notifier has priority == 0 same as
> ipv6_dev_notf, and ipv6_dev_notf is registered after
> ip6_route_dev_notifier so it is called actually after
> ip6_route_dev_notifier.
> 
> Fix it by picking a smaller priority for ip6_route_dev_notifier.
> Also, we have to release the refcnt accordingly when unregistering
> loopback_dev because device exit functions are called before subsys
> exit functions.
> 
> Cc: David Ahern <dsahern@gmail.com>
> Signed-off-by: Cong Wang <xiyou.wangcong@gmail.com>
> ---

Commit message needs a tie in to the problem that Andrey reported. It
solves the same problem for namespaces other than init_net.

Acked-by: David Ahern <dsahern@gmail.com>
Tested-by: David Ahern <dsahern@gmail.com>
