From: Jan Kiszka <jan.kiszka@web.de>
Subject: Re: [PATCH] d80211: don't symlink empty default keys
Date: Wed, 10 Jan 2007 21:05:28 +0100
Message-ID: <45A54708.30307@web.de>
References: <45A4183E.4010401@web.de> <20070110204029.014cc96d@griffin.suse.cz>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha1;
 protocol="application/pgp-signature";
 boundary="------------enig88B601D1BA9F04C61A058476"
Cc: netdev@vger.kernel.org, Ivo Van Doorn <ivdoorn@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from fmmailgate02.web.de ([217.72.192.227]:38607 "EHLO
	fmmailgate02.web.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S965057AbXAJUFk (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 10 Jan 2007 15:05:40 -0500
To: Jiri Benc <jbenc@suse.cz>
In-Reply-To: <20070110204029.014cc96d@griffin.suse.cz>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

This is an OpenPGP/MIME signed message (RFC 2440 and 3156)
--------------enig88B601D1BA9F04C61A058476
Content-Type: text/plain; charset=ISO-8859-15
Content-Transfer-Encoding: quoted-printable

Jiri Benc wrote:
> On Tue, 09 Jan 2007 23:33:34 +0100, Jan Kiszka wrote:
>> This gets rid of annoying
>>
>> wlan0: cannot create symlink to default key
>>
>> in my syslog with latest rt2x00. The patch takes care that in case of
>> (key/old_key =3D=3D NULL && set_tx_key) the existing default key symli=
nk is
>> removed correctly. Moreover, it tests for key!=3DNULL before trying to=
 register
>> a new default link.
>>
>> Signed-off-by: Jan Kiszka <jan.kiszka@web.de>
>>
>> ---
>>  ieee80211/ieee80211_ioctl.c |    6 +++---
>>  1 file changed, 3 insertions(+), 3 deletions(-)
>>
>> Index: rt2x00/ieee80211/ieee80211_ioctl.c
>> =3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D
>> --- rt2x00.orig/ieee80211/ieee80211_ioctl.c
>> +++ rt2x00/ieee80211/ieee80211_ioctl.c
>> @@ -629,7 +629,7 @@ static int ieee80211_set_encryption(stru
>>  		}
>>  		kfree(keyconf);
>> =20
>> -		if (key && sdata->default_key =3D=3D key) {
>> +		if (set_tx_key || (key && sdata->default_key =3D=3D key)) {
>>  			ieee80211_key_sysfs_remove_default(sdata);
>=20
> This is not correct when set_tx_key is set and sdata->default_key is
> NULL.

Hmm, is this required? Will sysfs_remove_link panic on non-existent
nodes? If yes or if it's considered better style, are you OK with
catching NULL in ieee80211_key_sysfs_remove_default and refactoring the
existing tests along this way?

Jan


--------------enig88B601D1BA9F04C61A058476
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: OpenPGP digital signature
Content-Disposition: attachment; filename="signature.asc"

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.4.6 (MingW32)
Comment: Using GnuPG with Mozilla - http://enigmail.mozdev.org

iD8DBQFFpUcIniDOoMHTA+kRAmaDAJ9Qgxf9NYSnBn+lormlDSba5AvY9gCdHWUT
w3Vxe8Al9VOjcGpEIENwBi0=
=1Mdl
-----END PGP SIGNATURE-----

--------------enig88B601D1BA9F04C61A058476--
