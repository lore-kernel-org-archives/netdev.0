From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 2/5] [IPV6]: Multiple Routing Tables
Date: Wed, 26 Jul 2006 15:55:37 -0700 (PDT)
Message-ID: <20060726.155537.96627920.davem@davemloft.net>
References: <20060726221849.495778268@postel.suug.ch>
	<20060726.153949.29046809.davem@davemloft.net>
	<20060726224848.GX14627@postel.suug.ch>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, vnuorval@tcs.hut.fi,
	usagi-core@linux-ipv6.org, yoshfuji@linux-ipv6.org,
	anttit@tcs.hut.fi
Return-path: <netdev-owner@vger.kernel.org>
Received: from dsl027-180-168.sfo1.dsl.speakeasy.net ([216.27.180.168]:57558
	"EHLO sunset.davemloft.net") by vger.kernel.org with ESMTP
	id S1751159AbWGZWz0 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 26 Jul 2006 18:55:26 -0400
To: tgraf@suug.ch
In-Reply-To: <20060726224848.GX14627@postel.suug.ch>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Thomas Graf <tgraf@suug.ch>
Date: Thu, 27 Jul 2006 00:48:48 +0200

> Fortunately it's only used read-only when notifying to figure
> out the destination pid but that code seems bogus as well and
> we can probably remove the netlink cb passing hell throughout
> all the code there.

Yes, that pid handling looks very strange.  But I would
search the history of this code that passes the netlink
skb parms around before making any changes to things like
inet6_rt_notify :)

It appears to have been added in 2.4.32, the original patch passes the
raw pid around as the argument but that got changed to the current
form which passes the netlink_skb_parms.
