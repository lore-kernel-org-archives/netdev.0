From: Gerald Britton <gbritton@doomcom.org>
Subject: Re: [RFC] Wireless extensions rethink
Date: Wed, 16 Jun 2004 11:28:08 -0400
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20040616152808.GA6270@fog.sekrit.org>
References: <C6F5CF431189FA4CBAEC9E7DD5441E0103AF626C@orsmsx402.amr.corp.intel.com> <40CF263E.70009@home.nl> <1087377197.25912.54.camel@sfeldma-mobl2.dsl-verizon.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Gertjan van Wingerde <gwingerde@home.nl>, netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: Scott Feldman <sfeldma@pobox.com>
Content-Disposition: inline
In-Reply-To: <1087377197.25912.54.camel@sfeldma-mobl2.dsl-verizon.net>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

A few comments below.

On Wed, Jun 16, 2004 at 02:13:18AM -0700, Scott Feldman wrote:
> +/* for getting/setting wireless settings */
> +struct ethtool_wx_cmd {
> +	u32	cmd;
> +	u16	nwid;		/* Wireless network ID; 0 = disabled */
> +	struct {
> +		u32	mantissa;
> +		u16	exponent;
> +	} freq;			/* Operating frequency */
> +	u32	mode;		/* Operating mode (ETH_WX_MODE_xxx) */
> +	u16	sens;		/* Sensitivity threshold (-dBm) */
> +	struct sockaddr wap;	/* Register with access point */
> +				/*   auto = 00:00:00:00:00:00 */
> +	char	essid[32];	/* ESSID; any = NULL string */

This isn't sufficient as you can have \0 bytes in the ESSID so treating it
as a null-terminated string is probably not ideal.  Also the spec specifies
32 characters as a max, but the 802.11 management IE's could support upto
255 character essid's, this probably needs a little extra thought.

> +	u32	rate;		/* Bit rate b/s; 0 = auto */
> +	u16	rts;		/* Smallest packet size for which */
> +				/* the node sends RTS; 0 = off */
> +	u16	frag;		/* Maximum fragment size; 0 = no frag */
> +	u16	tx_power;	/* Transmit power in dBm */
> +	struct { /* TODO: thit needs work */
> +		u16	limit;
> +		u32	lifetime;	/* usec */
> +	} retry;		/* MAC retransmission */
> +	u32	sec_mode;	/* Security mode (ETH_WX_SEC_MODE_xxx) */
> +	char	sec_key[32];	/* Security mode encryption key */

Similar here, is 32 characters worth of "key" enough here.

> +	/* TODO: add struct power */
> +	u32	reserved[16];
> +};

Also a quick thought to settings many drivers have in their iwpriv
commands such as operating modes .11b/.11a/.11g/auto.  A survey of a bunch
of drivers is probably worth doing to collect where the previous wireless
extentions didn't really fit their needs.

				-- Gerald
