From: David Ahern <dsahern@gmail.com>
Subject: Re: [PATCH net-next v2] net: ipv6: avoid overhead when no custom FIB
 rules are installed
Date: Tue, 8 Aug 2017 13:10:53 -0600
Message-ID: <c71be279-2482-0f3c-720e-8c4da4dd3520@gmail.com>
References: <66e3d00a-6788-2e86-9563-fc1424a6a250@gmail.com>
 <20170808182349.4987-1-vincent@bernat.im>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 7bit
To: Vincent Bernat <vincent@bernat.im>,
        "David S. Miller" <davem@davemloft.net>,
        Alexey Kuznetsov <kuznet@ms2.inr.ac.ru>,
        Hideaki YOSHIFUJI <yoshfuji@linux-ipv6.org>,
        Jiri Pirko <jiri@mellanox.com>, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pg0-f68.google.com ([74.125.83.68]:34198 "EHLO
        mail-pg0-f68.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751833AbdHHTLB (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 8 Aug 2017 15:11:01 -0400
Received: by mail-pg0-f68.google.com with SMTP id y192so3861070pgd.1
        for <netdev@vger.kernel.org>; Tue, 08 Aug 2017 12:11:01 -0700 (PDT)
In-Reply-To: <20170808182349.4987-1-vincent@bernat.im>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 8/8/17 12:23 PM, Vincent Bernat wrote:
> If the user hasn't installed any custom rules, don't go through the
> whole FIB rules layer. This is pretty similar to f4530fa574df (ipv4:
> Avoid overhead when no custom FIB rules are installed).
> 
> Using a micro-benchmark module [1], timing ip6_route_output() with
> get_cycles(), with 40,000 routes in the main routing table, before this
> patch:
...
> At the frequency of the host during the bench (~ 3.7 GHz), this is
> about a 100 ns difference on the median value.
> 
> A next step would be to collapse local and main tables, as in
> 0ddcf43d5d4a (ipv4: FIB Local/MAIN table collapse).
> 
> [1]: https://github.com/vincentbernat/network-lab/blob/master/lab-routes-ipv6/kbench_mod.c
> 
> Signed-off-by: Vincent Bernat <vincent@bernat.im>
> Reviewed-by: Jiri Pirko <jiri@mellanox.com>
> ---
>  include/net/netns/ipv6.h |  1 +
>  net/ipv6/fib6_rules.c    | 40 +++++++++++++++++++++++++++-------------
>  net/ipv6/route.c         |  1 +
>  3 files changed, 29 insertions(+), 13 deletions(-)
> 

LGTM.

Acked-by: David Ahern <dsahern@gmail.com>
