From: Doug Ledford <dledford-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>
Subject: Re: [RESEND PATCH v7 17/21] IB/hns: Add QP operations support
Date: Fri, 13 May 2016 18:04:00 -0400
Message-ID: <16fc19ea-308a-ceee-d2da-4de93c66e2d7@redhat.com>
References: <1462849483-67927-1-git-send-email-oulijun@huawei.com>
 <1462849483-67927-18-git-send-email-oulijun@huawei.com>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha256;
 protocol="application/pgp-signature";
 boundary="gqmVEoNUsX4c6WUwINla6lvFkkGeFnUcm"
Cc: linux-rdma-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, gongyangming-hv44wF8Li93QT0dZR+AlfA@public.gmane.org,
	xiaokun-hv44wF8Li93QT0dZR+AlfA@public.gmane.org, tangchaofei-hv44wF8Li93QT0dZR+AlfA@public.gmane.org, haifeng.wei-hv44wF8Li93QT0dZR+AlfA@public.gmane.org,
	yisen.zhuang-hv44wF8Li93QT0dZR+AlfA@public.gmane.org, yankejian-hv44wF8Li93QT0dZR+AlfA@public.gmane.org,
	charles.chenxin-hv44wF8Li93QT0dZR+AlfA@public.gmane.org, linuxarm-hv44wF8Li93QT0dZR+AlfA@public.gmane.org
To: Lijun Ou <oulijun-hv44wF8Li93QT0dZR+AlfA@public.gmane.org>, sean.hefty-ral2JQCrhuEAvxtiuMwx3w@public.gmane.org,
	hal.rosenstock-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org, davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org,
	jeffrey.t.kirsher-ral2JQCrhuEAvxtiuMwx3w@public.gmane.org, jiri-VPRAkNaXOzVWk0Htik3J/w@public.gmane.org,
	ogerlitz-VPRAkNaXOzVWk0Htik3J/w@public.gmane.org
Return-path: <linux-rdma-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <1462849483-67927-18-git-send-email-oulijun-hv44wF8Li93QT0dZR+AlfA@public.gmane.org>
Sender: linux-rdma-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

This is an OpenPGP/MIME signed message (RFC 4880 and 3156)
--gqmVEoNUsX4c6WUwINla6lvFkkGeFnUcm
Content-Type: text/plain; charset=windows-1252
Content-Transfer-Encoding: quoted-printable

On 05/09/2016 11:04 PM, Lijun Ou wrote:
> +static void hns_roce_v1_cq_clean(struct hns_roce_cq *hr_cq, u32 qpn,
> +				 struct hns_roce_srq *srq)
> +{
> +	spin_lock_irq(&hr_cq->lock);
> +	hns_roce_v1_clean_cq(hr_cq, qpn, srq);
> +	spin_unlock_irq(&hr_cq->lock);
> +}

This is a perfect example of what I was talking about in my last email.
The convention here would be to name the main function
__hns_roce_v1_cq_clean and the wrapper hns_roce_v1_cq_clean.  Instead,
you have one named cq_clean and one named clean_cq.  Keeping straight
which of those locks itself and which needs to be called with the lock
held is nigh impossible.

--=20
Doug Ledford <dledford-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>
              GPG KeyID: 0E572FDD



--gqmVEoNUsX4c6WUwINla6lvFkkGeFnUcm
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: OpenPGP digital signature
Content-Disposition: attachment; filename="signature.asc"

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v2
Comment: Using GnuPG with Thunderbird - http://www.enigmail.net/

iQIcBAEBCAAGBQJXNk9QAAoJELgmozMOVy/d5KkQAKtVYYM4THOrYfL7ArX+qXUf
xzovO2VKoa9Vbf7OtuGlpfF1Uk/RSJVlNFyB5qEo58useH4x5VBTWIvBbtPIvtEC
o5PfkAvBfo6hRj7ZuHmxd4/OguZFVkxX7oZXr619Exv9dn33RmgAlWibv2TCYss4
3RUPBDylSkFTjtpr0HWzFOYa8u2KFbprZi477Xf1Ry9R/j25ezSXFgTvXSsGMLy1
cSnvBfvvXcS8sgGmj7Gr4BHWcJeCRcjWAkMe4e/MGA2wUR66gNfHdsbUgAo1u9Ur
ZHKKQjqVMb9N1zl4frfPrOkuNNgNX2PPEI0cR1QQMBJ1W0SpBAx2lMpo+cwp2TTh
Cl7c4PhfLgQNj3dnkkzmL8cEui4MEzKU7UBXuWLa8CFbP72VYPW6K/0e3MzI8OE/
+ng0OqWVIZhSwSZtYiG5a/+uSdH0nF8y4Fjou4ZXuN8RMKxL0bpJGZ7NZ1YEh/g/
wyRVQvQsb1CrdskjKjAUJGcgwbRkVF/9saW28RZ+rBXbJT+3E/j1AUBI3Ro+i6So
FaMjKA5d8IIAbmXJJsMWiKOGAeLHQkcs++NJpcr5eSHzI89QuB4fHVEkTqLKAzkK
HhmtmgVt/XfVV3OW4Zi/oaoOXpemXz3GhpsAlEb3xAc8n8t/RElCyIYHGjuDitE8
NfQHoQfCfX+pddFIMcLi
=5Mnc
-----END PGP SIGNATURE-----

--gqmVEoNUsX4c6WUwINla6lvFkkGeFnUcm--
--
To unsubscribe from this list: send the line "unsubscribe linux-rdma" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
