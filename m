From: Dan Carpenter <dan.carpenter@oracle.com>
Subject: Re: [patch] enic: fix an endian bug in enic_probe()
Date: Fri, 2 Mar 2012 09:06:53 +0300
Message-ID: <20120302060653.GU1003@mwanda>
References: <20120301071954.GA7152@elgon.mountain>
 <20120301.172408.1182768164929080163.davem@davemloft.net>
 <184D23435BECB444AB6B9D4630C8EC8303853051@XMB-RCD-303.cisco.com>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha1;
	protocol="application/pgp-signature"; boundary="f6M9UaX53EEZorp0"
Cc: David Miller <davem@davemloft.net>,
	"Roopa Prabhu (roprabhu)" <roprabhu@cisco.com>,
	"Neel Patel (neepatel)" <neepatel@cisco.com>,
	"Nishank Trivedi (nistrive)" <nistrive@cisco.com>,
	netdev@vger.kernel.org, kernel-janitors@vger.kernel.org
To: "Christian Benvenuti (benve)" <benve@cisco.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from acsinet15.oracle.com ([141.146.126.227]:34062 "EHLO
	acsinet15.oracle.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756129Ab2CBGEu (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 2 Mar 2012 01:04:50 -0500
Content-Disposition: inline
In-Reply-To: <184D23435BECB444AB6B9D4630C8EC8303853051@XMB-RCD-303.cisco.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


--f6M9UaX53EEZorp0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
Content-Transfer-Encoding: quoted-printable

On Thu, Mar 01, 2012 at 07:23:45PM -0600, Christian Benvenuti (benve) wrote:
> Thanks Dan, David.
>=20
> Just one quick comment...
> pci_enable_sriov's 2nd input is declared as type int and we
> were using u32 instead (for a non negative 16bit value).
> With a quick check I noticed that other pci_enable_sriov callers
> do something similar and may need to be taken care too:
>=20

The problem was calling pci_read_config_word() not
pci_enable_sriov().  I did consider passing a temporary variable to
pci_read_config_word() and then storing that in num_vfs but it
seemed more complicated.

Looking at the other drivers now, I see that's how some of them do
it.  But it makes sense for them because they have the num_vfs which
the user can configure and the number from the hardware which is the
max that are supported.

Either way would fix it, but I feel that my fix is not terribly
ugly.

regards,
dan carpenter

--f6M9UaX53EEZorp0
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: Digital signature

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.4.11 (GNU/Linux)

iQIcBAEBAgAGBQJPUGN9AAoJEOnZkXI/YHqRSkoP/3AFsh36V6JIOrJdUdgD7jP5
s3GKeRNIwaVlTzHBv2o1eC8GP3zCYIp0kf295oZFqgw7bOAPU2aTMzFLQ7rTTJQl
zfGWQTlr20fgRn4U5DwM43jN/4Y7NPzeqcTjw7oqhqus1ZwVyE+2rqsMYzuR7prT
YziULMVPY9Ed+TUG06E9j888iEGkk08WgZsrYSeRlJxYDfOlbIQgVfoTMtqiQr67
jiR2+LGnWIWZ8O3atzKWuxpgTQ2knHim1/J1aZZzXwkIsryKv/W6gtNDgLEHMOWW
PnN/hgEt6AedK4cCYVA/RE596ei/mC5pmG44y/CVjczDrq9r2r5zIng6auyr1bWO
PEvPFXtD53bVziQGKnQWs+XOMIWmPwZe1Ywals5N7H1lxomqfKS1Mzm6gEOcH2DR
HwvznZTwWS2ZFIXxQWkUsCc0rxLWi7lOcNKhQ+LnIk8xWsCQDJtSvSkCQ37kGzH6
wI1pZGY5EspBwVhV5COfcF+VOAS6hS4ijSjD+iANWdPz48r01eU/TNEWMKzoGUsh
qhMmzGUXKvBPSSelXcCxbrWEwMWRW8QE7ThJe/dPAYynxOZldeNGmrayHF1VBTwZ
TsSTVN+vE1Xy7iLKEyltUNtiI8F3kS/F5O2E/dBuKyJzXLmCdyNI+ArZoS+mLkMl
r8N9UyCzTwQdnB/dWOru
=crUR
-----END PGP SIGNATURE-----

--f6M9UaX53EEZorp0--
