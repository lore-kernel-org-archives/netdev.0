From: Dan Williams <dcbw-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>
Subject: Re: [PATCH v2 15/16] wl1251: Add sysfs file address for setting
 permanent mac address
Date: Tue, 10 Dec 2013 11:49:22 -0600
Message-ID: <1386697762.30202.6.camel@dcbw.foobar.com>
References: <1382819655-30430-1-git-send-email-pali.rohar@gmail.com>
	 <87txegpuyk.fsf@purkki.adurom.net> <201312101710.51015@pali>
	 <201312101814.35112@pali>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Kalle Valo <kvalo-BkwN83ws05HQT0dZR+AlfA@public.gmane.org>, Luciano Coelho <luca-XPOmlcxoEMv1KXRcyAk9cg@public.gmane.org>,
	"John W. Linville" <linville-2XuSBdqkA4R54TAoqtyWWQ@public.gmane.org>,
	linux-wireless-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, freemangordon-uiMcrn6V0Vs@public.gmane.org,
	aaro.koskinen-X3B1VOXEql0@public.gmane.org, pavel-+ZI9xUNit7I@public.gmane.org, sre-GFxCN5SEZAc@public.gmane.org,
	joni.lapilainen-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org,
	Johannes Berg <johannes-cdvu00un1VgdHxzADdlk8Q@public.gmane.org>,
	Felipe Contreras <felipe.contreras-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
To: Pali =?ISO-8859-1?Q?Roh=E1r?= <pali.rohar-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
Return-path: <linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <201312101814.35112@pali>
Sender: linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

On Tue, 2013-12-10 at 18:14 +0100, Pali Roh=C3=A1r wrote:
> On Tuesday 10 December 2013 17:10:50 Pali Roh=C3=A1r wrote:
> > On Tuesday 10 December 2013 16:49:23 Kalle Valo wrote:
> > > Pali Roh=C3=A1r <pali.rohar-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org> writes:
> > > > Driver wl1251 generating mac address randomly at startup
> > > > and there is no way to set permanent mac address via
> > > > SET_IEEE80211_PERM_ADDR. This patch export sysfs file
> > > > which can set permanent mac address by userspace helper
> > > > program. Patch is needed for devices which do not store
> > > > mac address in internal wl1251 eeprom.
> > > >=20
> > > > Signed-off-by: Pali Roh=C3=A1r <pali.rohar-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
> > >=20
> > > We have ioctl() command for setting the mac address.
> >=20
> > Really? Is there ioctl for setting permanent mac address?
> > Can you show me it?
>=20
> Now I looked at it again and I did not found any ioctl for it.=20
> There is only ioctl cmd for getting address, not setting it.
>=20
> #define SIOCETHTOOL 0x8946
>=20
> /* Get permanent hardware address */
> #define ETHTOOL_GPERMADDR 0x00000020

Yeah, because it's supposed to be permanent and unchanging.  Which mean=
s
if there was an ioctl for it, that would be contrary to the purpose of =
a
permanent MAC address.

I realize the N900 stores the WiFi MAC address completely differently
than many other systems, and that's why this sysfs file was created.  I
don't really have a great converged solution for that, other than what
you've currently got, or perhaps adding SPERMADDR to ethtool.  One thin=
g
I *would* like though, is a restriction on the sysfs file such that if
the permanent MAC is already set, it cannot be set again.  Otherwise th=
e
permanent MAC address isn't permanent at all.

Dan


--
To unsubscribe from this list: send the line "unsubscribe linux-wireles=
s" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
