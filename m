From: Johannes Berg <johannes@sipsolutions.net>
Subject: frame status API? (was: mac80211 truesize bugs)
Date: Sun, 04 May 2008 03:55:41 +0200
Message-ID: <1209866141.6210.32.camel@johannes.berg>
References: <1209607368.7173.20.camel@johannes.berg>
	 (sfid-20080501_040316_946673_DB8C2769)
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha1; protocol="application/pgp-signature"; boundary="=-vwzL6umTWv5BivgCQKHn"
Cc: linux-wireless <linux-wireless@vger.kernel.org>
To: netdev <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from xc.sipsolutions.net ([83.246.72.84]:37012 "EHLO
	sipsolutions.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753532AbYEDBzu (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 3 May 2008 21:55:50 -0400
In-Reply-To: <1209607368.7173.20.camel@johannes.berg> (sfid-20080501_040316_946673_DB8C2769)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


--=-vwzL6umTWv5BivgCQKHn
Content-Type: text/plain
Content-Transfer-Encoding: quoted-printable


> Whenever you run a monitor interface in mac80211, you can see lots of
> truesize bugs:
>=20
> SKB BUG: Invalid truesize (464) len=3D307, sizeof(sk_buff)=3D176
>=20
> It appears to be caused by mac80211's re-injection of the transmitted
> frame.

Regardless of the fact that I'm pretty sure that we have bugs with
respect to pskb_expand_head in mac80211 that for some reason never show
up unless you add monitors, this re-injection of frames is quite a hack.

For one, it means that on a monitor interface you see every outgoing
frame, even if it wasn't sent on that interface. That's actually quite
nice, especially for debugging, but I think we can already see all
transmitted packets on the master interface.

Secondly, it means that actually injected packets show up twice, first
via dev_queue_xmit_nit and then via the status reporting.

Also, if we ever want to move towards an API where the driver need not
give a TX status report for every frame (some hardware cannot do this)
then this is at best a hack since we do not know the exact status for a
frame.

On the other hand, hostapd requires knowing whether a specific frame was
acknowledged.

Does anyone have any ideas how to implement such a status query for a
frame that was sent? What hostapd does is open a raw socket and simply
send a frame, but it needs to know whether that frame was acknowledged
so currently it also listens on a monitor and checks all outgoing
frames, which is suboptimal anyway.

The only thing I could so far think of is like the socket timestamps but
that seems rather bad to do for such a special case.

johannes

--=-vwzL6umTWv5BivgCQKHn
Content-Type: application/pgp-signature; name=signature.asc
Content-Description: This is a digitally signed message part

-----BEGIN PGP SIGNATURE-----
Comment: Johannes Berg (powerbook)

iQIVAwUASB0XnKVg1VMiehFYAQKOoxAAwbzUBDKEIul2NZx8faDAN0AGcfE5qDa8
ygAZ6WTnu+EZc5yfPZZn7qwjMrIi3Ff5W7juVzklVmVEXbNwdvEfTof9dKjvqDAM
ZfvMBCb0JxOxXZfZU1OySDlktfiXQJd2PiXdPdTZ4Xi4+0+erO4A8SYOE61H5+5w
rT4luH7qIf6c5dBZ9kv2pZB/w7dVyqJtUBPgaPCZe3qrhubfQcsOuSpt3o6PcTm/
NH/iMujOXA5lPJKQw3eDYurlPzKqwEj5g+nO4fHIySyvGy84emUrwt++DBYB394w
EJ7l4ox4ccKw6boRKr36F22jUptq7bpW/nKAllYxrStmv7Aefi3ABeSCVGJH+stL
M06hFJXgUT65JRW4XK4Rk8tpuoYwD7WJbHVz9XBgVLjOJW1xxyjeTzPKanM8WvDj
4qvVg+aUfrE0X7UJUumWQHlHXg+g6Ko6ZipMxxBZduNXBDlgQHCmtM3vWKh2VaVy
xpZiMCTQ1CJjAdl4MxzoY6UF9V7Pn+07/hi91nzfqylzOAR2sy4gbAmNPCY00TG3
u/QD5knq1vnPnEW7L2qI99YlDu2RS4P180HsvrqYtsg+Y/ENh3MI0MwAQxam+FDV
Ol8BUd5cRC+iypTOARaLaKPzm8w+8bA3mOXt0um+ysYayyNuzwF83903u+W1chlk
fFe8Hr7DXck=
=RxM5
-----END PGP SIGNATURE-----

--=-vwzL6umTWv5BivgCQKHn--

