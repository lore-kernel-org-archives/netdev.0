From: Patrick McHardy <kaber@trash.net>
Subject: Re: 2.6.25-rc9: Reported regressions from 2.6.24
Date: Sun, 13 Apr 2008 21:45:45 +0200
Message-ID: <480262E9.4030500@trash.net>
References: <RR4Oy_oXY2J.A.b0H.A3lAIB@albercik>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Linux Kernel Mailing List <linux-kernel@vger.kernel.org>,
	Adrian Bunk <bunk@kernel.org>,
	Andrew Morton <akpm@linux-foundation.org>,
	Linus Torvalds <torvalds@linux-foundation.org>,
	Natalie Protasevich <protasnb@gmail.com>,
	Linux Netdev List <netdev@vger.kernel.org>,
	andy@greyhouse.net, Pavel Emelyanov <xemul@openvz.org>
To: "Rafael J. Wysocki" <rjw@sisk.pl>
Return-path: <netdev-owner@vger.kernel.org>
Received: from stinky.trash.net ([213.144.137.162]:51065 "EHLO
	stinky.trash.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1758004AbYDMTtP (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 13 Apr 2008 15:49:15 -0400
In-Reply-To: <RR4Oy_oXY2J.A.b0H.A3lAIB@albercik>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Rafael J. Wysocki wrote:
> This message contains a list of some regressions from 2.6.24, for which there
> are no fixes in the mainline I know of.  If any of them have been fixed already,
> please let me know.
>
>
> Bug-Entry	: http://bugzilla.kernel.org/show_bug.cgi?id=10323
> Subject		: panic using bridging on linus kernel 2.6.25-rc6
> Submitter	: Andy Gospodarek <andy@greyhouse.net>
> Date		: 2008-03-25 11:40 (20 days old)

This looks like another network-namespace regression.
icmp_send() does:

        net = rt->u.dst.dev->nd_net;

The bridge netfilter code attaches a fake dst_entry to the
skb which has dev == NULL when passing it to IPv4 netfilter.

Pavel, do you have a better ideas for fixing this than
instantiating a dst_entry in br_netfilter.c for every
device (or at least for every namespace)?



