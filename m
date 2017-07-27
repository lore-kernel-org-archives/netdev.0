From: Roopa Prabhu <roopa@cumulusnetworks.com>
Subject: Re: [PATCHv4 net] ipv6: no need to check rt->dst.error when get route info
Date: Thu, 27 Jul 2017 12:52:37 -0700
Message-ID: <CAJieiUhQfj-ZVNuQc6o_DZTrcZn++BJArhjZsG_m6J0otGPj6A@mail.gmail.com>
References: <1500562286-14312-1-git-send-email-liuhangbin@gmail.com> <1501172736-13685-1-git-send-email-liuhangbin@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Cc: "netdev@vger.kernel.org" <netdev@vger.kernel.org>,
        Cong Wang <xiyou.wangcong@gmail.com>,
        David Ahern <dsahern@gmail.com>
To: Hangbin Liu <liuhangbin@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ua0-f173.google.com ([209.85.217.173]:36530 "EHLO
        mail-ua0-f173.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751597AbdG0Twj (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 27 Jul 2017 15:52:39 -0400
Received: by mail-ua0-f173.google.com with SMTP id k43so112258263uaf.3
        for <netdev@vger.kernel.org>; Thu, 27 Jul 2017 12:52:38 -0700 (PDT)
In-Reply-To: <1501172736-13685-1-git-send-email-liuhangbin@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, Jul 27, 2017 at 9:25 AM, Hangbin Liu <liuhangbin@gmail.com> wrote:
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

Acked-by: Roopa Prabhu <roopa@cumulusnetworks.com>
