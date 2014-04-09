From: Edward Cree <ecree@solarflare.com>
Subject: udp: Question about busy_poll change
Date: Wed, 9 Apr 2014 15:13:21 +0100
Message-ID: <53455581.7060209@solarflare.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="ISO-8859-1"
Content-Transfer-Encoding: 7bit
Cc: Jonathan Cooper <jcooper@solarflare.com>
To: <netdev@vger.kernel.org>, Shawn Bohrer <sbohrer@rgmadvisors.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from webmail.solarflare.com ([12.187.104.25]:13802 "EHLO
	webmail.solarflare.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932761AbaDION0 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 9 Apr 2014 10:13:26 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Commit 005ec9743394010cd37d86c3fd2e81978231cdbf, "udp: Only allow busy
read/poll on connected sockets",
causes a performance regression (increased latency) on some
micro-benchmarks which don't connect() their UDP socket, and might well
have a similar effect on real applications that do the same thing.
As far as I can tell, the change is only needed in the case where the
UDP socket is bound to INADDR_ANY, _and_ traffic on the chosen UDP port
is received through more than one NIC (or perhaps through a NIC with
separate NAPI contexts per receive queue?)
In particular, busy polling makes sense for a client (which will only be
receiving packets from one remote address even though the socket is
unconnected), or for a socket which has been bound to an interface's
address (at least in the case of sfc, where we have one NAPI context for
all the receive queues on an interface).

So, what was the deeper rationale for this change?  Is there a
correctness issue or does the old behaviour just affect performance
through unnecessary busy_polling?  Or have I just misunderstood things
completely?
