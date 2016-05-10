From: David Miller <davem@davemloft.net>
Subject: Re: [Drbd-dev] [PATCH net-next v3] block/drbd: align properly u64
 in nl messages
Date: Tue, 10 May 2016 11:39:49 -0400 (EDT)
Message-ID: <20160510.113949.2077250222547175741.davem@davemloft.net>
References: <20160509131547.GX16459@soda.linbit>
	<5731A561.6090509@6wind.com>
	<20160510094023.GC16459@soda.linbit>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: nicolas.dichtel@6wind.com, netdev@vger.kernel.org,
	philipp.reisner@linbit.com, drbd-dev@lists.linbit.com,
	linux-kernel@vger.kernel.org
To: lars.ellenberg@linbit.com
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20160510094023.GC16459@soda.linbit>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Lars Ellenberg <lars.ellenberg@linbit.com>
Date: Tue, 10 May 2016 11:40:23 +0200

> If we introduce a new config option,
> we have to add it to the config scanner (one line),
> define min, max, default and scale (four short defines),
> and add it to the netlink definition here (one line).
> Done, rest of the code is generated,
> both on the kernel side,
> and on the drbd-utils side used to talk to the kernel.
> We found that to be very convenient.

But it entirely misses the core design point of netlink.

Sender and receive _DO NOT_ need to coordinate at all.  That's the
whole point.  So tightly coupling such coordination is going to run
you into all kinds of problems.

When implemented properly, the sender can emit whatever attributes it
knows about and can generate, and the receive scans the attributes one
by one and picks out the ones it understands and processes them.

If you go against this model then you have no clean way to extend
things whilst allowing existing software to continue working.

If the drbd stuff had been posting to the networking list, we really
would have screamed loudly about these auto-generates structs and
macros and whatnot.

Anyways, back to the topic, can you please just relent and come to some
kind of agreement about the fix for this alignment bug?  This is taking
a very long time and patches are just rotting in patchwork with no
resolution.

Thanks.
