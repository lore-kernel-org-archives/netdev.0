From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: Re: [E1000-devel] [PATCH net-next] igb: add delay to allow igb
 loopback test to succeed on 8086:10c9
Date: Wed, 01 Aug 2012 18:06:49 -0700
Message-ID: <1343869609.2132.2.camel@jtkirshe-mobl>
References: <1343821463-18052-1-git-send-email-sassmann@kpanic.de>
Reply-To: jeffrey.t.kirsher@intel.com
Mime-Version: 1.0
Content-Type: multipart/signed; micalg="pgp-sha512";
	protocol="application/pgp-signature"; boundary="=-PHMFn7byRSejreI8pDGr"
Cc: netdev@vger.kernel.org, e1000-devel@lists.sourceforge.net
To: Stefan Assmann <sassmann@kpanic.de>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga14.intel.com ([143.182.124.37]:34183 "EHLO mga14.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751455Ab2HBBGw (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 1 Aug 2012 21:06:52 -0400
In-Reply-To: <1343821463-18052-1-git-send-email-sassmann@kpanic.de>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


--=-PHMFn7byRSejreI8pDGr
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: quoted-printable

On Wed, 2012-08-01 at 13:44 +0200, Stefan Assmann wrote:
> Some 8086:10c9 NICs have a problem completing the ethtool loopback
> test.
> The result looks like this:
>=20
> ethtool -t eth1
> The test result is FAIL
> The test extra info:
> Register test  (offline)         0
> Eeprom test    (offline)         0
> Interrupt test (offline)         0
> Loopback test  (offline)         13
> Link test   (on/offline)         0
>=20
> A bisect clearly points to commit
> a95a07445ee97a2fef65befafbadcc30ca1bd145.
> However that seems to only trigger the bug. While adding some printk
> the
> problem disappeared, so this might be a timing issue. After some trial
> and
> error I discovered that adding a small delay just before
> igb_write_phy_reg()
> in igb_integrated_phy_loopback() allows the loopback test to succeed.
> I was unable to figure out the root cause so far but I expect it to be
> somewhere in the following executing path
> igb_integrated_phy_loopback
> ->igb_write_phy_reg_igp
>   ->igb_write_phy_reg_mdic
>     ->igb_acquire_phy_82575
>       ->igb_acquire_swfw_sync_82575
>=20
> As this workaround only introduces a minor delay, which is not in the
> hot
> path I hope this is acceptable. The problem could only be oberved on
> 8086:10c9 NICs so far and not all of them show the behaviour. I did
> not
> restrict the workaround to this type of NIC as it should do no harm to
> other igb NICs.
>=20
> With the patch below the loopback test succeeded 500 times in a row
> using a NIC that would otherwise fail.
>=20
> Signed-off-by: Stefan Assmann <sassmann@kpanic.de>
> ---
>  drivers/net/ethernet/intel/igb/igb_ethtool.c |    3 +++
>  1 files changed, 3 insertions(+), 0 deletions(-)=20

Thanks Stefan, I have added the patch to my queue.

--=-PHMFn7byRSejreI8pDGr
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: This is a digitally signed message part
Content-Transfer-Encoding: 7bit

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.4.12 (GNU/Linux)

iQIcBAABCgAGBQJQGdKpAAoJEOVv75VaS+3OoNgP/R5WZgKxShxDIz5U57bO60Kr
MIad6+JgVfiCnduoC/0lcdPco76mVmdYdXN8vJl6pwxbgrxqDp31ASdYH/cFpDh/
bntzebYMNmWgt0n0pqvzeH4PappWqBBFt31va7L16dCMsIVdH68wXOSP3waxZ2BV
OtdYkQ3kDkH90Y2Ykloer/Fhb2pIoSAE9s9NMAf6FVZkXzPzauk3mWy6i4q20iHN
5cyc/6dwU9YvznVl3aTznWPqJSHIsnpugKpiDl4skJbqQ4PK60L0GduKyVVLjvMT
43LquWy9S5KOdKTj+zOq2BOHyzdNQsQaW+JME2ryMZB2+fwcHi2FvyQI9jtXiPKm
k/OSCnXTvOqUCeKwyke9vJLFmU9RxeZ7Sb5D1nLYHH/VSrWC50jXzkdtSvDU+E0+
aJIhK07DpGKAlnwvKogBNAPhMcAjpJV+8hgZTQmbgvRDBnkzijmd0u5ysQuHpXdV
LBY2wMKDkUguqmGAWWoUO6LRtUtRlspJpB2RwaCwh5iczpyRGUxYMtk8cebiE0ay
cz1hQev9GNL2iahiuVkhU9mH3NaRMwdldVTrVcMhTJqxk0Wu79bPOZ1rCLJVjluP
yZ6Eq0KtJG5ymH7H0CwhksNvwV9Wl4MVCc7fPLlz+Xc1sWKq7EU//X4RLvasAeoH
s7yV1gtNlESIXPq+snG9
=PooR
-----END PGP SIGNATURE-----

--=-PHMFn7byRSejreI8pDGr--
