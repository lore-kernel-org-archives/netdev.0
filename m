From: Andi Kleen <andi@firstfloor.org>
Subject: Re: [PATCH] Add sysctl to set the advertised TCP initial receive window.
Date: Wed, 09 Dec 2009 14:26:39 +0100
Message-ID: <87fx7kmg6o.fsf@basil.nowhere.org>
References: <pvm638hum1a.fsf@chavey.mtv.corp.google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: davem@davemloft.net, netdev@vger.kernel.org, therbert@google.com
To: chavey@google.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from one.firstfloor.org ([213.235.205.2]:37818 "EHLO
	one.firstfloor.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755673AbZLIN0f (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 9 Dec 2009 08:26:35 -0500
In-Reply-To: <pvm638hum1a.fsf@chavey.mtv.corp.google.com> (chavey@google.com's message of "Tue, 08 Dec 2009 14:40:49 -0800")
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

chavey@google.com writes:

> Add a sysctl, tcp_init_rcv_wnd, to set the TCP initial receive window
> size advertised by passive and active TCP connections. 
> The current Linux TCP implementation limits the advertised TCP initial
> receive window to the one proscribed by slow start. For short leave
> TCP connections used for transaction type of traffic (i.e. http
> requests), bounding the advertised TCP initial receive window results
> in increased latency to complete the transaction. There exists
> environments where strict adherence to using the TCP initial receive
> window used by slow start is un-necessary. 

That's not the Internet?

> The tcp_init_rcv_wnd sysctl allows increasing the TCP initial receive
> window for all TCP connections or on a per TCP connection, allowing
> for some of the TCP connection to advertise larger TCP receive window
> than the ones bounded by slow start.

Traditionally it was very discouraged to expose such settings to users.
There's the danger that lots of people will essentially turn off cwnd
without knowing what they're doing to "make downloads go faster", causing
problems in the public network.

-Andi

-- 
ak@linux.intel.com -- Speaking for myself only.
