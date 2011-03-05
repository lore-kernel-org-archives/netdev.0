From: Eduardo Panisset <eduardo.panisset@gmail.com>
Subject: Lacking to initialize "IP6CB(skb)->nhoff" for ipv6 transmission ?
Date: Sat, 5 Mar 2011 00:59:25 -0300
Message-ID: <AANLkTik2JGLJaYiF0uzM8TvQ44GR=OrdJ2mvz-53nS_6@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-vw0-f46.google.com ([209.85.212.46]:50896 "EHLO
	mail-vw0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751061Ab1CED70 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 4 Mar 2011 22:59:26 -0500
Received: by vws12 with SMTP id 12so2559779vws.19
        for <netdev@vger.kernel.org>; Fri, 04 Mar 2011 19:59:25 -0800 (PST)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi,

Im using iptables for marking outgoing packets and then divert them to
specific routing tables.
Whenever a flow matches a rule into mangle table it is marked properly
and reaches over the function ip6_route_me_harder.
That function ends up calling xfrm_decode_session and in particular
_decode_session6 for v6 flows.
The latter uses "IP6CB(skb)->nhoff" for locating nextheader value but
on my debugs it was presenting a weird value (96) instead of the
expected (6), since it was a TCP flow.
So I made the decision of initializing "IP6CB(skb)->nhoff" (with the
value offset(struct ipv6hdr, nexthdr) ) in "ip6_xmit" function and
then the (6) started to be shown and the (96) value did not appeared
anymore.
Is this proceeding correct ? (and then that would be a kernel bug ?)

Rgds,
Eduardo Panisset.
