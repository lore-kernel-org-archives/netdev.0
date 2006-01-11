From: Rogier Wolff <R.E.Wolff@harddisk-recovery.nl>
Subject: Re: Transmit timeout with E1000
Date: Wed, 11 Jan 2006 15:51:31 +0100
Message-ID: <20060111145130.GA30051@bitwizard.nl>
References: <20060110151254.GA24273@harddisk-recovery.com> <Pine.WNT.4.63.0601100929570.1360@jbrandeb-desk.amr.corp.intel.com> <20060111125946.GA18203@harddisk-recovery.nl> <20060111132208.GA2332@harddisk-recovery.nl> <20060111134349.GA11630@harddisk-recovery.com> <20060111135627.GB8292@bitwizard.nl> <43C51223.6040309@cosmosbay.com> <20060111144810.GA25967@bitwizard.nl>
Mime-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Transfer-Encoding: quoted-printable
Cc: Eric Dumazet <dada1@cosmosbay.com>,
	Rogier Wolff <R.E.Wolff@BitWizard.nl>,
	Erik Mouw <erik@harddisk-recovery.com>,
	Jesse Brandeburg <jesse.brandeburg@intel.com>,
	e1000-devel@lists.sourceforge.net, netdev@vger.kernel.org
Return-path: <e1000-devel-admin@lists.sourceforge.net>
To: Rogier Wolff <R.E.Wolff@harddisk-recovery.nl>
Content-Disposition: inline
In-Reply-To: <20060111144810.GA25967@bitwizard.nl>
Sender: e1000-devel-admin@lists.sourceforge.net
Errors-To: e1000-devel-admin@lists.sourceforge.net
List-Unsubscribe: <https://lists.sourceforge.net/lists/listinfo/e1000-devel>,
	<mailto:e1000-devel-request@lists.sourceforge.net?subject=unsubscribe>
List-Post: <mailto:e1000-devel@lists.sourceforge.net>
List-Help: <mailto:e1000-devel-request@lists.sourceforge.net?subject=help>
List-Subscribe: <https://lists.sourceforge.net/lists/listinfo/e1000-devel>,
	<mailto:e1000-devel-request@lists.sourceforge.net?subject=subscribe>
List-Archive: <http://sourceforge.net/mailarchive/forum.php?forum=e1000-devel>
List-Id: netdev.vger.kernel.org

On Wed, Jan 11, 2006 at 03:48:11PM +0100, Rogier Wolff wrote:
> On Wed, Jan 11, 2006 at 03:11:47PM +0100, Eric Dumazet wrote:
> > Rogier Wolff a =E9crit :
> > >On Wed, Jan 11, 2006 at 02:43:49PM +0100, Erik Mouw wrote:
> > >>The system only recovers after the Netdev watchdog found out that t=
he
> > >>transmit timed out. However, the e1000 register dump starts about 4=
 to
> > >>5 seconds earlier: a possible workaround would be to trigger the
> > >>timeout code path as soon as the register dump starts.
> > >
> > >Found a typo.=20
> > >
> > >	Roger.=20
> > >
> > >
> > >--- e1000_main.c.orig	2006-01-11 14:53:23.000000000 +0100
> > >+++ e1000_main.c	2006-01-11 14:53:38.000000000 +0100
> > >@@ -3449,7 +3449,7 @@
> > > 	}
> > >=20
> > > 	for (i =3D 0; i < E1000_MAX_INTR; i++)
> > >-		if (unlikely(!adapter->clean_rx(adapter, adapter->rx_ring) &
> > >+		if (unlikely(!adapter->clean_rx(adapter, adapter->rx_ring) &&
> > > 		   !e1000_clean_tx_irq(adapter, adapter->tx_ring)))
> > > 			break;
> > >=20
> > >
> > >
> >=20
> > I believe it's not a typo.
> >=20
> > The intention is to call both clean_rx() and e1000_clean_tx_irq(), an=
d=20
> > break of the loop if both said : There was no job pending.
>=20
> Although (one of) the prototypes state(s) that it returns a boolean,
> it is valid C to return the number of items pending.
>=20
> And if one reports "2 more pending" and the other reports "1 more
> pending", the "&" between the two becomes 2 & 1 =3D> 0 / FALSE, while 2
> && 1 =3D> TRUE.
>=20
> I consider this a low prio typo, not likely to be a bug "right now",
> but it is inviting someone to make it into a bug later on.

Oops. The line itself has "logical NOT" operators. So indeed it is NOW
not a bug, and slighlty less likely to become a bug later on, but
still bad programming practise.

	Roger.=20

--=20
+-- Rogier Wolff -- www.harddisk-recovery.nl -- 0800 220 20 20 --
| Files foetsie, bestanden kwijt, alle data weg?!
| Blijf kalm en neem contact op met Harddisk-recovery.nl!


-------------------------------------------------------
This SF.net email is sponsored by: Splunk Inc. Do you grep through log fi=
les
for problems?  Stop!  Download the new AJAX search engine that makes
searching your log files as easy as surfing the  web.  DOWNLOAD SPLUNK!
http://ads.osdn.com/?ad_id=3D7637&alloc_id=3D16865&op=3Dclick
