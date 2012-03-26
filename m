From: Ben Hutchings <bhutchings@solarflare.com>
Subject: Re: [PATCH V2 4/7] net/mlx4_en: Set max rate-limit for a TC
Date: Mon, 26 Mar 2012 15:46:03 +0100
Message-ID: <1332773163.3500.81.camel@deadeye>
References: <1332752874-8086-1-git-send-email-amirv@mellanox.com>
	 <1332752874-8086-5-git-send-email-amirv@mellanox.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: "David S. Miller" <davem@davemloft.net>, <netdev@vger.kernel.org>,
	Roland Dreier <roland@purestorage.com>,
	Yevgeny Petrilin <yevgenyp@mellanox.com>,
	Oren Duer <oren@mellanox.com>,
	Amir Vadai <amirv@dev.mellanox.co.il>
To: Amir Vadai <amirv@mellanox.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.solarflare.com ([216.237.3.220]:31499 "EHLO
	ocex02.SolarFlarecom.com" rhost-flags-OK-OK-OK-FAIL)
	by vger.kernel.org with ESMTP id S932691Ab2CZOqJ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 26 Mar 2012 10:46:09 -0400
In-Reply-To: <1332752874-8086-5-git-send-email-amirv@mellanox.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, 2012-03-26 at 11:07 +0200, Amir Vadai wrote:
> Set max rate-limit using sysfs file /sys/class/net/<interface>/ratelimit/tc<n>
> Values in Mbps units.
> 
> For example, to set ratelimit of 5G to TC3 issue:
> echo 5000 > /sys/class/net/eth2/ratelimit/tc3

This looks the wrong way round; wouldn't a tc be an object with a
ratelimit as attribute?

> Signed-off-by: Amir Vadai <amirv@mellanox.com>
> ---
> 
> We used sysfs since max bw isn't part of the ETS / DCBX NL support, and we're
> open to other suggestions to add generic support for max bw, e.g add call to
> the DCBX NL API.
[...]

netlink interfaces are generally easily extensible and it doesn't make
sense to me to augment such an interface through sysfs.  Perhaps you're
concerned that netlink extensions won't be supported in older kernel
versions running your OOT driver?  That's unfortunate, but let's not
standardise an ugly interface based on a temporary problem like that.

Ben.

-- 
Ben Hutchings, Staff Engineer, Solarflare
Not speaking for my employer; that's the marketing department's job.
They asked us to note that Solarflare product names are trademarked.
