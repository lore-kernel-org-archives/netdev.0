From: Sebastian Kuzminsky <seb@highlab.com>
Subject: Re: bug in tcp?
Date: Mon, 16 Apr 2007 23:35:23 -0600
Message-ID: <E1HdgLb-0005eU-Ji@highlab.com>
References: <E1HdZgM-0001n2-F0@highlab.com> <462450C5.5080702@snapgear.com>
Cc: netdev@vger.kernel.org, Sebastian Kuzminsky <seb@highlab.com>
To: Philip Craig <philipc@snapgear.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from sccrmhc11.comcast.net ([63.240.77.81]:38034 "EHLO
	sccrmhc11.comcast.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753975AbXDQFfk (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 17 Apr 2007 01:35:40 -0400
In-reply-to: <462450C5.5080702@snapgear.com> 
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Philip Craig <philipc@snapgear.com> wrote:
> It sounds like it could easily be iptables related, if you have iptables
> rules that only allow new connections in the client to server direction,
> which is quite normal.

Sure I have those standard rules.

iptables -A INPUT -p tcp -m state --state ESTABLISHED -j ACCEPT
iptables -A INPUT -p tcp --syn --dport ssh -j ACCEPT
iptables -A INPUT -p tcp --syn --dport http -j ACCEPT
... etc


> The default iptables timeout for TCP connections is 5 days.
> So after 5 days of idle, any packets from the server will be treated
> as a new connection and the iptables rules will drop them.

Weird.  Why does sending a message from the client make it go again?

If that's the case, it seems like a simple fix would be to enable TCP
keepalive in my app, that would keep netfilter from timing out, right?
That seems better than extending the netfilter timeout.

How do people normally handle this?


-- 
Sebastian Kuzminsky
