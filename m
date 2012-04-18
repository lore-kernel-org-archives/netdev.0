From: Michal =?utf-8?B?S3ViZcSNZWs=?= <mkubecek@suse.cz>
Subject: Re: [PATCH v2] bonding: start slaves with link down for ARP monitor
Date: Wed, 18 Apr 2012 14:32:31 +0200
Message-ID: <2570606.YH3Fgdn9ql@alaris>
References: <20120414220617.DA8BE45BA2@lion.mk-sys.cz> <1410525.5tCeY2AOxF@alaris> <1343782.ObcgmM0SbX@alaris>
Reply-To: Michal =?utf-8?B?S3ViZcSNZWs=?= <mkubecek@suse.cz>
Mime-Version: 1.0
Content-Type: text/plain; charset=iso-8859-2
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Flavio Leitner <fbl@redhat.com>, netdev@vger.kernel.org,
	Andy Gospodarek <andy@greyhouse.net>
To: Jay Vosburgh <fubar@us.ibm.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from cantor2.suse.de ([195.135.220.15]:59988 "EHLO mx2.suse.de"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751917Ab2DRMce convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 18 Apr 2012 08:32:34 -0400
In-Reply-To: <1343782.ObcgmM0SbX@alaris>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tuesday 17 of April 2012 13:58EN, Michal Kube=E8ek wrote:
> On Monday 16 of April 2012 12:27EN, Michal Kube=E8ek wrote:
> > On Saturday 14 of April 2012 21:48EN, Jay Vosburgh wrote:
> > > Anybody got a 10 or 100 card laying around with fast autoneg to
> > > try?  Back in the day I used 3c59x and e100s, and I seem to recal=
l
> > > that the 3c59x board I had was pretty speedy at going carrier up.
> >=20
> > It seems these cards are hard to find these days (I tried to find
> > one
> > in our office but no luck yet). However, I tried an onboard adapter
> > with r8169 driver and patched kernel succeeded to detect carrier in
> > time for bonding driver to start the slave in "up" state (and it
> > started in "down" state with unplugged cable so that the detection
> > is
> > correct).
>=20
> I tested few more cards:
>=20
> - two 100 Mb/s Realtek 8139C and 8139D with 8139too driver:
>   driver sets carrier on soon enough and slave starts with "up" and
>   stays that way (same as r8169)
>=20
> - 1 Gb/s Intel Pro/1000PT (82572EI) with e1000e driver:
>   essentially the same as igb, driver is slow and patch prevents the
>   up -> down -> up sequence by starting the slave in "down" state
>=20
> - 100 Mb/s Intel (?) cards with DECchip Tulip 21142/3, tulip driver:
>   card/driver either doesn't set the flag properly or is extremely
> slow with up -> down transition so that the state was "up" all the
> time no matter what the real link state was

Thanks to Andreas Taschner, I could test some more cards, including=20
3COM:

- both 3COM's (3C905CX and 3C595 with 3c59x driver) reset the flag fast
  enough for bonding to detect "up" from the start

- e100 (Compaq NC3120) took about 46 ms which was too late and slave
  started in "down", waiting for ARP monitor

- Marvell 88E8001 (skge driver) needs 2-3 seconds so that the patch
  prevented spurious failure

All tested cards can be divided into three groups:

1. patch helps: igb, e1000e, skge
2. no change: r8169, 8139too, 3c59x, tulip
3. delay introduced: e100

(I also tested a virtual e1000 in VMware Workstation guest, it falls=20
into group 2 - initial detection fast enough.)

IMHO the cards currently in use are much more likely to fall into first=
=20
group than into third.

                                                         Michal Kubecek
