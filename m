From: Corinna Vinschen <vinschen@redhat.com>
Subject: Re: [PATCH v2 net-next] r8169: Add values missing in @get_stats64
 from HW counters
Date: Sat, 22 Aug 2015 10:39:16 +0200
Message-ID: <20150822083916.GA17408@calimero.vinschen.de>
References: <1439888664-28620-1-git-send-email-vinschen@redhat.com>
 <1440151756-18165-1-git-send-email-vinschen@redhat.com>
 <20150821193926.GA16437@electric-eye.fr.zoreil.com>
 <20150821220756.GI19683@calimero.vinschen.de>
 <20150821235940.GA20313@electric-eye.fr.zoreil.com>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha256;
	protocol="application/pgp-signature"; boundary="u3/rZRmxL6MmkK24"
Cc: netdev@vger.kernel.org, Hayes Wang <hayeswang@realtek.com>,
	Ivan Vecera <ivecera@redhat.com>,
	David Miller <davem@davemloft.net>,
	nic_swsd <nic_swsd@realtek.com>
To: Francois Romieu <romieu@fr.zoreil.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-n.franken.de ([193.175.24.27]:50676 "EHLO
	mail-n.franken.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753221AbbHVIjT (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 22 Aug 2015 04:39:19 -0400
Content-Disposition: inline
In-Reply-To: <20150821235940.GA20313@electric-eye.fr.zoreil.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


--u3/rZRmxL6MmkK24
Content-Type: text/plain; charset=utf-8
Content-Disposition: inline
Content-Transfer-Encoding: quoted-printable

On Aug 22 01:59, Francois Romieu wrote:
> Corinna Vinschen <vinschen@redhat.com> :
> > On Aug 21 21:39, Francois Romieu wrote:
> [...]
> > > The code should propagate failure when both rtl8169_reset_counters and
> > > rtl8169_update_counters fail.
> >=20
> > This one I don't understand.  Neither failing to reset the counters nor
> > failing to update the counters is fatal for the driver.  So far the
> > (unchanged) rtl8169_update_counters doesn't even print a log message,
>=20
> I wouldn't overestimate the value of log messages vs real status return.
> Users can be quite unhappy with default settings that spam their logs
> (it isn't a problem in open(), it's marginaly murphy plausible from
> a periodic get_stats context).

That won't happen with the current patch because only
rtl8169_reset_counters would print a log message, it's only called from
open, and open occurs rather seldom.  Atop of that the code only tries
to reset counters on HW supporting it, and only if resetting on the HW
fails, there will be a log message at all.  There's no reasonable chance
that failing to reset the counters will lead to log flooding.

> The driver can't propagate errors from the current get_stats context
> where rtl8169_update_counters is used. However it can be done in
> open().
>=20
> > while a failing reset in rtl8169_reset_counters now does.
> >=20
> > Why is that not sufficent?
>=20
> Because of the same reason(s) why this patch wants to improve things.
>=20
> It isn't a showstopper.

I'm not trying to avoid work, I'm trying to understand.

As far as I see it failing to reset the counters has no impact on the
viability of the code.  It's still working with offsets and if the
offset is 0 or non-0, the user space won't see the difference in the
values returned by @get_stats64.  Successful resetting the counters is
just a bonus.

Considering that failing rtl8169_reset_counters or failing
rtl8169_update_counters has no negative impact on open at all, the
problem I have here is:

What do you do with a return value from either one of these functions?

rtl_open () {
  [...]

  if (!rtl8169_reset_counters (dev)) {
    /* ??? */
  }

  if (!rtl8169_update_counters (dev)) {
    /* ??? */
  }

  [...]
}


Thanks,
Corinna

--u3/rZRmxL6MmkK24
Content-Type: application/pgp-signature

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v2

iQIcBAEBCAAGBQJV2DU0AAoJEPU2Bp2uRE+ghkgP/2EXjMmpTtOrk3Qctc1KgxK1
ui8P0sGq/mtDa55dO7MuAac76GCJKfs9N4V0kAee2mPBiNJlKt3bcOeP3/VTt8D3
vx/JTmhVtSqApiMbZqrLPSNB/IhZlftcDbZKPvCIbZb5wJR06+Q+5yBsR9LT+ZiU
GyU8T8jGIm9gCKPjdrboZx69gUqEZvHyQYh6gwhs8ozrxvlLit/A0bmjWDKEiwqo
vq+txSJf5tze8B8xdd6V+vQ3LtnCFs1GHALGmsj32Jh+SdOJ8LCRcfoRyb/P6NlG
qGR37qr8w/WMGbF6xd9/D3lZgoG6QRD7w2yzZO9cpl5DDUmDySjVvTXHzBEL7pcB
HBYeYdfYS22cBJ8SbADNBXEdjJSLyzQM8m8b05wELQY5w68P1U6/IheDRxi9Xok+
DEJHvw96rn5XyUU5BdI8j+IkuG2V79NlymJr6GH72c8LhK1WngyoID+qPZrdtjrH
LG9KbKYCPNiWKfXu8Obz2YO7ZlJ+wjkVpsb2/FXO1AM0pPU7l3A363WPU+aTQAi2
/qNqTngsLrINlMFiU1zdOT5NOpMLEK9tidbEwCFQN58V8q+oKtFRQyFRNw3wcQWx
ToFOXrmRFMjHIeFxC77H5tfmtKkadldYM+IYmRK+Kob4dblNh84aJ5Huwbf2HUQO
VW1LWOGP9Eq81YUNOyJq
=2+NV
-----END PGP SIGNATURE-----

--u3/rZRmxL6MmkK24--
