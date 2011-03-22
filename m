From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] veth: Fix the byte counters
Date: Mon, 21 Mar 2011 18:25:03 -0700 (PDT)
Message-ID: <20110321.182503.258117496.davem@davemloft.net>
References: <m1oc54i242.fsf@fess.ebiederm.org>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, mirq-linux@rere.qmqm.pl,
	eric.dumazet@gmail.com, arnd@arndb.de, greearb@candelatech.com,
	kaber@trash.net, daniel.lezcano@free.fr, xemul@openvz.org
To: ebiederm@xmission.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:54864
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1754840Ab1CVBYZ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 21 Mar 2011 21:24:25 -0400
In-Reply-To: <m1oc54i242.fsf@fess.ebiederm.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: ebiederm@xmission.com (Eric W. Biederman)
Date: Mon, 21 Mar 2011 14:40:29 -0700

> 
> Commit 44540960 "veth: move loopback logic to common location" introduced
> a bug in the packet counters.  I don't understand why that happened as it
> is not explained in the comments and the mut check in dev_forward_skb
> retains the assumption that skb->len is the total length of the packet.
> 
> I just measured this emperically by setting up a veth pair between two
> noop network namespaces setting and attempting a telnet connection between
> the two.  I saw three packets in each direction and the byte counters were
> exactly 14*3 = 42 bytes high in each direction.  I got the actual
> packet lengths with tcpdump.
> 
> So remove the extra ETH_HLEN from the veth byte count totals.
> 
> Signed-off-by: Eric W. Biederman <ebiederm@aristanetworks.com>

Applied, thanks.
