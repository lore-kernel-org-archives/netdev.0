From: David Laight <David.Laight@ACULAB.COM>
Subject: RE: [net-next 13/15] i40e/i40evf: use logical operators, not bitwise
Date: Mon, 22 Feb 2016 10:54:32 +0000
Message-ID: <063D6719AE5E284EB5DD2968C1650D6D1CCE6A53@AcuExch.aculab.com>
References: <1455766737-11911-1-git-send-email-jeffrey.t.kirsher@intel.com>
	 <1455766737-11911-14-git-send-email-jeffrey.t.kirsher@intel.com>
 <1455771536.4031.4.camel@perches.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=Windows-1252
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Mitch Williams <mitch.a.williams@intel.com>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"nhorman@redhat.com" <nhorman@redhat.com>,
	"sassmann@redhat.com" <sassmann@redhat.com>,
	"jogreene@redhat.com" <jogreene@redhat.com>
To: 'Joe Perches' <joe@perches.com>,
	Jeff Kirsher <jeffrey.t.kirsher@intel.com>,
	"davem@davemloft.net" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp-out6.electric.net ([192.162.217.193]:62613 "EHLO
	smtp-out6.electric.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753961AbcBVK6D convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 22 Feb 2016 05:58:03 -0500
In-Reply-To: <1455771536.4031.4.camel@perches.com>
Content-Language: en-US
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

=46rom: Joe Perches
> Sent: 18 February 2016 04:59
> On Wed, 2016-02-17 at 19:38 -0800, Jeff Kirsher wrote:
> > From: Mitch Williams <mitch.a.williams@intel.com>
> >
> > Mr. Spock would certainly raise an eyebrow to see us using bitwise
> > operators, when we should clearly be relying on logic. Fascinating.
>=20
> I think it read better before this change.
>=20
> Spock might have looked at the type of the
> variable before raising that eyebrow.
>=20
> clean_complete is bool so it's not actually a
> bitwise operation,

Except that, of course, you may well want a bitwise operation
in order to remove slow conditional instructions.

Hopefully gcc generates a bit-wise 'and' provided that i40e_clean_tx_ir=
q()
returns a 'bool'.

	David

> > diff --git a/drivers/net/ethernet/intel/i40e/i40e_txrx.c
> b/drivers/net/ethernet/intel/i40e/i40e_txrx.c
> []
> > @@ -1996,7 +1996,8 @@ int i40e_napi_poll(struct napi_struct *napi, =
int budget)
> > =A0	=A0* budget and be more aggressive about cleaning up the Tx des=
criptors.
> > =A0	=A0*/
> > =A0	i40e_for_each_ring(ring, q_vector->tx) {
> > -		clean_complete &=3D i40e_clean_tx_irq(ring, vsi->work_limit);
> > +		clean_complete =3D clean_complete &&
> > +				=A0i40e_clean_tx_irq(ring, vsi->work_limit);
>=20
> etc...
