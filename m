From: Ben Hutchings <bhutchings@solarflare.com>
Subject: Re: [PATCH 3/4] sfc: resolve tx multiqueue bug
Date: Tue, 22 Jul 2008 19:41:19 +0100
Message-ID: <20080722184118.GR10471@solarflare.com>
References: <20080718175911.GF10471@solarflare.com> <20080718180156.GH10471@solarflare.com> <20080718184925.GJ10471@solarflare.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Jeff Garzik <jgarzik@pobox.com>, netdev@vger.kernel.org,
	linux-net-drivers@solarflare.com
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smarthost02.mail.mbr-roch.zen.net.uk ([212.23.3.141]:45482 "EHLO
	smarthost02.mail.zen.net.uk" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1752000AbYGVSl1 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 22 Jul 2008 14:41:27 -0400
Content-Disposition: inline
In-Reply-To: <20080718184925.GJ10471@solarflare.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The more I look at this issue of start vs wake, the more it seems like the
distinction should not be visible to drivers.

So long as a queue is only woken in response to TX completions, the current
arrangement is fine.  However, sfc needs to tear down and restart hardware TX
queues as part of some reconfiguration, self-test and recovery code, and I
doubt it's the only such driver.

I think the corresponding kernel queue must be stopped and then started when
we do this (otherwise we could return NETDEV_TX_BUSY in hard_start_xmit, but
I understand that to be deprecated).  So we must also wake the kernel queue
if and only if it's considered active - but we don't know whether that's the
case because deactivation is done asynchronously.

Ben.

-- 
Ben Hutchings, Senior Software Engineer, Solarflare Communications
Not speaking for my employer; that's the marketing department's job.
