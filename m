From: Evgeniy Polyakov <johnpol@2ka.mipt.ru>
Subject: Re: [PATCH] *icsk_ca_priv: Reduce inet_connection_sock size?
Date: Mon, 1 Sep 2008 00:22:39 +0400
Message-ID: <20080831202238.GA12624@2ka.mipt.ru>
References: <48BAE26A.4060002@danielinux.net> <20080831190916.GA15931@2ka.mipt.ru> <48BAEECA.80906@danielinux.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, angelo.tornese@gmail.com
To: Daniele Lacamera <root@danielinux.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from relay.2ka.mipt.ru ([194.85.80.65]:44378 "EHLO 2ka.mipt.ru"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751764AbYHaUXB (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sun, 31 Aug 2008 16:23:01 -0400
Content-Disposition: inline
In-Reply-To: <48BAEECA.80906@danielinux.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi Daniele.

On Sun, Aug 31, 2008 at 09:19:38PM +0200, Daniele Lacamera (root@danielinux.net) wrote:
> fast path? I don't think so... the modules allocate the ca_priv once per 
> connection, at the beginning of the connection and only if that specific 
> module needs that.
> Am I missing something?

That's actually a very fast path: connection establishment both for
listened and connection sockets (tcp_init_congestion_control() is called
for TCP_SYN_RECV state too), so you forces every socket allocation (if
appropriate congestion contttrol requires that) to be doubled.

This actually may be not a big problem, since we allocate and free
objects all the time, but still it is additional overhead which can be
avoided. Did you run some perfromance analysis to check if influence is
small or not visible at all?

-- 
	Evgeniy Polyakov
