From: Mugunthan V N <mugunthanvnm-l0cyMroinI0@public.gmane.org>
Subject: Re: [net-next PATCH v2 0/3] Broadcast/Multicast rate limit via Ethtool
 Coalesce
Date: Thu, 17 Jul 2014 11:43:36 +0530
Message-ID: <53C76990.3000304@ti.com>
References: <1404890050-4020-1-git-send-email-mugunthanvnm@ti.com> <20140709.164420.157865201153845876.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="ISO-8859-1"
Content-Transfer-Encoding: 7bit
Cc: <netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>, <linux-api-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
	<linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
To: David Miller <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>
Return-path: <linux-api-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <20140709.164420.157865201153845876.davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>
Sender: linux-api-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

On Thursday 10 July 2014 05:14 AM, David Miller wrote:
> From: Mugunthan V N <mugunthanvnm-l0cyMroinI0@public.gmane.org>
> Date: Wed, 9 Jul 2014 12:44:07 +0530
>
>> A system/cpu can be loaded by a hacker with flooding of broadcast or
>> multicast packets, to prevent this some Ethernet controllers like CPSW
>> provide a mechanism to limit the broadcast/multicast packet rate via
>> hardware limiters. This patch series enables this feature via
>> Ethtool Coalesce.
> This is pretty bogus if you ask me.
>
> What is the difference from accepting a high rate of unicast packets?
> I say it is no different.
>
> Therefore, this feature makes no sense to me at all.

Any packet storm can cause an endpoint some issues. Typically packet
storms will cause the system CPU to thrash resulting is very low system
performance.

Unicast storms only target a single destination end station, it can be
easily mitigated by the host adding a blocking entry in the LUT for each
aggressor.

Broadcast and multicast target multiple end stations, or an entire
network, not only can it cause CPU thrashing, it can result in loss of
other broadcast and multicast services. The rate limiting feature allow
the broadcast and or multicast traffic to be dropped if the rates are
too high. This eliminates the CPU thrashing issue. It also allows the
system to analyze the aggressors and block them for future transgressions.

Regards
Mugunthan V N
