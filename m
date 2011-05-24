From: Ben Hutchings <bhutchings@solarflare.com>
Subject: Re: net: enable dynamic lro disabling for vlans
Date: Tue, 24 May 2011 10:22:49 -0700
Message-ID: <1306257769.17233.61.camel@localhost>
References: <1306257314-3925-1-git-send-email-nhorman@tuxdriver.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, davem@davemloft.net
To: Neil Horman <nhorman@tuxdriver.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.solarflare.com ([216.237.3.220]:8202 "EHLO
	exchange.solarflare.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752295Ab1EXRWt (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 24 May 2011 13:22:49 -0400
In-Reply-To: <1306257314-3925-1-git-send-email-nhorman@tuxdriver.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, 2011-05-24 at 13:15 -0400, Neil Horman wrote:
> Hey there-
> 	Noted recently that, while physical devices have lro disabled when
> attached to a bridge, vlan devices do not.

Good point.

> This is because the vlan netdev has
> no get/set flags method in its ethtool_ops struct. This series adds those
> methods as passthrough calls to the underlying physical devices, so that whe
> dev_disable_lro is called on a vlan device, the physical device underneath has
> lro properly disabled.

But I don't think this is correct.

The get_flags() result should be masked with vlan_features.  And
set_flags() shouldn't be allowed; the VLAN device should normally follow
the parent device and not the other way round.  I think
dev_disable_lro() needs to handle VLAN devices explicitly, instead.

Ben.

-- 
Ben Hutchings, Senior Software Engineer, Solarflare
Not speaking for my employer; that's the marketing department's job.
They asked us to note that Solarflare product names are trademarked.

