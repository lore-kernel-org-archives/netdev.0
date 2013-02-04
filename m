From: Andrew Savchenko <bircoph@gmail.com>
Subject: Re: [BUG] Kernel recieves DNS reply, but doesn't deliver it to a
 waiting application
Date: Mon, 4 Feb 2013 17:39:32 +0400
Message-ID: <20130204173932.bad780bc.bircoph@gmail.com>
References: <20121003232548.eb6b6b22.bircoph@gmail.com>
	<20121013163639.87abca00.bircoph@gmail.com>
	<1350135860.21172.14606.camel@edumazet-glaptop>
	<20121014031119.a60263d6.bircoph@gmail.com>
	<20121021032543.09d1844f.bircoph@gmail.com>
	<1350823941.13333.2167.camel@edumazet-glaptop>
	<20121022073636.98462bc6.bircoph@gmail.com>
	<1350888489.8609.322.camel@edumazet-glaptop>
	<20121023012759.ca7f91d6.bircoph@gmail.com>
	<20121212122716.1e71f644.bircoph@gmail.com>
	<20121223150627.d7ebcf6a.bircoph@gmail.com>
	<1356718263.21409.430.camel@edumazet-glaptop>
	<20130116203644.8eb2a16f.bircoph@gmail.com>
Mime-Version: 1.0
Content-Type: multipart/signed; protocol="application/pgp-signature";
 micalg="PGP-SHA1";
 boundary="Signature=_Mon__4_Feb_2013_17_39_32_+0400_jlc=xTE.uE753apn"
Cc: netdev@vger.kernel.org
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-la0-f46.google.com ([209.85.215.46]:65282 "EHLO
	mail-la0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750946Ab3BDNj6 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 4 Feb 2013 08:39:58 -0500
Received: by mail-la0-f46.google.com with SMTP id fq12so4503493lab.5
        for <netdev@vger.kernel.org>; Mon, 04 Feb 2013 05:39:56 -0800 (PST)
In-Reply-To: <20130116203644.8eb2a16f.bircoph@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

--Signature=_Mon__4_Feb_2013_17_39_32_+0400_jlc=xTE.uE753apn
Content-Type: multipart/mixed;
 boundary="Multipart=_Mon__4_Feb_2013_17_39_32_+0400_P_BPTZBV_NBYwd+V"


--Multipart=_Mon__4_Feb_2013_17_39_32_+0400_P_BPTZBV_NBYwd+V
Content-Type: text/plain; charset=US-ASCII
Content-Disposition: inline
Content-Transfer-Encoding: quoted-printable

Hello,

On Wed, 16 Jan 2013 20:36:44 +0400 Andrew Savchenko wrote:
> On Fri, 28 Dec 2012 10:11:03 -0800 Eric Dumazet wrote:
[...]
> > Thanks a lot !
> >=20
> > I see strange drops in dev_hard_start_xmit()
> >=20
> > l2tp needs some care.
> >=20
> > Please try the following patch, as skb_cow_head() API
> > doesnt really ease skb->truesize exact tracking anyway, better not mess
> > with it.=20
>=20
> Sorry for the delay, but I was able to reboot kernel only today.
> Your patch is applied on top of the 3.7.2 vanilla kernel.
>=20
> l2tp works fine and /proc/net/udp tx_queue values are normal now, see
> attached /prot/net/udp output. This is a good hint that problem is
> probably solved, but we need to wait at least several weeks to be
> sure.

With 16-days uptime system works fine.

Also I was able to reproduce this bug on another box: an embedded
system running openwrt with 3.7.5 kernel with openl2tpd client and
dnsmasq server. Due to limited memory resources this bug happened to
be easily reproducible: several thousands of dns queries were
sufficient to reproduce this bug. Full debug on embedded box was not
possible due to constrained resources, but bug appearance was the same
and /proc/net/udp is apparently broken (see attached log).

I applied your patch on openwrt's 3.7.5 kernel and it fixed the bug
on this box too.

So we've found a solution and I'm looking forward for it in the main
kernel :)

Best regards,
Andrew Savchenko

--Multipart=_Mon__4_Feb_2013_17_39_32_+0400_P_BPTZBV_NBYwd+V
Content-Type: application/octet-stream;
 name="proc.net.udp"
Content-Disposition: attachment;
 filename="proc.net.udp"
Content-Transfer-Encoding: base64

