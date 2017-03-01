From: David Ahern <dsa@cumulusnetworks.com>
Subject: Re: [Patch net v3] ipv6: check for ip6_null_entry in
 __ip6_del_rt_siblings()
Date: Wed, 1 Mar 2017 15:03:45 -0800
Message-ID: <8a8f59e9-c2b4-d630-4cc7-faf7172773be@cumulusnetworks.com>
References: <1488240463-12000-1-git-send-email-xiyou.wangcong@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252
Content-Transfer-Encoding: 7bit
Cc: andreyknvl@google.com, Eric Dumazet <eric.dumazet@gmail.com>
To: Cong Wang <xiyou.wangcong@gmail.com>, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pg0-f43.google.com ([74.125.83.43]:33700 "EHLO
        mail-pg0-f43.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1753729AbdCAXMy (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 1 Mar 2017 18:12:54 -0500
Received: by mail-pg0-f43.google.com with SMTP id 25so25052376pgy.0
        for <netdev@vger.kernel.org>; Wed, 01 Mar 2017 15:12:54 -0800 (PST)
In-Reply-To: <1488240463-12000-1-git-send-email-xiyou.wangcong@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 2/27/17 4:07 PM, Cong Wang wrote:
> Andrey reported a NULL pointer deref bug in ipv6_route_ioctl()
> -> ip6_route_del() -> __ip6_del_rt_siblings() code path. This is
> because ip6_null_entry is returned in this path since ip6_null_entry
> is kinda default for a ipv6 route table root node. Quote from
> David Ahern:
> 
>  ip6_null_entry is the root of all ipv6 fib tables making it integrated
>  into the table ...
> 
> We should ignore any attempt of trying to delete it, like we do in
> __ip6_del_rt() path and several others.
> 
> Reported-by: Andrey Konovalov <andreyknvl@google.com>
> Fixes: 0ae8133586ad ("net: ipv6: Allow shorthand delete of all nexthops in multipath route")
> Cc: David Ahern <dsa@cumulusnetworks.com>
> Cc: Eric Dumazet <eric.dumazet@gmail.com>
> Signed-off-by: Cong Wang <xiyou.wangcong@gmail.com>
> ---
>  net/ipv6/route.c | 14 +++++++++-----
>  1 file changed, 9 insertions(+), 5 deletions(-)


Acked-by: David Ahern <dsa@cumulusnetworks.com>
