From: Patrick McHardy <kaber@trash.net>
Subject: Re: [PATCH 0/2] netem: trace enhancement
Date: Tue, 04 Dec 2007 15:58:40 +0100
Message-ID: <47556B20.2030700@trash.net>
References: <20071120231131.oqn4s5eda84k4csw@email.ee.ethz.ch>	<474C2246.50205@ee.ethz.ch> <20071129134554.5c25a891@freepuppy.rosehill>	<474F3719.30101@trash.net> <47503971.9080509@ee.ethz.ch>	<4753B423.7030000@trash.net> <4753C874.80703@ee.ethz.ch>	<47543E65.4060303@trash.net> <47544B1F.1010902@candelatech.com> <20071204154535.4eu35nfe9wks8kgg@email.ee.ethz.ch>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-15; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Ben Greear <greearb@candelatech.com>,
	Stephen Hemminger <shemminger@linux-foundation.org>,
	netdev@vger.kernel.org, herbert@gondor.apana.org.au,
	Rainer Baumann <baumann@tik.ee.ethz.ch>
To: Ariane Keller <ariane.keller@tik.ee.ethz.ch>
Return-path: <netdev-owner@vger.kernel.org>
Received: from stinky.trash.net ([213.144.137.162]:33750 "EHLO
	stinky.trash.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753435AbXLDO6o (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 4 Dec 2007 09:58:44 -0500
In-Reply-To: <20071204154535.4eu35nfe9wks8kgg@email.ee.ethz.ch>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Ariane Keller wrote:
> 
>>> That sounds like it would also be possible using rtnetlink. You could
>>> send out a notification whenever you switch the active buffer and have
>>> userspace listen to these and replace the inactive one.
> 
> I guess using rtnetlink is possible. However I'm not sure about how to 
> implement it:
> The first thought was to use RTM_NEWQDISC to send the data to the 
> netem_change() function (similar to tc_qdisc_modify() ).

That sounds reasonable.

> But with this 
> we would need the tcm_handle, tcm_parent arguments etc. which are not 
> known in q_netem.c
> Therefore we would have to change the parse_qopt() function prototype in 
> order to pass the whole "req" and not only the nlmsghdr.

I assume you mean netem_init, parse_qopt is userspace. But I don't
see how that is related, emptying the buffer happens during packet
processing, right?

I guess I would simply change the qdisc_notify function to not
require a struct nlmsghdr * (simply pass nlmsg_seq directly) and
use that to send notifications. The netem dump function would
add the buffer state. BTW, the parent class id is available in
sch->parent, the handle in sch->handle, but qdisc_notify should
take care of everything you need.
