From: Philip Craig <philipc@snapgear.com>
Subject: Re: bug in tcp?
Date: Tue, 17 Apr 2007 16:13:06 +1000
Message-ID: <46246572.9020108@snapgear.com>
References: <E1HdZgM-0001n2-F0@highlab.com> <462450C5.5080702@snapgear.com> <E1HdgLb-0005eU-Ji@highlab.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: Sebastian Kuzminsky <seb@highlab.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from rex.snapgear.com ([203.143.235.140]:50176 "EHLO
	cyberguard.com.au" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1751130AbXDQGOE (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 17 Apr 2007 02:14:04 -0400
In-Reply-To: <E1HdgLb-0005eU-Ji@highlab.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Sebastian Kuzminsky wrote:
> Weird.  Why does sending a message from the client make it go again?

The rule that allows packets with an "ESTABLISHED" state only matches
packets for which the connection is in netfilter's conntrack table.
The connection is removed from the table after the 5 days of idle.
It is only added again if netfilter accepts a packet for that connection.
So the packet from the client will cause it to be added.

> If that's the case, it seems like a simple fix would be to enable TCP
> keepalive in my app, that would keep netfilter from timing out, right?
> That seems better than extending the netfilter timeout.

Yes that would work.

> How do people normally handle this?

Change the timeout or use keepalives.  I can't think of any other way.
The 5 days is a compromise between keeping valid connections and
timing out dead connections.  There will always be connections for
which it times out too fast or too slow.  I don't think there are
any drawbacks to increasing the timeout if you aren't a router,
but as long as there is a timeout, you need keepalives to be sure.

