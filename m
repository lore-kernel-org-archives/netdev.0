From: Ulrich Weber <uweber@astaro.com>
Subject: Re: [RFC PATCH] dont create cached routes from ARP requests
Date: Mon, 27 Sep 2010 15:11:47 +0200
Message-ID: <4CA09813.6090707@astaro.com>
References: <20100922162209.GA10281@babylon>	 <20100922.203442.233700254.davem@davemloft.net>	 <20100923144708.GA8037@babylon> <1285254302.2509.47.camel@edumazet-laptop>	 <4C9CBCFC.6080300@gmail.com> <1285342083.2503.252.camel@edumazet-laptop>	 <4C9CC608.7010401@astaro.com> <1285344352.2503.321.camel@edumazet-laptop>	 <4C9CD466.4010909@astaro.com> <1285347509.2503.357.camel@edumazet-laptop>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: David Miller <davem@davemloft.net>, netdev@vger.kernel.org
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from exsmtpd002-2.dex002.intermedia.net ([64.78.19.134]:10315 "EHLO
	EXSMTPD002-2.dex002.intermedia.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1759301Ab0I0N1C (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 27 Sep 2010 09:27:02 -0400
In-Reply-To: <1285347509.2503.357.camel@edumazet-laptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi Eric,

thanks for the correction! Searched through the log files and discovere=
d
that the initial "Neighbor overflow" message was caused by an IPv6 ping
scan from the Internet.

rt_garbage_collect() is called from dst_alloc and rt_intern_hash. In an=
y
case no routes will be freed if the total entries are smaller than
ipv4.route.gc_thresh.

neigh.default.gc_thresh is static while ipv4.route.gc_thresh is based o=
n
system memory. Wouldn't it make sense to set neigh.default.gc_thresh
based on system memory too?

Cheers
 Ulrich

--=20
Ulrich Weber | uweber@astaro.com | Software Engineer
Astaro GmbH & Co. KG | www.astaro.com | Phone +49-721-25516-0 | Fax =E2=
=80=93200
An der RaumFabrik 33a | 76227 Karlsruhe | Germany
