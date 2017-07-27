From: David Ahern <dsahern@gmail.com>
Subject: Re: [PATCHv4 net] ipv6: no need to check rt->dst.error when get route
 info
Date: Thu, 27 Jul 2017 12:03:02 -0600
Message-ID: <9e5d3137-c84d-91f7-6c82-813519964513@gmail.com>
References: <1500562286-14312-1-git-send-email-liuhangbin@gmail.com>
 <1501172736-13685-1-git-send-email-liuhangbin@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252
Content-Transfer-Encoding: 7bit
Cc: Cong Wang <xiyou.wangcong@gmail.com>,
        Roopa Prabhu <roopa@cumulusnetworks.com>
To: Hangbin Liu <liuhangbin@gmail.com>, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pf0-f176.google.com ([209.85.192.176]:32859 "EHLO
        mail-pf0-f176.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751671AbdG0SDK (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 27 Jul 2017 14:03:10 -0400
Received: by mail-pf0-f176.google.com with SMTP id d67so18467779pfc.0
        for <netdev@vger.kernel.org>; Thu, 27 Jul 2017 11:03:10 -0700 (PDT)
In-Reply-To: <1501172736-13685-1-git-send-email-liuhangbin@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 7/27/17 10:25 AM, Hangbin Liu wrote:
> After commit 18c3a61c4264 ("net: ipv6: RTM_GETROUTE: return matched fib
> result when requested"). When we get a prohibit ertry, we will return
> -EACCES directly instead of dump route info.
> 
> Fix it by remove the rt->dst.error check.
> 
> Before fix:
> \# ip -6 route add prohibit 2003::/64 dev eth1
> \# ip -6 route get fibmatch 2003::1
> RTNETLINK answers: Permission denied
> \# ip -6 route add unreachable 2004::/64 dev eth1
> \# ip -6 route get fibmatch 2004::1
> RTNETLINK answers: No route to host
> 
> After fix:
> \# ip -6 route add prohibit 2003::/64 dev eth1
> \# ip -6 route get fibmatch 2003::1
> prohibit 2003::/64 dev lo metric 1024 error -13 pref medium
> \# ip -6 route add unreachable 2004::/64 dev eth1
> \# ip -6 route get fibmatch 2004::1
> unreachable 2004::/64 dev lo metric 1024 error -113 pref medium
> 
> Fixes: 18c3a61c4264 ("net: ipv6: RTM_GETROUTE: return matched fib...")
> Signed-off-by: Hangbin Liu <liuhangbin@gmail.com>
> ---
>  net/ipv6/route.c | 6 ------
>  1 file changed, 6 deletions(-)
> 

Acked-by: David Ahern <dsahern@gmail.com>
