From: Daniel Gimpelevich <daniel@gimpelevich.san-francisco.ca.us>
Subject: Re: [PATCH] allow setting wiphy.perm_addr after driver probe
Date: Mon, 11 Aug 2014 14:04:35 -0700
Message-ID: <1407791075.28221.74.camel@chimera>
References: <1407780269.28221.63.camel@chimera>
	 <54DF22CF-59D7-4633-A625-896F58C26A64@holtmann.org>
	 <1407789645.28221.68.camel@chimera>
	 <37210DB5-2911-4FA3-9299-7701C5003945@holtmann.org>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: "John W. Linville" <linville@tuxdriver.com>,
	"linux-wireless@vger.kernel.org Wireless"
	<linux-wireless@vger.kernel.org>,
	Johannes Berg <johannes@sipsolutions.net>,
	"David S. Miller" <davem@davemloft.net>,
	Network Development <netdev@vger.kernel.org>,
	linux-kernel@vger.kernel.org
To: Marcel Holtmann <marcel@holtmann.org>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <37210DB5-2911-4FA3-9299-7701C5003945@holtmann.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Mon, 2014-08-11 at 13:56 -0700, Marcel Holtmann wrote:
> The initial wlan0 can be removed as every other netdev attached to the
> wiphy. It can also be as easily re-created.
> 
> Since the wiphy does not have a valid MAC address, my proposal here
> would be to just not create the wlan0 in the first place. This means
> that the wiphy can be still discovered via nl80211.

I repeat, currently wlan0 is *not* created.

> It also means that the wlan0 netdev needs to be created by userspace
> now. And a valid NL80211_ATTR_MAC be provided. Similar to what is
> already done for P2P devices at the moment. That should just solve the
> problem.

The creation of wlan0 already comes from userspace, but the PHY has its
own MAC.

> We really do not want to announce a netdev when registering the wiphy
> device and then having to mess with its MAC address via sysfs somehow.
> This all needs to be properly reflected over RTNL.
> 
Again, no netdev is announced. There just isn't a way to set the MAC of
the wiphy device itself.

How about this: What if the driver were to leave the MAC at all zeros
initially, and sysfs could set that if and only if it's all zeros at the
time?
