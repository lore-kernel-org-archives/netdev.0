From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] net: add SO_MAX_DGRAM_QLEN for AF_UNIX SOCK_DGRAM
 sockets
Date: Mon, 02 Mar 2015 21:38:07 -0500 (EST)
Message-ID: <20150302.213807.367185406305242762.davem@davemloft.net>
References: <1425342774-32667-1-git-send-email-christian@iwakd.de>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, dan@mindstab.net, edumazet@google.com,
	hannes@stressinduktion.org, linux-api@vger.kernel.org
To: christian@iwakd.de
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:55978 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754504AbbCCCiJ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 2 Mar 2015 21:38:09 -0500
In-Reply-To: <1425342774-32667-1-git-send-email-christian@iwakd.de>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Christian Seiler <christian@iwakd.de>
Date: Tue,  3 Mar 2015 01:32:54 +0100

> Rationale: applications may want to control how many datagrams the
> kernel buffers before senders are blocked. A prominent example would be
> to create a socket for syslog early at boot but only consume messages
> once enough of the system has been set up. The default queue length of
> 11 messages (= 10 + 1) is too low for this kind of application.

I never like arguments that talk about forcing the kernel to do
excessive buffering for an application.

Queue this stuff in the userspace side, then you can have as many
messages backlogged as you like _without_ consuming unswappable kernel
memory.

I'm tossing this, you're going to have to do a much better job
explaining to me why userspace cannot take upon itself the burdon of
queueing data until it can be sent.
