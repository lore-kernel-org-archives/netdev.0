From: Stephen Hemminger <shemming@brocade.com>
Subject: Multicast packets being lost (3.10 stable)
Date: Mon, 24 Mar 2014 09:41:07 -0700
Message-ID: <20140324094107.2cfbf103@nehalam.linuxnetplumber.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: <netdev@vger.kernel.org>
To: Linus =?ISO-8859-1?B?TPxzc2luZw==?= <linus.luessing@web.de>,
	"David Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx0b-000f0801.pphosted.com ([67.231.152.113]:11267 "EHLO
	mx0b-000f0801.pphosted.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1752675AbaCXQlb convert rfc822-to-8bit
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 24 Mar 2014 12:41:31 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

We are seeing multicast snooping related issues.
Is there some reason this commit never went into stable (3.10)

commit b00589af3b04736376f24625ab0b394642e89e29
Author: Linus L=FCssing <linus.luessing@web.de>
Date:   Thu Aug 1 01:06:20 2013 +0200

    bridge: disable snooping if there is no querier
   =20
    If there is no querier on a link then we won't get periodic reports=
 and
    therefore won't be able to learn about multicast listeners behind p=
orts,
    potentially leading to lost multicast packets, especially for multi=
cast
    listeners that joined before the creation of the bridge.
   =20
    These lost multicast packets can appear since c5c23260594
    ("bridge: Add multicast_querier toggle and disable queries by defau=
lt")
    in particular.
   =20
    With this patch we are flooding multicast packets if our querier is
    disabled and if we didn't detect any other querier.
   =20
    A grace period of the Maximum Response Delay of the querier is adde=
d to
    give multicast responses enough time to arrive and to be learned fr=
om
    before disabling the flooding behaviour again.
   =20
    Signed-off-by: Linus L=FCssing <linus.luessing@web.de>
    Signed-off-by: David S. Miller <davem@davemloft.net>
