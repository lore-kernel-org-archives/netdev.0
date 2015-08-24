From: Corinna Vinschen <vinschen@redhat.com>
Subject: Re: [PATCH v2 net-next] r8169: Add values missing in @get_stats64
 from HW counters
Date: Mon, 24 Aug 2015 12:29:35 +0200
Message-ID: <20150824102935.GM19683@calimero.vinschen.de>
References: <1439888664-28620-1-git-send-email-vinschen@redhat.com>
 <1440151756-18165-1-git-send-email-vinschen@redhat.com>
 <20150821193926.GA16437@electric-eye.fr.zoreil.com>
 <20150821220756.GI19683@calimero.vinschen.de>
 <20150821235940.GA20313@electric-eye.fr.zoreil.com>
 <20150822083916.GA17408@calimero.vinschen.de>
 <20150822112334.GB24519@electric-eye.fr.zoreil.com>
 <20150824073348.GL19683@calimero.vinschen.de>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha256;
	protocol="application/pgp-signature"; boundary="dMyqICaxQaaUjrCL"
To: Francois Romieu <romieu@fr.zoreil.com>, netdev@vger.kernel.org,
	Hayes Wang <hayeswang@realtek.com>,
	Ivan Vecera <ivecera@redhat.com>,
	David Miller <davem@davemloft.net>,
	nic_swsd <nic_swsd@realtek.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-n.franken.de ([193.175.24.27]:41695 "EHLO
	mail-n.franken.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751079AbbHXK3i (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 24 Aug 2015 06:29:38 -0400
Content-Disposition: inline
In-Reply-To: <20150824073348.GL19683@calimero.vinschen.de>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


--dMyqICaxQaaUjrCL
Content-Type: text/plain; charset=utf-8
Content-Disposition: inline
Content-Transfer-Encoding: quoted-printable

On Aug 24 09:33, Corinna Vinschen wrote:
> On Aug 22 13:23, Francois Romieu wrote:
> > Corinna Vinschen <vinschen@redhat.com> :
> > [...]
> > > That won't happen with the current patch because only
> > > rtl8169_reset_counters would print a log message, it's only called fr=
om
> > > open, and open occurs rather seldom.  Atop of that the code only tries
> > > to reset counters on HW supporting it, and only if resetting on the HW
> > > fails, there will be a log message at all.  There's no reasonable cha=
nce
> > > that failing to reset the counters will lead to log flooding.
> >=20
> > Thanks for reformulating it. We are in violent agreement here.
> >=20
> > [...]
> > > I'm not trying to avoid work, I'm trying to understand.
> > >=20
> > > As far as I see it failing to reset the counters has no impact on the
> > > viability of the code.  It's still working with offsets and if the
> > > offset is 0 or non-0, the user space won't see the difference in the
> > > values returned by @get_stats64.  Successful resetting the counters is
> > > just a bonus.
> >=20
> > Sorry, my english was really bad:
> >=20
> > the code should propagate failure when rtl8169_reset_counters and
> > rtl8169_update_counters *simultaneously* fail.
>=20
> Uhm... sorry, but that still doesn't answer the question.  As you can
> see in my patch, the initalization at open time is already encapsulated
> in a function rtl8169_init_counter_offsets.=20
>=20
> Assuming rtl8169_init_counter_offsets returns -1 if both functions,
> rtl8169_reset_counters and rtl8169_update_counters fail.
>=20
> Then... what?
>=20
> Not being able to reset or update the counters is still not at all fatal
> for the operation of the NIC as a whole and rtl_open in particular:
>=20
>   rtl_open()
>   {
>     [...]
>=20
>     /* This is non-fatal. */
>     if (!rtl8169_init_counter_offsets ()) {
>=20
> 	  /* What to do here??? */
>=20
>     }
>=20
>     [...]
>   }

Never mind, I rearranged the code so that the warning is now printed
in rtl_open.  All functions related to the counter reset/update are
now bool functions.  I just sent a v3 patch.


Corinna

--dMyqICaxQaaUjrCL
Content-Type: application/pgp-signature

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v2

iQIcBAEBCAAGBQJV2vIPAAoJEPU2Bp2uRE+gxhEP/19+cVCZ3rVzOX296AcXEODl
oTTbMmmiOR9cZXjwOI9RIpMsC7dcN+iAeFJvbrh50Koxs8vz6F8dh/zHM9StjwVB
1fnZD0q/+nAVjOrjXCmmyMOkaakLaRGY6t7Ou4uEmS2NHlpKhKspgCUoCRYuwKdF
SvSO+PQKXyRh2hUyy8W2nfygI6dLJ7t4jysH7awvzeGYhm5CeLiXjk9NQrbSmAtl
iPgyS1/QXfjpr3T4tjLZgOxtZNwerUpjrci05CEc5BwBzie5gzRU4mPVRl5RhHnr
nrSefY7BVAVeS6ZQGuvJaJIQFz96WZEFRI4z4kCoMhzOYf1A0SxEjzFsO2Av7HlG
XEJtJQ9CtDpQMqRzqiWLI+LjMHiljkvTn0CZzWy9K7MmfJ89TPYOrbGX+o4Z4qfZ
rgTULUcvjjDaxeso3WmVNPjrCR+MWnriCpHxQpfrX6jAlZ+JRf4Jh9MU4FsGphrv
pK5dFlVG1B5S4OMbfX1nFXyTTDSLzAoV6BcLWq54tJbJDEkZgQlRtiIizo/LyzQ3
6TzzIyHjjjD3iBG6iuQCgqxyxnqiA46qepONB5EGwNAVVIP3tFNyokLmv3P0azRW
vicDB27YB13I80cuAzqZp2JY1I2nCfPU9AAXtUrUP8JYvkG5dENYoyzvICnLpjCF
Sf+JCTrHwAy1pQHKtmar
=1Pab
-----END PGP SIGNATURE-----

--dMyqICaxQaaUjrCL--
