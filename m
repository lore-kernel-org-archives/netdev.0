From: Jeff Sipek <jeffpc@optonline.net>
Subject: Re: [PATCH - RFC] [1/5] 64-bit network statistics - generic net
Date: Fri, 04 Jul 2003 02:02:03 -0400
Sender: linux-kernel-owner@vger.kernel.org
Message-ID: <200307040200.08574.jeffpc@optonline.net>
References: <200307032231.39842.jeffpc@optonline.net>
 <3F04EAA0.2050102@pobox.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=iso-8859-1
Content-Transfer-Encoding: 7BIT
Cc: Kernel Mailing List <linux-kernel@vger.kernel.org>,
	Andrew Morton <akpm@digeo.com>,
	Dave Jones <davej@codemonkey.org.uk>,
	Linus Torvalds <torvalds@osdl.org>, netdev@oss.sgi.com
Return-path: <linux-kernel-owner+linux-kernel=40quimby.gnus.org@vger.kernel.org>
In-reply-to: <3F04EAA0.2050102@pobox.com>
To: Jeff Garzik <jgarzik@pobox.com>
Content-Disposition: inline
Content-description: clearsigned data
List-Id: netdev.vger.kernel.org

-----BEGIN PGP SIGNED MESSAGE-----
Hash: SHA1

On Thursday 03 July 2003 22:46, Jeff Garzik wrote:
> Jeff Sipek wrote:
> > +	spinlock_t	rx_packets;
<snip>
> > +	spinlock_t	tx_compressed;
>
> That's a fat daddy list of locks you got there.

Yeah, I know, I am sure there is a way of getting rid of some of those.. (i.e.
the tx functions are inside a spinlock from struct net_device.)

> > +	NETSTAT_TYPE	_rx_packets;		/* total packets received	*/
> > +	NETSTAT_TYPE	_tx_packets;		/* total packets transmitted	*/
> > +	NETSTAT_TYPE	_rx_bytes;		/* total bytes received 	*/
> > +	NETSTAT_TYPE	_tx_bytes;		/* total bytes transmitted	*/
> > +	NETSTAT_TYPE	_rx_errors;		/* bad packets received		*/
> > +	NETSTAT_TYPE	_tx_errors;		/* packet transmit problems	*/
> > +	NETSTAT_TYPE	_rx_dropped;		/* no space in linux buffers	*/
> > +	NETSTAT_TYPE	_tx_dropped;		/* no space available in linux	*/
> > +	NETSTAT_TYPE	_multicast;		/* multicast packets received	*/
> > +	NETSTAT_TYPE	_collisions;
>
> Increasing user-visible sizes arbitrarily breaks stuff.  Having
> config-dependent types like this increases complexity.

Not really, those macros used to change the variables hide everything from the
driver programmer. Besides those changes in procfs and sysfs which always
return 64-bits, everything else is type casted (if needed) by those macros -
depending on CONFIG_NETSTATS64.

> Short term, just sample the stats more rapidly.

That's what Linus said. But it is only a temporary fix.

> Long term, I suppose with 10GbE we should start thinking about this.
> Personally, I would prefer to make the standard net device stats
> available in the format already exported by ETHTOOL_GSTATS -- which I
> note uses u64's for its counters, and it's easily extensible.  I
> received a request for this just today, even.

I was thinking about making the 64-bit stats mandatory, but then I opted to
make in an option in the config. (As Linus pointed out, some people want
performance, not statistics.)

Jeff.

- --
I'm somewhere between geek and normal.
		- Linus Torvalds
-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.2.2 (GNU/Linux)

iD8DBQE/BRhfwFP0+seVj/4RAtBbAJ4nmbs8ZQLgFagfb4KrJGZ55AYTmwCgzkcs
1uPma124BorLUdrcsbF2Txs=
=EIag
-----END PGP SIGNATURE-----
