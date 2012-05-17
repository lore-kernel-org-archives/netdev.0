From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: Re: [net-next 3/4] e1000: look in the page and not in skb->data for
 the last byte
Date: Thu, 17 May 2012 04:50:17 -0700
Message-ID: <1337255417.2714.49.camel@jtkirshe-mobl>
References: <1337254070-32500-1-git-send-email-jeffrey.t.kirsher@intel.com>
	 <1337254070-32500-4-git-send-email-jeffrey.t.kirsher@intel.com>
	 <4FB4E34F.2050004@linutronix.de>
Reply-To: jeffrey.t.kirsher@intel.com
Mime-Version: 1.0
Content-Type: multipart/signed; micalg="pgp-sha512";
	protocol="application/pgp-signature"; boundary="=-LJfKNAu6IVVgjZclgdXV"
Cc: davem@davemloft.net, netdev@vger.kernel.org, gospo@redhat.com,
	sassmann@redhat.com
To: Sebastian Andrzej Siewior <bigeasy@linutronix.de>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga11.intel.com ([192.55.52.93]:46491 "EHLO mga11.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1761468Ab2EQLuT (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 17 May 2012 07:50:19 -0400
In-Reply-To: <4FB4E34F.2050004@linutronix.de>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


--=-LJfKNAu6IVVgjZclgdXV
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: quoted-printable

On Thu, 2012-05-17 at 13:38 +0200, Sebastian Andrzej Siewior wrote:
> On 05/17/2012 01:27 PM, Jeff Kirsher wrote:
> > diff --git a/drivers/net/ethernet/intel/e1000/e1000_main.c b/drivers/ne=
t/ethernet/intel/e1000/e1000_main.c
> > index fefbf4d..6ac80c8 100644
> > --- a/drivers/net/ethernet/intel/e1000/e1000_main.c
> > +++ b/drivers/net/ethernet/intel/e1000/e1000_main.c
> > @@ -4066,7 +4066,11 @@ static bool e1000_clean_jumbo_rx_irq(struct e100=
0_adapter *adapter,
> >   		/* errors is only valid for DD + EOP descriptors */
> >   		if (unlikely((status&  E1000_RXD_STAT_EOP)&&
> >   		(rx_desc->errors&  E1000_RXD_ERR_FRAME_ERR_MASK))) {
> > -			u8 last_byte =3D *(skb->data + length - 1);
> > +			u8 *mapped;
> > +			u8 last_byte;
> > +
> > +			mapped =3D kmap_atomic(buffer_info->page);
> > +			last_byte =3D *(mapped + length - 1);
> >   			if (TBI_ACCEPT(hw, status, rx_desc->errors, length,
> >   				       last_byte)) {
> >   				spin_lock_irqsave(&adapter->stats_lock,
>=20
> This is not what I've sent. My original patch [0] hat a unmap as well.=
=20
> One comment was, that kmap_atomic() is too much overhead because the=20
> page can never be highmem. So I changed it to page_address() [1].
>=20
> [0] http://permalink.gmane.org/gmane.linux.drivers.e1000.devel/10008
> [1] http://permalink.gmane.org/gmane.linux.drivers.e1000.devel/10012
>=20
> Sebastian

Your correct, I apologize.  This was my fault, I applied your v1 of the
patch and then realized there was a v2.

I will re-send the series with the correct patch.

--=-LJfKNAu6IVVgjZclgdXV
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: This is a digitally signed message part
Content-Transfer-Encoding: 7bit

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.4.12 (GNU/Linux)

iQIcBAABCgAGBQJPtOX5AAoJEOVv75VaS+3OADcP/ir2P85z3qFbLHpVkcZltXXN
gV2O5D2Zk4eXmAMqMa8MLIZZoho/1nSQDM1vIeUIxDUYTiicwp40YfrKzYlVdPMp
YKBQV8zbcXvT5+9mxIllU79zUeeSZZicGc4YHj/0n3zBm3IpBqNfxqaZJBoU03VM
7f1+d7K+D8Tf1lFtih5deetipJwl1zb10wvKVQYHW6vGhXGWtzBVDSaSjwBbPa+f
8qPbjpN2CMATk4owQOuSbd8GCwOjX5fuJqQDgL5+p5NMwdhQmbl78kLPNjTiiSbm
2wHmc5vPQl0EAJDjsQYwGVW21FjRcjg0/wUbPzd8H/vD2veTDWr7dsmsr0RiNcJk
5FyPqpsp9eJkjP9tjNlcJhEhOyuFVXHHH95EBv3VXyRg9Z0Bhu745Wyb41x3I9Ji
+gwOtPCSxualWYVXIroU9vaH48vhJsmwxgPHc+7vYAWsOAF3Y/tBVH/yWE56sriw
IdFkcTdzwg7AC8+JiJMkQL3ICOG1SkgYOTxEFLS+mVOUFXLsT9CCUxEhzewChGeD
bGib4FNLGp4BMR3qGH0eUnEaNom7Kb2haC90OBU+diW9+RUVF7eC7AIP3uE3Az5L
J7Vh4hunP7otPRGn/qYk6O+ujD2XNvm/9NbK78AycGFRRg7QjUuRucZyakZ9zcvI
PrY0VSw/cnx8dnF3kDfg
=ITem
-----END PGP SIGNATURE-----

--=-LJfKNAu6IVVgjZclgdXV--
