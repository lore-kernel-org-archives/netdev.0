From: Andy Fleming <afleming@gmail.com>
Subject: Re: [RFC PATCH] et1011c: Replaced PHY driver by a small dm646x board fixup
Date: Wed, 23 Mar 2011 19:24:04 -0500
Message-ID: <AANLkTin14WSZsc7+B-rK1dSn=XShNrF63k_47RXu-3G6@mail.gmail.com>
References: <091F7EC1-5D33-4C90-AFC1-D6E24EF3EEC6@boeing.com>
	<1300919616-6780-1-git-send-email-Kyle.D.Moffett@boeing.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org, Kevin Hilman <khilman@deeprootsystems.com>,
	Russell King <linux@arm.linux.org.uk>,
	"David S. Miller" <davem@davemloft.net>,
	=?ISO-8859-1?Q?Uwe_Kleine=2DK=F6nig?=
	<u.kleine-koenig@pengutronix.de>,
	"David J. Choi" <david.choi@micrel.com>,
	Giuseppe Cavallaro <peppe.cavallaro@st.com>,
	Randy Dunlap <randy.dunlap@oracle.com>,
	linux-arm-kernel@lists.infradead.org, linux-kernel@vger.kernel.org
To: Kyle Moffett <Kyle.D.Moffett@boeing.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1300919616-6780-1-git-send-email-Kyle.D.Moffett@boeing.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Wed, Mar 23, 2011 at 5:33 PM, Kyle Moffett <Kyle.D.Moffett@boeing.co=
m> wrote:

> -
> -static struct phy_driver et1011c_driver =3D {
> - =A0 =A0 =A0 .phy_id =A0 =A0 =A0 =A0 =3D 0x0282f014,
> - =A0 =A0 =A0 .name =A0 =A0 =A0 =A0 =A0 =3D "ET1011C",
> - =A0 =A0 =A0 .phy_id_mask =A0 =A0=3D 0xfffffff0,
> - =A0 =A0 =A0 .features =A0 =A0 =A0 =3D (PHY_BASIC_FEATURES | SUPPORT=
ED_1000baseT_Full),
> - =A0 =A0 =A0 .flags =A0 =A0 =A0 =A0 =A0=3D PHY_POLL,
> - =A0 =A0 =A0 .config_aneg =A0 =A0=3D et1011c_config_aneg,
> - =A0 =A0 =A0 .read_status =A0 =A0=3D et1011c_read_status,
> - =A0 =A0 =A0 .driver =A0 =A0 =A0 =A0 =3D { .owner =3D THIS_MODULE,},
> -};


Might I suggest that you not eliminate the whole driver?  If you leave
just this part (and the init stuff below it), and convert the
config_aneg and read_status pointers to use the genphy versions, the
kernel will, at least, be able to report what type of PHY it is.  And
maybe one day, someone who is familiar with the inner workings of this
PHY will fill in a more correct driver.

Andy
