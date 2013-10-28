From: Dan Williams <dcbw@redhat.com>
Subject: Re: [PATCH 16/16] wl1251: Add sysfs file address for setting
 permanent mac address
Date: Mon, 28 Oct 2013 10:29:21 -0500
Message-ID: <1382974161.1542.18.camel@dcbw.foobar.com>
References: <1382819655-30430-1-git-send-email-pali.rohar@gmail.com>
	 <1382971562.1542.6.camel@dcbw.foobar.com>
	 <1382972215.17956.30.camel@jlt4.sipsolutions.net> <201310281604.48542@pali>
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
In-Reply-To: <201310281604.48542@pali>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Mon, 2013-10-28 at 16:04 +0100, Pali Roh=C3=A1r wrote:
> On Monday 28 October 2013 15:56:55 Johannes Berg wrote:
> > On Mon, 2013-10-28 at 09:46 -0500, Dan Williams wrote:
> > > If the device doesn't actually *have* a permanent MAC
> > > address, then it shouldn't be returning one via ethtool,
> > > and should return an error for ETHTOOL_GPERMADDR.
> >=20
> > There's currently no provision for that, but I agree it would
> > be better to do so.
> >=20
> > johannes
>=20
> So what to do with devices which has MAC address stored in some=20
> obscure place and there is userspace binary which can read it?
>=20
> I think that there should be some way to tell kernel that *this*=20
> is the permanent address and it should use it.
>=20
> This is reason why I proposed patch which adding sysfs entry for=20
> setting permanent address from userspace in wl1251 driver.

Ok, so the N900's MAC is stored in the "cal partition", which is a
region of flash exposed to the OS as /dev/mtd1.  That also stores the
regulatory domain.  Typically userspace binaries are used to pull out
this and other data (see
https://dev.openwrt.org/browser/packages/utils/calvaria/files/src/calva=
ria.c ) which is then used to initialize the device.

Any idea what kernel driver is used to expose the CAL partition
as /dev/mtd1?  If it's nothing special maybe a small EEPROM-style drive=
r
could be written to read the relevant areas (and since they don't ever
change, don't need to worry about something else writing at the same
time).

Dan
