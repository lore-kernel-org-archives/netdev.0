From: Marcel Holtmann <marcel@holtmann.org>
Subject: Re: [PATCH] allow setting wiphy.perm_addr after driver probe
Date: Mon, 11 Aug 2014 16:56:55 -0700
Message-ID: <52896C9C-8560-4CE4-A1FB-C896D766EC87@holtmann.org>
References: <1407780269.28221.63.camel@chimera> <54DF22CF-59D7-4633-A625-896F58C26A64@holtmann.org> <1407789645.28221.68.camel@chimera> <37210DB5-2911-4FA3-9299-7701C5003945@holtmann.org> <1407791075.28221.74.camel@chimera> <28066DB2-9EA9-4748-9C89-D3FBD3EC51F5@holtmann.org> <1407798738.28221.81.camel@chimera>
Mime-Version: 1.0 (Mac OS X Mail 7.3 \(1878.6\))
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 8BIT
Cc: "John W. Linville" <linville@tuxdriver.com>,
	"linux-wireless@vger.kernel.org Wireless"
	<linux-wireless@vger.kernel.org>,
	Johannes Berg <johannes@sipsolutions.net>,
	"David S. Miller" <davem@davemloft.net>,
	Network Development <netdev@vger.kernel.org>,
	linux-kernel@vger.kernel.org
To: Daniel Gimpelevich <daniel@gimpelevich.san-francisco.ca.us>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1407798738.28221.81.camel@chimera>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hi Daniel,

>> Internally it might do that, but I do not see it exposing the
>> NL80211_ATTR_MAC when you get the attributes for wiphy.
> 
> When wlan0 is created, it can be created with its own MAC irrespective
> of the wiphy MAC. In OpenWrt, the wlan0 MAC can be supplied and assigned
> to a netdev created on a specific wiphy identified by its MAC, and if
> that cannot be predicted, there is no wlan0.

the way I read the nl80211 code is that the NL80211_CMD_NEW_INTERFACE requires a wiphy device to be specified. And that is actually just a number. So I have no idea what the MAC has to here.

>> So I am still saying that when you do NL80211_CMD_NEW_INTERFACE allow
>> providing NL80211_ATTR_MAC to set the MAC address to be used. It might
>> be useful that the wiphy exposes an attribute saying that it does not
>> have a default MAC address, but that should be it. I do not like these
>> magic 00:00:00:00:00:00 games. As I mentioned earlier, in Bluetooth we
>> just deal with allowing the driver to set a flag that it does not have
>> a valid address. And then the core takes care of dealing with it.
>> 
> An attribute saying there is no default MAC is helpful only if there is
> a way to supply a new default to the wiphy.

Why does the wiphy need to know the MAC if it is always specified from userspace when actually creating the new netdev interface. Works for P2P devices, so why wouldn't it work for access point and station mode?

Regards

Marcel
