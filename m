From: Dan Williams <dcbw@redhat.com>
Subject: Re: [PATCH 16/16] wl1251: Add sysfs file address for setting
 permanent mac address
Date: Mon, 28 Oct 2013 09:46:02 -0500
Message-ID: <1382971562.1542.6.camel@dcbw.foobar.com>
References: <1382819655-30430-1-git-send-email-pali.rohar@gmail.com>
	 <201310281449.58170@pali> <1382968522.17956.11.camel@jlt4.sipsolutions.net>
	 <201310281500.24159@pali>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Johannes Berg <johannes@sipsolutions.net>,
	Luciano Coelho <luca@coelho.fi>,
	"John W. Linville" <linville@tuxdriver.com>,
	"David S. Miller" <davem@davemloft.net>,
	linux-wireless@vger.kernel.org, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org, freemangordon@abv.bg,
	aaro.koskinen@iki.fi, pavel@ucw.cz, sre@ring0.de,
	joni.lapilainen@gmail.com
To: Pali =?ISO-8859-1?Q?Roh=E1r?= <pali.rohar@gmail.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <201310281500.24159@pali>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Mon, 2013-10-28 at 15:00 +0100, Pali Roh=C3=A1r wrote:
> On Monday 28 October 2013 14:55:22 Johannes Berg wrote:
> > On Mon, 2013-10-28 at 14:49 +0100, Pali Roh=C3=A1r wrote:
> > > On Monday 28 October 2013 14:45:05 Johannes Berg wrote:
> > > > On Sat, 2013-10-26 at 22:34 +0200, Pali Roh=C3=A1r wrote:
> > > > > Driver wl1251 generating mac address randomly at startup
> > > > > and there is no way to set permanent mac address via
> > > > > SET_IEEE80211_PERM_ADDR. This patch export sysfs file
> > > > > which can set permanent mac address by userspace helper
> > > > > program. Patch is needed for devices which do not store
> > > > > mac address in internal wl1251 eeprom.
> > > >=20
> > > > This doesn't really seem like a good idea since you can
> > > > also just use 'ip' or whatever to set the MAC address.
> > > >=20
> > > > johannes
> > >=20
> > > AFAIK you cannot set permanent address (show by ethtool -P
> > > wlan0) via ip/ifconfig.
> >=20
> > You probably can't, but that address also doesn't matter at
> > all and isn't really used anywhere.
> >=20
> > johannes
>=20
> There are some (proprietary) applications which using permanent=20
> address for something...
>=20
> And also more important: some network managing tools using it.=20
> NetworkManager resetting current MAC address to permanent one=20
> before starting configuring interface.
>=20
> So this will lead to never use correct MAC address (but random=20
> permanent one) assigned for that wl1251 wireless card...

If the device doesn't actually *have* a permanent MAC address, then it
shouldn't be returning one via ethtool, and should return an error for
ETHTOOL_GPERMADDR.  Setting the permanent MAC address shouldn't ever be
allowed except by the driver inspecting EEPROM, and certainly not via
sysfs.

mac80211 does have to do some special stuff due to virtual interfaces
and such, but in general, if the MAC address is randomly generated,
neither the driver nor mac80211 should be reporting that address as the
permanent address, only as the current one.

Dan
