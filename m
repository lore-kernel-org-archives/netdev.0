From: Vladimir Kondratiev <vkondra@mail.ru>
Subject: Re: [RFC] Wireless extensions rethink
Date: Wed, 16 Jun 2004 20:40:07 +0300
Sender: netdev-bounce@oss.sgi.com
Message-ID: <200406162040.12747.vkondra@mail.ru>
References: <C6F5CF431189FA4CBAEC9E7DD5441E0103AF626C@orsmsx402.amr.corp.intel.com> <1087377197.25912.54.camel@sfeldma-mobl2.dsl-verizon.net> <20040616152808.GA6270@fog.sekrit.org>
Mime-Version: 1.0
Content-Type: Text/Plain;
  charset="iso-8859-1"
Content-Transfer-Encoding: 8bit
Cc: Gerald Britton <gbritton@doomcom.org>, Scott Feldman <sfeldma@pobox.com>,
        Gertjan van Wingerde <gwingerde@home.nl>
Return-path: <netdev-bounce@oss.sgi.com>
To: netdev@oss.sgi.com
In-Reply-To: <20040616152808.GA6270@fog.sekrit.org>
Content-Disposition: inline
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

-----BEGIN PGP SIGNED MESSAGE-----
Hash: SHA1

On Wednesday 16 June 2004 18:28, Gerald Britton wrote:
> A few comments below.
>
> On Wed, Jun 16, 2004 at 02:13:18AM -0700, Scott Feldman wrote:
> > +/* for getting/setting wireless settings */
> > +struct ethtool_wx_cmd {
> > +	u32	cmd;
> > +	u16	nwid;		/* Wireless network ID; 0 = disabled */
> > +	struct {
> > +		u32	mantissa;
> > +		u16	exponent;
> > +	} freq;			/* Operating frequency */
> > +	u32	mode;		/* Operating mode (ETH_WX_MODE_xxx) */
> > +	u16	sens;		/* Sensitivity threshold (-dBm) */
> > +	struct sockaddr wap;	/* Register with access point */
> > +				/*   auto = 00:00:00:00:00:00 */
> > +	char	essid[32];	/* ESSID; any = NULL string */
>
> This isn't sufficient as you can have \0 bytes in the ESSID so treating it
> as a null-terminated string is probably not ideal.  Also the spec specifies
> 32 characters as a max, but the 802.11 management IE's could support upto
> 255 character essid's, this probably needs a little extra thought.

... And WiFi compliance tests include testing for ESSID with \0 and other 
non-printable characters in all places.

Sure, ESSID length should be added. One byte is sufficient. In all places 
within MAC, it is used as "info element" like
struct ie {
  u8 id;
  u8 length;
  u8 content[0];
};
Is it worth to keep it in this format?

Other candidates to include:
- - supported rates
- - Channel width. In Japan, in addition to 20Mhz channels, there are 10Mzh 
ones.
- - country information. Country code and Tx power limit per channel group
- - there are 2 independent keys: unicast and mcast, each may belong to 
different suite (AES, TKIP, WEP...)
- - TGe data: air access parameters per access category, list of TSPECs, whether 
STA uses aggregate schedule, whether STA uses APSD (automatic power save 
delivery)

>
> > +	u32	rate;		/* Bit rate b/s; 0 = auto */
> > +	u16	rts;		/* Smallest packet size for which */
> > +				/* the node sends RTS; 0 = off */
> > +	u16	frag;		/* Maximum fragment size; 0 = no frag */
> > +	u16	tx_power;	/* Transmit power in dBm */
> > +	struct { /* TODO: thit needs work */
> > +		u16	limit;
> > +		u32	lifetime;	/* usec */
> > +	} retry;		/* MAC retransmission */
> > +	u32	sec_mode;	/* Security mode (ETH_WX_SEC_MODE_xxx) */
> > +	char	sec_key[32];	/* Security mode encryption key */
>
> Similar here, is 32 characters worth of "key" enough here.
>
> > +	/* TODO: add struct power */
> > +	u32	reserved[16];
> > +};
>
> Also a quick thought to settings many drivers have in their iwpriv
> commands such as operating modes .11b/.11a/.11g/auto.  A survey of a bunch
> of drivers is probably worth doing to collect where the previous wireless
> extentions didn't really fit their needs.
>
> 				-- Gerald
-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.2.4 (GNU/Linux)

iD8DBQFA0IX8qxdj7mhC6o0RAu6pAJ9gZsba1Fv7PE4ELFZTr6Tj7KkgfQCgrwIw
/H6eBtA6jETvx2N/YzhAvTw=
=pOUh
-----END PGP SIGNATURE-----
