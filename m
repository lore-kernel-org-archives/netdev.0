From: John Fastabend <john.r.fastabend@intel.com>
Subject: Re: [PATCH 4/8] net/mlx4_en: Set max rate-limit for a TC
Date: Tue, 13 Mar 2012 11:26:38 -0700
Message-ID: <4F5F915E.4020505@intel.com>
References: <1331659323-12904-1-git-send-email-amirv@mellanox.com> <1331659323-12904-5-git-send-email-amirv@mellanox.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: "David S. Miller" <davem@davemloft.net>, netdev@vger.kernel.org,
	Roland Dreier <roland@purestorage.com>,
	Oren Duer <oren@mellanox.com>,
	Amir Vadai <amirv@mellanox.co.il>
To: Amir Vadai <amirv@mellanox.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga03.intel.com ([143.182.124.21]:49809 "EHLO mga03.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753222Ab2CMS0l (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 13 Mar 2012 14:26:41 -0400
In-Reply-To: <1331659323-12904-5-git-send-email-amirv@mellanox.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 3/13/2012 10:21 AM, Amir Vadai wrote:
> From: Amir Vadai <amirv@mellanox.co.il>
> 
> Set max rate-limit using sysfs file /sys/class/net/<interface>/qos/ratelimit
> 
> To set, enter a space separated list of values in units of 100Mbps.  For
> example to set ratelimit of 5G to TC0 and 10G for the reset on eth2 issue:
> echo 50 100 100 100 100 100 100 100 100 > /sys/class/net/eth2/qos/ratelimit
> 
> Signed-off-by: Amir Vadai <amirv@mellanox.co.il>
> ---
> 
> We used sysfs since max bw isn't part of the ETS / DCBX NL support, and we're
> open to other suggestions to add generic support for max bw, e.g add call to
> the DCBX NL API.
> 

Its not really part of DCB so adding it to DCBnl seems a bit forced. But how
about adding it as an attribute of the mqprio which "knows" about the queue
groupings?

Does the rate limiter take into account the user priority to tc mapping or
is it really just a group of queues with a rate limit? The code makes it
look like it really is per 802.1Q traffic class.

.John
