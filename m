From: Neil Horman <nhorman@tuxdriver.com>
Subject: [RFC PATCH 0/2 v3] net: alternate proposal for using macvlans with forwarding acceleration
Date: Fri, 11 Oct 2013 14:43:55 -0400
Message-ID: <1381517037-26007-1-git-send-email-nhorman@tuxdriver.com>
References: <1380140209-24587-1-git-send-email-nhorman@tuxdriver.com>
Cc: john.fastabend@gmail.com, Andy Gospodarek <andy@greyhouse.net>,
	David Miller <davem@davemloft.net>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from charlotte.tuxdriver.com ([70.61.120.58]:57801 "EHLO
	smtp.tuxdriver.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752077Ab3JKSoP (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 11 Oct 2013 14:44:15 -0400
In-Reply-To: <1380140209-24587-1-git-send-email-nhorman@tuxdriver.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hey all-
     heres the next, updated version of the vsi/macvlan integration that we've
been discussing.

Change notes:

* Moved the feature flag to netdev_features.h.  No ethtool option for disabling
it yet, but its there now, and seems to fit fairly well.  I was actually
thinking about your comment John, regarding the clumsiness in allowing sw and hw
accel vlans on the same lowerdev, and it just occured to me that we could use
the same flag on the macvlan device directly - i.e. if we found that a lowerdev
supported acceleration, then call ndo_dfwd_station_add, and, if successfull, set
the same feature flag in the macvlan device.  Then we could use ethtool to
control the enabling/disabling of acceleration at the macvlan device directly.
Thoughts?

* Moved the acceleration net device methods back into net_device_ops.  Looks
pretty good to me there.

* Restored the use of a separate xmit routine so we weren't subject to the
lowerdevs queue disciplines.  I integrated its use with dev_hard_start_xmit, so
we could share the use of the linearization code, etc.  Let me know what you
think.

Best
Neil
