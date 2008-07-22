From: Jeff Garzik <jgarzik@pobox.com>
Subject: Re: [PATCH 3/4] sfc: resolve tx multiqueue bug
Date: Tue, 22 Jul 2008 17:29:59 -0400
Message-ID: <48865157.20709@pobox.com>
References: <20080718180156.GH10471@solarflare.com> <20080718184925.GJ10471@solarflare.com> <20080722184118.GR10471@solarflare.com> <20080722.140023.127726788.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: bhutchings@solarflare.com, netdev@vger.kernel.org,
	linux-net-drivers@solarflare.com
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from srv5.dvmed.net ([207.36.208.214]:34082 "EHLO mail.dvmed.net"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752182AbYGVVam (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 22 Jul 2008 17:30:42 -0400
In-Reply-To: <20080722.140023.127726788.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

David Miller wrote:
> From: Ben Hutchings <bhutchings@solarflare.com>
> Date: Tue, 22 Jul 2008 19:41:19 +0100
> 
>> So long as a queue is only woken in response to TX completions, the current
>> arrangement is fine.  However, sfc needs to tear down and restart hardware TX
>> queues as part of some reconfiguration, self-test and recovery code, and I
>> doubt it's the only such driver.
> 
> Mark the carrier off and packets will stop flowing to the driver.

Yep.

Though based on looking at a lot of existing driver code, I think this 
is sometimes unclear to driver writers -- when to manage carrier 
(netif_carrier_on/off) and when to manage queue flow 
(netif_queue_start/stop/wake).

	Jeff



