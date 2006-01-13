From: "John W. Linville" <linville@tuxdriver.com>
Subject: wireless: recap of current issues (configuration)
Date: Fri, 13 Jan 2006 17:19:36 -0500
Message-ID: <20060113221935.GJ16166@tuxdriver.com>
References: <20060113195723.GB16166@tuxdriver.com> <20060113212605.GD16166@tuxdriver.com> <20060113213011.GE16166@tuxdriver.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: linux-kernel@vger.kernel.org
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S1423015AbWAMWTv@vger.kernel.org>
To: netdev@vger.kernel.org
Content-Disposition: inline
In-Reply-To: <20060113213011.GE16166@tuxdriver.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Configuration
=============

Configuration seems to be coalescing around netlink.  Among other
things, this technology provides for muliticast requests and
asynchronous event notification.

The kernel should provide generic handlers for netlink
configuraion messages, and there should be a per-device 80211_ops
(wireless_ops? akin to ethtool_ops) structure for drivers to
populate appropriately.

At init, physical devices should be represented by a "WiPHY" device,
not directly by a net_device.  The list of physical devices should
be discoverable through netlink and/or sysfs.  (A WiPHY device is an
abstraction representing the radio interface itself.)

Virtual wlan devices should be associated to a WiPHY device many-to-one
(one-to-one for some devices).  Virtual devices correspond to a net_device.

Virtual devices will have a mode (e.g. station, AP, WDS, ad-hoc, rfmon,
raw?, other modes?) which defines its "on the air" behaviour.  Should
this mode be fixed when the wlan device is created?  Or something
that can be changed when the net_device is down?

It may be necessary to remove, suspend, and/or disable wlan devices
in order to add, resume, and/or enable other types of wlan devices
on the same WiPHY device (especialy true for rfmon).  A mechanism is
needed for drivers to be able to influence or disallow combinations
of wlan devices in accordance with capabilities of the hardware.

Do "global" config requests go to any associated wlan device?
Or must they be directed to the WiPHY device?  Does it matter?
I think we should require "global" configuration to target the WiPHY
device, while "local" configuration remains with the wlan device.
(I'm not sure how important this point is?)  Either way, the WiPHY
device will need some way to be able to reject configuration requests
that are incompatible among its associated wlan devices.  Since the
wlan interface implementations should not be device specific, perhaps
the 802.11 stack can be smart enough to filter-out most conflicting
config requests before they get to the WiPHY device?
-- 
John W. Linville
linville@tuxdriver.com