IyBjYXQgL3Byb2MvbmV0L3VkcAogIHNsICBsb2NhbF9hZGRyZXNzIHJlbV9hZGRyZXNzICAgc3Qg
dHhfcXVldWUgcnhfcXVldWUgdHIgdG0tPndoZW4gcmV0cm5zbXQgICB1aWQgIHRpbWVvdXQgaW5v
ZGUgcmVmIHBvaW50ZXIgZHJvcHMgICAgICAgICAgICAgCiAgIDQyOiAwMDAwMDAwMDo3QjJBIDAw
MDAwMDAwOjAwMDAgMDcgRkZGRkZGQjA6MDAwMDAwMDAgMDA6MDAwMDAwMDAgMDAwMDAwMDAgNjU1
MzQgICAgICAgIDAgNjIzOSAyIDgxNmJiNzYwIDEgICAgICAgICAgICAgICAgICAKICAgNTM6IDAw
MDAwMDAwOjAwMzUgMDAwMDAwMDA6MDAwMCAwNyAwMDAwMDAwMDowMDAwMDAwMCAwMDowMDAwMDAw
MCAwMDAwMDAwMCAgICAgMCAgICAgICAgMCAxNDc2IDIgODFiNmU0NDAgMCAgICAgICAgICAgICAg
ICAgIAogICA2NzogMDAwMDAwMDA6MDA0MyAwMDAwMDAwMDowMDAwIDA3IDAwMDAwMDAwOjAwMDAw
MDAwIDAwOjAwMDAwMDAwIDAwMDAwMDAwICAgICAwICAgICAgICAwIDE0NzEgMiA4MWI2ZTIyMCAw
ICAgICAgICAgICAgICAgICAgCiAgIDc2OiAwMDAwMDAwMDoxQjRDIDAwMDAwMDAwOjAwMDAgMDcg
RkZGRkZGQjA6MDAwMDAwMDAgMDA6MDAwMDAwMDAgMDAwMDAwMDAgNjU1MzQgICAgICAgIDAgNjIy
NSAyIDgxNmJhY2MwIDEgICAgICAgICAgICAgICAgICAKICAgOTU6IDAwMDAwMDAwOjE2NUYgMDAw
MDAwMDA6MDAwMCAwNyBGRkZGRkZCMDowMDAwMDAwMCAwMDowMDAwMDAwMCAwMDAwMDAwMCA2NTUz
NCAgICAgICAgMCA2MjIxIDIgODE2YmE4ODAgMSAgICAgICAgICAgICAgICAgIAogIDEwMTogMEEz
NDE4MkU6QUU2NSAwQTMyMDAxNDowNkE1IDAxIDAwMDAwMDAwOjAwMDAwMDAwIDAwOjAwMDAwMDAw
IDAwMDAwMDAwICAgICAwICAgICAgICAwIDE1MzggNCA4MWI2ZWNjMCAwICAgICAgICAgICAgICAg
ICAgCiAgMTIzOiAwMDAwMDAwMDowMDdCIDAwMDAwMDAwOjAwMDAgMDcgMDAwMDAwMDA6MDAwMDAw
MDAgMDA6MDAwMDAwMDAgMDAwMDAwMDAgICAgIDAgICAgICAgIDAgMTUzMCAyIDgxYjZlODgwIDAg
ICAgICAgICAgICAgICAgICAKICAxMjY6IDAwMDAwMDAwOjg0N0UgMDAwMDAwMDA6MDAwMCAwNyBG
RkZGRkZCMDowMDAwMDAwMCAwMDowMDAwMDAwMCAwMDAwMDAwMCA2NTUzNCAgICAgICAgMCA2MjIz
IDIgODE2YmFhYTAgMSAgICAgICAgICAgICAgICAgIAogIDE1MzogMDAwMDAwMDA6Q0Y5OSAwMDAw
MDAwMDowMDAwIDA3IEZGRkZGRkIwOjAwMDAwMDAwIDAwOjAwMDAwMDAwIDAwMDAwMDAwIDY1NTM0
ICAgICAgICAwIDYyMzMgMiA4MTZiYjU0MCAxICAgICAgICAgICAgICAgICAgCiAgMTYzOiAwMDAw
MDAwMDowOUEzIDAwMDAwMDAwOjAwMDAgMDcgRkZGRkZGQjA6MDAwMDAwMDAgMDA6MDAwMDAwMDAg
MDAwMDAwMDAgNjU1MzQgICAgICAgIDAgNjIyNyAyIDgxNmJhZWUwIDEgICAgICAgICAgICAgICAg
ICAKICAxNjU6IDAwMDAwMDAwOjA2QTUgMDAwMDAwMDA6MDAwMCAwNyAwMDAwMDAwMDowMDAwMDAw
MCAwMDowMDAwMDAwMCAwMDAwMDAwMCAgICAgMCAgICAgICAgMCAxNTIzIDIgODFiNmU2NjAgMCAg
ICAgICAgICAgICAgICAgIAogIDE4NDogMDAwMDAwMDA6NzBCOCAwMDAwMDAwMDowMDAwIDA3IEZG
RkZGRkIwOjAwMDAwMDAwIDAwOjAwMDAwMDAwIDAwMDAwMDAwIDY1NTM0ICAgICAgICAwIDYyMzEg
MiA4MTZiYjMyMCAxICAgICAgICAgICAgICAgICAgCiAgMjI2OiAwMDAwMDAwMDpDQ0UyIDAwMDAw
MDAwOjAwMDAgMDcgRkZGRkZGQjA6MDAwMDAwMDAgMDA6MDAwMDAwMDAgMDAwMDAwMDAgNjU1MzQg
ICAgICAgIDAgNjIyOSAyIDgxNmJiMTAwIDEK

--Multipart=_Mon__4_Feb_2013_17_39_32_+0400_P_BPTZBV_NBYwd+V--

--Signature=_Mon__4_Feb_2013_17_39_32_+0400_jlc=xTE.uE753apn
Content-Type: application/pgp-signature

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v2.0.19 (GNU/Linux)

iEYEARECAAYFAlEPuiUACgkQ2anJBBcsZw36AwCgucMpj/ov/L2Ch1kfSNfgqjOd
gPQAoK2zzXzQpoPjoI8n4uSdVhwd8ul+
=GwWK
-----END PGP SIGNATURE-----

--Signature=_Mon__4_Feb_2013_17_39_32_+0400_jlc=xTE.uE753apn--
