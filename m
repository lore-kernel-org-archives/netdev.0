From: Sven Eckelmann <sven.eckelmann@openmesh.com>
Subject: Re: [REGRESSION] mac80211: IBSS vif queue stopped when started after 11s vif
Date: Wed, 29 Mar 2017 14:11:08 +0200
Message-ID: <1889117.GdG6vIS4EM@bentobox>
References: <1978424.XTv2Qph05K@bentobox> <5090047.94hdUy33Q8@bentobox> <1490788386.7948.21.camel@sipsolutions.net>
Mime-Version: 1.0
Content-Type: multipart/signed; boundary="nextPart15861504.LmPm9Y6aJZ"; micalg="pgp-sha512"; protocol="application/pgp-signature"
Cc: linux-wireless@vger.kernel.org, netdev@vger.kernel.org,
        Michal Kazior <michal.kazior@tieto.com>
To: Johannes Berg <johannes@sipsolutions.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wr0-f179.google.com ([209.85.128.179]:34948 "EHLO
        mail-wr0-f179.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1755445AbdC2MLM (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 29 Mar 2017 08:11:12 -0400
Received: by mail-wr0-f179.google.com with SMTP id k6so5974649wre.2
        for <netdev@vger.kernel.org>; Wed, 29 Mar 2017 05:11:11 -0700 (PDT)
In-Reply-To: <1490788386.7948.21.camel@sipsolutions.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

--nextPart15861504.LmPm9Y6aJZ
Content-Transfer-Encoding: quoted-printable
Content-Type: text/plain; charset="iso-8859-1"

On Mittwoch, 29. M=E4rz 2017 13:53:06 CEST Johannes Berg wrote:
[...]
> > Not sure whether removing it in ieee80211_propagate_queue_wake will
> > have other odd side effects with software queuing. Maybe Michal
> > Kazior can tell us if it is safe to remove it.
>=20
> No, it's the other way around.
>=20
> Michal's patches correctly added a test for this to
> __ieee80211_stop_queue(), the only missing thing is that this test
> should also be in ieee80211_do_open() like this:
>=20
> diff --git a/net/mac80211/iface.c b/net/mac80211/iface.c
> index 40813dd3301c..5bb0c5012819 100644
> --- a/net/mac80211/iface.c
> +++ b/net/mac80211/iface.c
> @@ -718,7 +718,8 @@ int ieee80211_do_open(struct wireless_dev *wdev, bool=
 coming_up)
>  	ieee80211_recalc_ps(local);
> =20
>  	if (sdata->vif.type =3D=3D NL80211_IFTYPE_MONITOR ||
> -	    sdata->vif.type =3D=3D NL80211_IFTYPE_AP_VLAN) {
> +	    sdata->vif.type =3D=3D NL80211_IFTYPE_AP_VLAN ||
> +	    local->ops->wake_tx_queue) {
>  		/* XXX: for AP_VLAN, actually track AP queues */
>  		netif_tx_start_all_queues(dev);
>  	} else if (dev) {

Yes, this also works.

Kind regards,
	Sven
--nextPart15861504.LmPm9Y6aJZ
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: This is a digitally signed message part.
Content-Transfer-Encoding: 7Bit

-----BEGIN PGP SIGNATURE-----

iQIzBAABCgAdFiEEF10rh2Elc9zjMuACXYcKB8Eme0YFAljbpFwACgkQXYcKB8Em
e0ZKyw/8CKOKbDYndWLYWJZ9E4taFtoU9jtSCE9oL2H5jR0iytP5oeHd09CTZtOK
VRXBvmEvmVj0p+7gIU/7fgZG9yIiJ0yH+kQ/6V6UMvOvuR1jW8uM5A0PVViu7P56
7Ug+m+b0J58kTvvsam60KVQsUTJyk2MXSeywVh3QAfZRDjkts2VMIWMNWTiQnRf/
qkhbEAdvtKdseYxS67A75wyUM0qDmsTlAnCPb0jF9aaCGUc7QeN6ZuCwYD7iSyAg
VnoKRfJWG7DGKSb7QCERDNWlO0qNS5PJSUPUlNypZD/939wxmaA2kPgvZGjCKyXh
Z/TNV2meKyqsu/AgRNUHktw4KTtGb75zIrUGAw2/OJcREK6pleOa4egkw2iCV01W
bj+56dQ3VLNVUYxvvFlpfoqCttzX8R28pLpqDYdJmCfk2ffJtGhu1wf1DH/iTkjH
hF1b+fF65+jzK+orPMPr38Z9dBfsRh6QzeUzDS1OfyXOGalsNrRJiMh0cCwWL53a
HFU4w5ZU1hpFVToKDKY6LrOMfhzbFdgKmjayWORTyTY8TyPr4Uqp4bv5kRW5sznv
mlSf/3m0o/VrVNzmldpamCUBj8hvKqH4N53DG/L0NaSJNGmUtFpA8wVh14dIEzyU
FKuETcHy/5r9bj4TW2g0faYt805J7hD0B+OC1k6TB4iPlwElDBI=
=xwpE
-----END PGP SIGNATURE-----

--nextPart15861504.LmPm9Y6aJZ--
