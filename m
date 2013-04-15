From: Wilco Baan Hofman <wilco@baanhofman.nl>
Subject: ECMP ipv6 vs ipv4
Date: Mon, 15 Apr 2013 09:58:48 +0200
Message-ID: <1366012728.4975.13.camel@localhost>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from 37-251-2-65.FTTH.ispfabriek.nl ([37.251.2.65]:59974 "EHLO
	mail.baanhofman.nl" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753930Ab3DOH7E (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 15 Apr 2013 03:59:04 -0400
Received: from localhost (localhost [127.0.0.1])
	by mail.baanhofman.nl (Postfix) with ESMTP id A2379788C3
	for <netdev@vger.kernel.org>; Mon, 15 Apr 2013 09:59:01 +0200 (CEST)
Received: from mail.baanhofman.nl ([127.0.0.1])
	by localhost (blackhole.synnack.net [127.0.0.1]) (amavisd-new, port 10024)
	with ESMTP id XSujWQlgUACa for <netdev@vger.kernel.org>;
	Mon, 15 Apr 2013 09:58:50 +0200 (CEST)
Received: from [IPv6:2001:7b8:2ff:1d9::2] (cl-474.ede-01.nl.sixxs.net [IPv6:2001:7b8:2ff:1d9::2])
	by mail.baanhofman.nl (Postfix) with ESMTPSA id D9C14788B4
	for <netdev@vger.kernel.org>; Mon, 15 Apr 2013 09:58:49 +0200 (CEST)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi,

I'm working on a patch to implement 'nexthop weight' for multipath ipv6.
However, the ECMPv6 implementation has a few flaws that are quite
annoying.

One of the flaws is that the netlink nexthop API is asymmetrical, you
can add nexthops through the netlink API, but when the result is
requested it is completely different, resulting in bird6 removing the
route as it does not match the initial route set.

Another one of the flaws is that if I add nexthop weight or algorithm
(weighted hash or weighted random) I need to add this to the main rt
node, this seems like an inefficient memory structure, as this needs to
be added to all the siblings as well.

I propose that we have a nexthop structure to an exclusive route,
similar what we have for IPv4, where we store the gateway, device and
weight for all nexthops and the algorithm in the route. This would make
the netlink API symmetrical again and fixes the n*n inefficiencies when
adding routes (all siblings need to know about all siblings).

What are your thoughts on this?

Regards,

Wilco Baan Hofman
