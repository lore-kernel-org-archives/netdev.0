From: Hannes Frederic Sowa <hannes@stressinduktion.org>
Subject: Re: [PATCH RFC 1/6] ipv6: also increase fib6_node sernum on
 deletion events
Date: Tue, 16 Sep 2014 23:05:50 +0200
Message-ID: <1410901550.32691.18.camel@localhost>
References: <cover.1410477596.git.hannes@stressinduktion.org>
	 <4f55afa99da1dab957b2dc5e7b313a1b70f864f3.1410477596.git.hannes@stressinduktion.org>
	 <541862ED.8090600@6wind.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org, Eric Dumazet <eric.dumazet@gmail.com>,
	Vlad Yasevich <vyasevich@gmail.com>
To: nicolas.dichtel@6wind.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from out1-smtp.messagingengine.com ([66.111.4.25]:36399 "EHLO
	out1-smtp.messagingengine.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1753210AbaIPVFy (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 16 Sep 2014 17:05:54 -0400
Received: from compute3.internal (compute3.nyi.internal [10.202.2.43])
	by gateway2.nyi.internal (Postfix) with ESMTP id 800FC206E8
	for <netdev@vger.kernel.org>; Tue, 16 Sep 2014 17:05:53 -0400 (EDT)
In-Reply-To: <541862ED.8090600@6wind.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Di, 2014-09-16 at 18:18 +0200, Nicolas Dichtel wrote:
> Le 12/09/2014 01:21, Hannes Frederic Sowa a =C3=A9crit :
> > fib6_add increases the fn_sernum of fib6_nodes while it traverses t=
he
> > tree. This serial number is used by ip6_dst_check to judge whether =
a
> > relookup for the socket cache should be done (e.g. a better route i=
s
> > available).
> >
> > We didn't do so for fib6_del, so we missed relookups on ipv6 addres=
s
> > deletion events. Because this caused trouble in the SCTP stack, ins=
tead
> > the genid for ipv6 was bumped. Also TCP connections used old source
> > addresses, which were not available anymore.
> >
> > Because we have static rt6_nodes in the tree (no RTF_GATEWAY,
> > RTF_NONEXTHOP nor RTF_CACHE nodes but still DST_HOST) flag, we ende=
d up
> > in a situation where the genid of the routing node was always small=
er
> > than the published genid in the namespace. That caused ip6_dst_chec=
k to
> > always discard the current dst_entry and a relookup happend.
> >
> > This patch prepares for the removal of the ipv6 genid by also modif=
ying
> > the fn_sernum on route deletion.
> >
> > Thanks to Eric Dumazet who noticed this problem!
> >
> > Cc: Eric Dumazet <eric.dumazet@gmail.com>
> > Cc: Vlad Yasevich <vyasevich@gmail.com>
> > Cc: Nicolas Dichtel <nicolas.dichtel@6wind.com>
> > Signed-off-by: Hannes Frederic Sowa <hannes@stressinduktion.org>
> This serie looks good to me. Thank you for working on this topic!

Thanks a lot for your review, Nicolas! I'll do some more build tests I
got all the module handling correct and will send the formal submission=
=2E

Bye,
Hannes
