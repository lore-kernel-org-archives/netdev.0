From: Ben Hutchings <bhutchings@solarflare.com>
Subject: Re: [PATCH] drivers/net: Call netif_carrier_off at the end of the
 probe
Date: Tue, 15 Feb 2011 15:58:52 +0000
Message-ID: <1297785532.2584.10.camel@bwh-desktop>
References: <1297771719-14202-1-git-send-email-ivecera@redhat.com>
	 <20110215152246.GA11719@electric-eye.fr.zoreil.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: Ivan Vecera <ivecera@redhat.com>, netdev@vger.kernel.org,
	davem@davemloft.net, aabdulla@nvidia.com,
	Ben Hutchings <ben@decadent.org.uk>
To: Francois Romieu <romieu@fr.zoreil.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from exchange.solarflare.com ([216.237.3.220]:59475 "EHLO
	exchange.solarflare.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754624Ab1BOP6z (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 15 Feb 2011 10:58:55 -0500
In-Reply-To: <20110215152246.GA11719@electric-eye.fr.zoreil.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, 2011-02-15 at 16:22 +0100, Francois Romieu wrote:
> Ivan Vecera <ivecera@redhat.com> :
> > Without calling of netif_carrier_off at the end of the probe the operstate
> > is unknown when the device is initially opened. By default the carrier is
> > on so when the device is opened and netif_carrier_on is called the link
> > watch event is not fired and operstate remains zero (unknown).
> 
> Stated this way it sounds like a core dev layer issue.

Due to hardware limitations, some network drivers cannot report the
carrier state and they never call netif_carrier_{on,off}().  Therefore
the initial operstate of 'unknown' is correct.

> I am not completely sure after reading some history. Namely:
> - (37e8273cd30592d3a82bcb70cbb1bdc4eaeb6b71 ?)
> - c276e098d3ee33059b4a1c747354226cec58487c 
> - 22604c866889c4b2e12b73cbf1683bda1b72a313
> - b47300168e770b60ab96c8924854c3b0eb4260eb
> 
> I am confused.

Drivers that can report carrier state should do so initially some time
between registering a device and bringing it up (either in the bus probe
function or the ndo_open function).  It generally seems to be safe to
assume that the link is down initially, and then to rely on
notifications from the hardware.  However, that does depend on the
behaviour of the hardware.

Ben.

-- 
Ben Hutchings, Senior Software Engineer, Solarflare Communications
Not speaking for my employer; that's the marketing department's job.
They asked us to note that Solarflare product names are trademarked.

