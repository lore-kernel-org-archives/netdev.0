From: Sebastian Reichel <sre-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org>
Subject: Re: [PATCH v3 3/4] bluetooth: hci_uart: add LL protocol serdev
 driver support
Date: Sat, 15 Apr 2017 21:48:54 +0200
Message-ID: <20170415194854.byado7bxupbdhivp@earth>
References: <20170413150353.7389-1-robh@kernel.org>
 <20170413150353.7389-4-robh@kernel.org>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha512;
        protocol="application/pgp-signature"; boundary="agbrdpyrwwvtb7cb"
Cc: Marcel Holtmann <marcel-kz+m5ild9QBg9hUCZPvPmw@public.gmane.org>,
        linux-bluetooth-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
        linux-arm-kernel-IAPFreCvJWM7uuMidbF8XUB+6BGkLq7r@public.gmane.org,
        Gustavo Padovan <gustavo-THi1TnShQwVAfugRpC6u6w@public.gmane.org>,
        Johan Hedberg <johan.hedberg-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>,
        Mark Rutland <mark.rutland-5wv7dgnIgG8@public.gmane.org>,
        Wei Xu <xuwei5-C8/M+/jPZTeaMJb+Lgu22Q@public.gmane.org>, Eyal Reizer <eyalr-l0cyMroinI0@public.gmane.org>,
        Satish Patel <satish.patel-QSEj5FYQhm4dnm+yROfE0A@public.gmane.org>, netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
        devicetree-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
To: Rob Herring <robh-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org>
Return-path: <devicetree-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
Content-Disposition: inline
In-Reply-To: <20170413150353.7389-4-robh-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org>
Sender: devicetree-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org


--agbrdpyrwwvtb7cb
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline

Hi,

On Thu, Apr 13, 2017 at 10:03:52AM -0500, Rob Herring wrote:
> +static int read_local_version(struct hci_dev *hdev)
> +{
> +	int err = 0;
> +	unsigned short version = 0;
> +	struct sk_buff *skb;
> +	struct hci_rp_read_local_version *ver;
> +
> +	skb = __hci_cmd_sync(hdev, HCI_OP_READ_LOCAL_VERSION, 0, NULL, HCI_INIT_TIMEOUT);
> +	if (IS_ERR(skb)) {
> +		bt_dev_err(hdev, "Reading TI version information failed (%ld)",
> +			   PTR_ERR(skb));
> +		err = PTR_ERR(skb);
> +		goto out;

If __hci_cmd_sync() fails the code tries to kfree_skb() an error pointer
resulting in NULL pointer dereference warning + strack trace. This
can just return err instead.

> +	}
> +	if (skb->len != sizeof(*ver)) {
> +		err = -EILSEQ;
> +		goto out;
> +	}
> +
> +	ver = (struct hci_rp_read_local_version *)skb->data;
> +	if (le16_to_cpu(ver->manufacturer) != 13) {
> +		err = -ENODEV;
> +		goto out;
> +	}
> +
> +	version = le16_to_cpu(ver->lmp_subver);
> +
> +out:
> +	if (err) bt_dev_err(hdev, "Failed to read TI version info: %d", err);
> +	kfree_skb(skb);
> +	return err ? err : version;
> +}

-- Sebastian

--agbrdpyrwwvtb7cb
Content-Type: application/pgp-signature; name="signature.asc"

-----BEGIN PGP SIGNATURE-----

iQIzBAABCgAdFiEE72YNB0Y/i3JqeVQT2O7X88g7+poFAljyeSQACgkQ2O7X88g7
+poEEA/5AYD6nBWwKDCfL7FxsyOf67BEnX+lmrbC/YuheR5Ms+jNTUd6aV3eri4q
wUKuDQ2/kO8NJG2abB+PYQLwkHfWuGbOyOr0eIdRi7nNRFje2IJIZQ3IItlqP1do
1H9YiKv5nCo8Q6RKuhr4onYXjGC1SRLLqIioKBIfVK834jadUi/jxllAU4RRdls3
qqXbGjqLlLhFaMzDTK7OQRKQRlMHoPLUoM4W4qp205fLmBF61AYiTEi3FNdaYi1G
ShkmzFTnaEpyLtvFlU/dFm50suZgZZ1FN8jrg45P2pJw7XMXiYGP1mA3+EqKNPik
QT984FMAkObCObHHc1+R5AHeXg16N3P3ReQbGnVJ4yzzaFoGNRWqnT+tYrSVNXAz
YADpppKu8HCv0wShcxU6l/4PPLKHlqGD1GRFvF+qV1M6Rszwxx4sd3rOl9LPev0K
EbLXxl4vJUYeLz7xBuG3yLTIFvTdLxw1G9aCvP/AE9gL1Nb9IIT3HXpnCyCL9nDm
5jRaxyL1IcOGJoO+lCsk1ckmXwzn//2HoTfJdig1ZklcdKJUFPjSAAzirVPZV8cS
18OqUxWcAetrOyaE4MCiw5GXoP11N38Kc9ner04XOk8I2zGiIrBSK5nM1o3DkU6T
H4qxH0fCaCDfI2e1TwiZ1g/ToShgE0PvbnFEivpXzPHY3fYvWgo=
=mBSk
-----END PGP SIGNATURE-----

--agbrdpyrwwvtb7cb--
--
To unsubscribe from this list: send the line "unsubscribe devicetree" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
