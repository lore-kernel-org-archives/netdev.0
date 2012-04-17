From: Michal =?utf-8?B?S3ViZcSNZWs=?= <mkubecek@suse.cz>
Subject: Re: [PATCH v2] bonding: start slaves with link down for ARP monitor
Date: Tue, 17 Apr 2012 13:58:07 +0200
Message-ID: <1343782.ObcgmM0SbX@alaris>
References: <20120414220617.DA8BE45BA2@lion.mk-sys.cz> <19180.1334465333@death.nxdomain> <1410525.5tCeY2AOxF@alaris>
Reply-To: Michal =?utf-8?B?S3ViZcSNZWs=?= <mkubecek@suse.cz>
Mime-Version: 1.0
Content-Type: text/plain; charset=iso-8859-2
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Flavio Leitner <fbl@redhat.com>, netdev@vger.kernel.org,
	Andy Gospodarek <andy@greyhouse.net>
To: Jay Vosburgh <fubar@us.ibm.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from cantor2.suse.de ([195.135.220.15]:43141 "EHLO mx2.suse.de"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754876Ab2DQL6J convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 17 Apr 2012 07:58:09 -0400
In-Reply-To: <1410525.5tCeY2AOxF@alaris>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Monday 16 of April 2012 12:27EN, Michal Kube=E8ek wrote:
> On Saturday 14 of April 2012 21:48EN, Jay Vosburgh wrote:
> > Anybody got a 10 or 100 card laying around with fast autoneg to
> > try?  Back in the day I used 3c59x and e100s, and I seem to recall
> > that the 3c59x board I had was pretty speedy at going carrier up.
>=20
> It seems these cards are hard to find these days (I tried to find one
> in our office but no luck yet). However, I tried an onboard adapter
> with r8169 driver and patched kernel succeeded to detect carrier in
> time for bonding driver to start the slave in "up" state (and it
> started in "down" state with unplugged cable so that the detection is
> correct).

I tested few more cards:

- two 100 Mb/s Realtek 8139C and 8139D with 8139too driver:
  driver sets carrier on soon enough and slave starts with "up" and
  stays that way (same as r8169)

- 1 Gb/s Intel Pro/1000PT (82572EI) with e1000e driver:
  essentially the same as igb, driver is slow and patch prevents the
  up -> down -> up sequence by starting the slave in "down" state

- 100 Mb/s Intel (?) cards with DECchip Tulip 21142/3, tulip driver:
  card/driver either doesn't set the flag properly or is extremely slow
  with up -> down transition so that the state was "up" all the time
  no matter what the real link state was

I'll resend v3 with fixed style problem in a moment.

                                                        Michal Kubecek
