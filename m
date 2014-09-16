From: Nicolas Dichtel <nicolas.dichtel@6wind.com>
Subject: Re: [PATCH RFC 1/6] ipv6: also increase fib6_node sernum on deletion
 events
Date: Tue, 16 Sep 2014 18:18:53 +0200
Message-ID: <541862ED.8090600@6wind.com>
References: <cover.1410477596.git.hannes@stressinduktion.org> <4f55afa99da1dab957b2dc5e7b313a1b70f864f3.1410477596.git.hannes@stressinduktion.org>
Reply-To: nicolas.dichtel@6wind.com
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8;
	format=flowed
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Eric Dumazet <eric.dumazet@gmail.com>,
	Vlad Yasevich <vyasevich@gmail.com>
To: Hannes Frederic Sowa <hannes@stressinduktion.org>,
	netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-we0-f178.google.com ([74.125.82.178]:54597 "EHLO
	mail-we0-f178.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754319AbaIPQS4 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 16 Sep 2014 12:18:56 -0400
Received: by mail-we0-f178.google.com with SMTP id q58so84454wes.23
        for <netdev@vger.kernel.org>; Tue, 16 Sep 2014 09:18:55 -0700 (PDT)
In-Reply-To: <4f55afa99da1dab957b2dc5e7b313a1b70f864f3.1410477596.git.hannes@stressinduktion.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Le 12/09/2014 01:21, Hannes Frederic Sowa a =C3=A9crit :
> fib6_add increases the fn_sernum of fib6_nodes while it traverses the
> tree. This serial number is used by ip6_dst_check to judge whether a
> relookup for the socket cache should be done (e.g. a better route is
> available).
>
> We didn't do so for fib6_del, so we missed relookups on ipv6 address
> deletion events. Because this caused trouble in the SCTP stack, inste=
ad
> the genid for ipv6 was bumped. Also TCP connections used old source
> addresses, which were not available anymore.
>
> Because we have static rt6_nodes in the tree (no RTF_GATEWAY,
> RTF_NONEXTHOP nor RTF_CACHE nodes but still DST_HOST) flag, we ended =
up
> in a situation where the genid of the routing node was always smaller
> than the published genid in the namespace. That caused ip6_dst_check =
to
> always discard the current dst_entry and a relookup happend.
>
> This patch prepares for the removal of the ipv6 genid by also modifyi=
ng
> the fn_sernum on route deletion.
>
> Thanks to Eric Dumazet who noticed this problem!
>
> Cc: Eric Dumazet <eric.dumazet@gmail.com>
> Cc: Vlad Yasevich <vyasevich@gmail.com>
> Cc: Nicolas Dichtel <nicolas.dichtel@6wind.com>
> Signed-off-by: Hannes Frederic Sowa <hannes@stressinduktion.org>
This serie looks good to me. Thank you for working on this topic!


Regards,
Nicolas
