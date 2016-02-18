From: Joe Perches <joe@perches.com>
Subject: Re: [net-next 13/15] i40e/i40evf: use logical operators, not bitwise
Date: Wed, 17 Feb 2016 20:58:56 -0800
Message-ID: <1455771536.4031.4.camel@perches.com>
References: <1455766737-11911-1-git-send-email-jeffrey.t.kirsher@intel.com>
	 <1455766737-11911-14-git-send-email-jeffrey.t.kirsher@intel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Mitch Williams <mitch.a.williams@intel.com>,
	netdev@vger.kernel.org, nhorman@redhat.com, sassmann@redhat.com,
	jogreene@redhat.com
To: Jeff Kirsher <jeffrey.t.kirsher@intel.com>, davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtprelay0160.hostedemail.com ([216.40.44.160]:47398 "EHLO
	smtprelay.hostedemail.com" rhost-flags-OK-OK-OK-FAIL)
	by vger.kernel.org with ESMTP id S1424543AbcBRE7A (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 17 Feb 2016 23:59:00 -0500
In-Reply-To: <1455766737-11911-14-git-send-email-jeffrey.t.kirsher@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, 2016-02-17 at 19:38 -0800, Jeff Kirsher wrote:
> From: Mitch Williams <mitch.a.williams@intel.com>
>=20
> Mr. Spock would certainly raise an eyebrow to see us using bitwise
> operators, when we should clearly be relying on logic. Fascinating.

I think it read better before this change.

Spock might have looked at the type of the
variable before raising that eyebrow.

clean_complete is bool so it's not actually a
bitwise operation,

> diff --git a/drivers/net/ethernet/intel/i40e/i40e_txrx.c b/drivers/ne=
t/ethernet/intel/i40e/i40e_txrx.c
[]
> @@ -1996,7 +1996,8 @@ int i40e_napi_poll(struct napi_struct *napi, in=
t budget)
> =A0	=A0* budget and be more aggressive about cleaning up the Tx descr=
iptors.
> =A0	=A0*/
> =A0	i40e_for_each_ring(ring, q_vector->tx) {
> -		clean_complete &=3D i40e_clean_tx_irq(ring, vsi->work_limit);
> +		clean_complete =3D clean_complete &&
> +				=A0i40e_clean_tx_irq(ring, vsi->work_limit);

etc...
