From: "Rustad, Mark D" <mark.d.rustad@intel.com>
Subject: Re: [PATCH] ixgbe: Look up MAC address in Open Firmware
Date: Mon, 17 Nov 2014 23:29:45 +0000
Message-ID: <E5B679BA-48C8-47D9-9299-BC8C32000E2A@intel.com>
References: <yq1r3x5vbh9.fsf@sermon.lab.mkp.net>
 <54666106.9000609@cogentembedded.com> <yq1mw7tv8jq.fsf@sermon.lab.mkp.net>
Mime-Version: 1.0
Content-Type: multipart/signed;
	boundary="Apple-Mail=_3F67BFB1-BF2C-48B7-83E9-5433409FCE1B";
	protocol="application/pgp-signature"; micalg=pgp-sha1
Cc: Sergei Shtylyov <sergei.shtylyov@cogentembedded.com>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	Linux NICS <Linux-nics@isotope.jf.intel.com>
To: "Martin K. Petersen" <martin.petersen@oracle.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga01.intel.com ([192.55.52.88]:3953 "EHLO mga01.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751499AbaKQX37 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 17 Nov 2014 18:29:59 -0500
In-Reply-To: <yq1mw7tv8jq.fsf@sermon.lab.mkp.net>
Content-Language: en-US
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

--Apple-Mail=_3F67BFB1-BF2C-48B7-83E9-5433409FCE1B
Content-Transfer-Encoding: quoted-printable
Content-Type: text/plain;
	charset=us-ascii

On Nov 14, 2014, at 12:20 PM, Martin K. Petersen =
<martin.petersen@oracle.com> wrote:

> /**
> + * ixgbe_of_mac_addr - Look up MAC address in Open Firmware
> + * @adapter: Pointer to adapter struct
> + */
> +static void ixgbe_of_mac_addr(struct ixgbe_adapter *adapter)
> +{
> +#ifdef CONFIG_OF
> +	struct device_node *dp =3D pci_device_to_OF_node(adapter->pdev);
> +	struct ixgbe_hw *hw =3D &adapter->hw;
> +	const unsigned char *addr;
> +	int len;
> +
> +	addr =3D of_get_property(dp, "local-mac-address", &len);
> +	if (addr && len =3D=3D 6) {
> +		e_dev_info("Using OpenPROM MAC address\n");
> +		memcpy(hw->mac.perm_addr, addr, 6);
> +	}
> +
> +	if (!is_valid_ether_addr(hw->mac.perm_addr)) {
> +		e_dev_info("Using IDPROM MAC address\n");
> +		memcpy(hw->mac.perm_addr, idprom->id_ethaddr, 6);
> +	}
> +#endif
> +}

I would prefer that the entire function be wrapped by the #if so that a =
null implementation can include the prototype. That allows the unused =
parameter to properly be declared as __always_unused as in:

#else
static void ixgbe_of_mac_addr(struct ixgbe_adapter __always_unused =
*adapter)
{}
#endif /* CONFIG_OF */

Otherwise, it will throw warnings when compiled with enhanced warning =
messages.

--=20
Mark Rustad, Networking Division, Intel Corporation


--Apple-Mail=_3F67BFB1-BF2C-48B7-83E9-5433409FCE1B
Content-Transfer-Encoding: 7bit
Content-Disposition: attachment; filename="signature.asc"
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: Message signed with OpenPGP using GPGMail

-----BEGIN PGP SIGNATURE-----
Comment: GPGTools - http://gpgtools.org

iQIcBAEBAgAGBQJUaoTpAAoJEDwO/+eO4+5ul1sQAIwcX2eD6VW4EFIcSLNCENNL
hhGfoT6E5bQx+KXbm94OLAWYN2mreyxVFb3YA/88/ky/nnU6gqm5TVBF1PBZu+q4
93bYSoLYyxGmaIiYgQqCKdVh8QIdhmEuhYnUOKj+K2lcqkknvxmJ7PWaRGGmllN6
MkjnLAYAflZvplPka03HuiQIRwz8l6F13y+3W8QxBWOaGuWDIn0+gJm/IeDpe5Im
2xEeYhPZpvTKCXx5iSoTzPBuEPWduYIP8iNeSeK5CbohINj9uASw8MPP7MUMUt/k
oUtLDEHJrNgNwGerLMyNzeTMRybxXov1jWcw7vcOzGnu8NfUV/uTY5lWwkoqEJJF
Noir1QGxGphbBE8mrFaqhjdgkGL7ulcQxtQwiisHZWI523o9ywXGcuNsf6oUrF13
aLzPaZ8dvb2XPEzIYleQOiEtyf3Dq1HcRTh3pGkYrP1W8ehHLZoxT3zF/O78P/YK
1YPnV/N8s+JBGgAGtionpNZNiKr9pgkUU0dkD/MTMQWQPXd3kEMB9atWngKfLlfG
5F8PcIWJPV+tClwImjgCE+UpJzOk4PY/vnPbRy+1Ow8sdTHZ3GwwkM/Gf06tchbT
xxt+GSWd56F4x7ZA/Qn88Pm8PHXZIf8YKN4ZIAlcOE/FaMG+rDuxn59XtdcFLgHk
nqeN6XlHD9x1kHi1yoja
=VV5n
-----END PGP SIGNATURE-----

--Apple-Mail=_3F67BFB1-BF2C-48B7-83E9-5433409FCE1B--
