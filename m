From: Marcel Holtmann <marcel@holtmann.org>
Subject: Re: [PATCH] allow setting wiphy.perm_addr after driver probe
Date: Tue, 12 Aug 2014 00:59:14 -0700
Message-ID: <70001DBA-E1CE-49D6-9A37-6F7CE31B61E6@holtmann.org>
References: <1407780269.28221.63.camel@chimera> <54DF22CF-59D7-4633-A625-896F58C26A64@holtmann.org> <1407789645.28221.68.camel@chimera> <37210DB5-2911-4FA3-9299-7701C5003945@holtmann.org> <1407791075.28221.74.camel@chimera> <28066DB2-9EA9-4748-9C89-D3FBD3EC51F5@holtmann.org> <1407798738.28221.81.camel@chimera> <52896C9C-8560-4CE4-A1FB-C896D766EC87@holtmann.org> <1407801666.28221.84.camel@chimera>
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
In-Reply-To: <1407801666.28221.84.camel@chimera>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hi Daniel,

>> the way I read the nl80211 code is that the NL80211_CMD_NEW_INTERFACE
>> requires a wiphy device to be specified. And that is actually just a
>> number. So I have no idea what the MAC has to here.
>> 
> OpenWrt finds a wiphy by its MAC.

maybe that is the first problem right there. I see that over sysfs you get phy80211/macaddress. However if you do a dump via NL80211_CMD_GET_WIPHY then you do not have the MAC address there.

>> Why does the wiphy need to know the MAC if it is always specified from
>> userspace when actually creating the new netdev interface. Works for
>> P2P devices, so why wouldn't it work for access point and station
>> mode?
>> 
> A MAC can be specified for the netdev, but it is assigned to a wiphy
> identified by its MAC.

That you find the wiphy device by its MAC address seems to be your problem. As I said, on nl80211 you are using the wiphy unique number and not a MAC address.

If you want to use some sort of device discovery via sysfs, then use phy80211/index and other attributes to uniquely identify the device. Basing this on the MAC address seems dangerous. Especially since it might be not valid or an identical default for all cards.

Regards

Marcel
