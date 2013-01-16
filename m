From: Andrew Savchenko <bircoph@gmail.com>
Subject: Re: [BUG] Kernel recieves DNS reply, but doesn't deliver it to a
 waiting application
Date: Wed, 16 Jan 2013 20:36:44 +0400
Message-ID: <20130116203644.8eb2a16f.bircoph@gmail.com>
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
Mime-Version: 1.0
Content-Type: multipart/signed; protocol="application/pgp-signature";
 micalg="PGP-SHA1";
 boundary="Signature=_Wed__16_Jan_2013_20_36_44_+0400_VSYwZ4cgPJpc_rG="
Cc: netdev@vger.kernel.org
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-la0-f52.google.com ([209.85.215.52]:41281 "EHLO
	mail-la0-f52.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1758496Ab3APQnW (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 16 Jan 2013 11:43:22 -0500
Received: by mail-la0-f52.google.com with SMTP id fq12so1655771lab.11
        for <netdev@vger.kernel.org>; Wed, 16 Jan 2013 08:43:21 -0800 (PST)
In-Reply-To: <1356718263.21409.430.camel@edumazet-glaptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

--Signature=_Wed__16_Jan_2013_20_36_44_+0400_VSYwZ4cgPJpc_rG=
Content-Type: multipart/mixed;
 boundary="Multipart=_Wed__16_Jan_2013_20_36_44_+0400_t/Xn0xog36TB27+i"


--Multipart=_Wed__16_Jan_2013_20_36_44_+0400_t/Xn0xog36TB27+i
Content-Type: text/plain; charset=US-ASCII
Content-Disposition: inline
Content-Transfer-Encoding: quoted-printable

Hello,

On Fri, 28 Dec 2012 10:11:03 -0800 Eric Dumazet wrote:
> On Sun, 2012-12-23 at 15:06 +0400, Andrew Savchenko wrote:
[...]
> > I hit this bug again on uptime 11 days on 3.7.0 vanilla kernel.
> > See kernel config, /prot/net/upd, netstat -s and dropwatch logs
> > attached to this mail. This bug happens on UDP DNS requests only,
> > TCP requests work fine, see dig.log attached.
> >=20
> > Increasing of net.ipv4.udp_mem from
> > 24150        32201   48300
> > to
> > 100000       150000  200000
> > helps, but I'm afraid only temporary again.
> >=20
> > Dropwatch data was collected in the following way:
> > - dropwatch.bug.* files contain data obtained after bug occurred;
> > - dropwatch.*.background files contain background data when no
> >   host or dig test was running; this system has active firewall
> >   and complicated routing, ipv6 disabled via sysctl, etc, so some
> >   drops are normal;
> > - dropwatch.*.host.request shows dropped packets recorded during
> >   host ya.ru request; of course, during this time some background
> >   packets were recorded as well (dropwatch doesn't support filtering
> >   at this moment);
> > - dropwatch.nobug.* data was collected after the bug was
> >   workarounded via net.ipv4.upd_mem as described above.
> >=20
> > As can be seen from dropwatch logs, drop in __udp_queue_rcv_skb+61
> > happens only on host request on bug conditions, thus something is
> > wrong there.
> >=20
> > Best regards,
> > Andrew Savchenko
>=20
> Thanks a lot !
>=20
> I see strange drops in dev_hard_start_xmit()
>=20
> l2tp needs some care.
>=20
> Please try the following patch, as skb_cow_head() API
> doesnt really ease skb->truesize exact tracking anyway, better not mess
> with it.=20

Sorry for the delay, but I was able to reboot kernel only today.
Your patch is applied on top of the 3.7.2 vanilla kernel.

l2tp works fine and /proc/net/udp tx_queue values are normal now, see
attached /prot/net/udp output. This is a good hint that problem is
probably solved, but we need to wait at least several weeks to be
sure.

Best regards,
Andrew Savchenko

--Multipart=_Wed__16_Jan_2013_20_36_44_+0400_t/Xn0xog36TB27+i
Content-Type: application/octet-stream;
 name="proc.net.udp"
Content-Disposition: attachment;
 filename="proc.net.udp"
Content-Transfer-Encoding: base64

ICBzbCAgbG9jYWxfYWRkcmVzcyByZW1fYWRkcmVzcyAgIHN0IHR4X3F1ZXVlIHJ4X3F1ZXVlIHRy
IHRtLT53aGVuIHJldHJuc210ICAgdWlkICB0aW1lb3V0IGlub2RlIHJlZiBwb2ludGVyIGRyb3Bz
ICAgICAgICAgICAgIAogICAgMDogMDAwMDAwMDA6MDZBNSAwMDAwMDAwMDowMDAwIDA3IDAwMDAw
MDAwOjAwMDAwMDAwIDAwOjAwMDAwMDAwIDAwMDAwMDAwICAgICAwICAgICAgICAwIDUwMTMgMiBm
ZmZmODgwMDNkNjA1YzAwIDAgICAgICAgICAgCiAgIDg5OiAwMDAwMDAwMDo5MEZFIDAwMDAwMDAw
OjAwMDAgMDcgMDAwMDAwMDA6MDAwMDAwMDAgMDA6MDAwMDAwMDAgMDAwMDAwMDAgICAgIDAgICAg
ICAgIDAgNTA3NCAyIGZmZmY4ODAwM2JjYmE3MDAgMCAgICAgICAgICAKICAgOTA6IDdFMTgzNDBB
Ojg4RkYgMTQwMDMyMEE6MDZBNSAwMSAwMDAwMDAwMDowMDAwMDAwMCAwMDowMDAwMDAwMCAwMDAw
MDAwMCAgICAgMCAgICAgICAgMCA1MDM0IDQgZmZmZjg4MDAzYmNiYTAwMCAwICAgICAgICAgIAog
IDEzNjogMDAwMDAwMDA6ODkyRCAwMDAwMDAwMDowMDAwIDA3IDAwMDAwMDAwOjAwMDAwMDAwIDAw
OjAwMDAwMDAwIDAwMDAwMDAwICAgICAwICAgICAgICAwIDUwNDkgMiBmZmZmODgwMDNiY2JhMzgw
IDAgICAgICAgICAgCiAgMTYwOiAwMTAwMDA3RjoyNzQ1IDAwMDAwMDAwOjAwMDAgMDcgMDAwMDAw
MDA6MDAwMDAwMDAgMDA6MDAwMDAwMDAgMDAwMDAwMDAgICAgIDAgICAgICAgIDAgNDQ5NSAyIGZm
ZmY4ODAwM2Q2MDQzODAgMCAgICAgICAgICAKICAxODM6IDAxMDAwMDdGOjAzNUMgMDAwMDAwMDA6
MDAwMCAwNyAwMDAwMDAwMDowMDAwMDAwMCAwMDowMDAwMDAwMCAwMDAwMDAwMCAgICAgMCAgICAg
ICAgMCA0NzcwIDIgZmZmZjg4MDAzZDYwNGE4MCAwICAgICAgICAgIAogIDIxNzogMDAwMDAwMDA6
ODU3RSAwMDAwMDAwMDowMDAwIDA3IDAwMDAwMDAwOjAwMDAwMDAwIDAwOjAwMDAwMDAwIDAwMDAw
MDAwICAgICAwICAgICAgICAwIDUxNDYgMiBmZmZmODgwMDNiZDM0NzAwIDAgICAgICAgICAgCiAg
MzEwOiAwMDAwMDAwMDowM0RCIDAwMDAwMDAwOjAwMDAgMDcgMDAwMDAwMDA6MDAwMDAwMDAgMDA6
MDAwMDAwMDAgMDAwMDAwMDAgICAgIDAgICAgICAgIDAgNDUyMCAyIGZmZmY4ODAwM2Q2MDQ3MDAg
MCAgICAgICAgICAKICAzMTg6IDAwMDAwMDAwOkE5RTMgMDAwMDAwMDA6MDAwMCAwNyAwMDAwMDAw
MDowMDAwMDAwMCAwMDowMDAwMDAwMCAwMDAwMDAwMCAgICAgMCAgICAgICAgMCA0Nzc2IDIgZmZm
Zjg4MDAzZDYwNGUwMCAwICAgICAgICAgIAogIDM0ODogMDAwMDAwMDA6MDgwMSAwMDAwMDAwMDow
MDAwIDA3IDAwMDAwMDAwOjAwMDAwMDAwIDAwOjAwMDAwMDAwIDAwMDAwMDAwICAgICAwICAgICAg
ICAwIDUxMzcgMiBmZmZmODgwMDNiZDM0MzgwIDAgICAgICAgICAgCiAgNDAwOiAwMTAwMTNBQzow
MDM1IDAwMDAwMDAwOjAwMDAgMDcgMDAwMDAwMDA6MDAwMDAwMDAgMDA6MDAwMDAwMDAgMDAwMDAw
MDAgICAgIDAgICAgICAgIDAgNDg3NiAyIGZmZmY4ODAwM2Q2MDU4ODAgMCAgICAgICAgICAKICA0
MDA6IDAxMDAwMDdGOjAwMzUgMDAwMDAwMDA6MDAwMCAwNyAwMDAwMDAwMDowMDAwMDAwMCAwMDow
MDAwMDAwMCAwMDAwMDAwMCAgICAgMCAgICAgICAgMCA0ODc1IDIgZmZmZjg4MDAzZDYwNTUwMCAw
ICAgICAgICAgIAogIDQxNDogMDAwMDAwMDA6MDA0MyAwMDAwMDAwMDowMDAwIDA3IDAwMDAwMDAw
OjAwMDAwMDAwIDAwOjAwMDAwMDAwIDAwMDAwMDAwICAgICAwICAgICAgICAwIDUxNzYgMiBmZmZm
ODgwMDNiZDM1NTAwIDAgICAgICAgICAgCiAgNDU4OiAwMDAwMDAwMDowMDZGIDAwMDAwMDAwOjAw
MDAgMDcgMDAwMDAwMDA6MDAwMDAwMDAgMDA6MDAwMDAwMDAgMDAwMDAwMDAgICAgIDAgICAgICAg
IDAgNDQ4NiAyIGZmZmY4ODAwM2Q2MDQwMDAgMCAgICAgICAgICAKICA0NjY6IDAwMDAwMDAwOjAy
NzcgMDAwMDAwMDA6MDAwMCAwNyAwMDAwMDAwMDowMDAwMDAwMCAwMDowMDAwMDAwMCAwMDAwMDAw
MCAgICAgMCAgICAgICAgMCA0ODE4IDIgZmZmZjg4MDAzZDYwNTE4MCAwICAgICAgICAgIAogIDQ3
MDogMDc2QTA3MEE6MDA3QiAwMDAwMDAwMDowMDAwIDA3IDAwMDAwMDAwOjAwMDAwMDAwIDAwOjAw
MDAwMDAwIDAwMDAwMDAwICAgMTIzICAgICAgICAwIDU1MjYgMiBmZmZmODgwMDNiZDM1YzAwIDAg
ICAgICAgICAgCiAgNDcwOiAwMTAyMTNBQzowMDdCIDAwMDAwMDAwOjAwMDAgMDcgMDAwMDAwMDA6
MDAwMDAwMDAgMDA6MDAwMDAwMDAgMDAwMDAwMDAgICAgIDAgICAgICAgIDAgNTEyMSAyIGZmZmY4
ODAwM2JkMzQwMDAgMCAgICAgICAgICAKICA0NzA6IDAxMDAxM0FDOjAwN0IgMDAwMDAwMDA6MDAw
MCAwNyAwMDAwMDAwMDowMDAwMDAwMCAwMDowMDAwMDAwMCAwMDAwMDAwMCAgICAgMCAgICAgICAg
MCA1MTIwIDIgZmZmZjg4MDAzYmNiYmMwMCAwICAgICAgICAgIAogIDQ3MDogMDBGQ0E4QzA6MDA3
QiAwMDAwMDAwMDowMDAwIDA3IDAwMDAwMDAwOjAwMDAwMDAwIDAwOjAwMDAwMDAwIDAwMDAwMDAw
ICAgICAwICAgICAgICAwIDUxMTkgMiBmZmZmODgwMDNiY2JiODgwIDAgICAgICAgICAgCiAgNDcw
OiA3RTE4MzQwQTowMDdCIDAwMDAwMDAwOjAwMDAgMDcgMDAwMDAwMDA6MDAwMDAwMDAgMDA6MDAw
MDAwMDAgMDAwMDAwMDAgICAgIDAgICAgICAgIDAgNTExOCAyIGZmZmY4ODAwM2JjYmI1MDAgMCAg
ICAgICAgICAKICA0NzA6IDAxMDAwMDdGOjAwN0IgMDAwMDAwMDA6MDAwMCAwNyAwMDAwMDAwMDow
MDAwMDAwMCAwMDowMDAwMDAwMCAwMDAwMDAwMCAgICAgMCAgICAgICAgMCA1MTE3IDIgZmZmZjg4
MDAzYmNiYjE4MCAwICAgICAgICAgIAogIDQ3MDogMDAwMDAwMDA6MDA3QiAwMDAwMDAwMDowMDAw
IDA3IDAwMDAwMDAwOjAwMDAwMDAwIDAwOjAwMDAwMDAwIDAwMDAwMDAwICAgICAwICAgICAgICAw
IDUxMTEgMiBmZmZmODgwMDNiY2JhYTgwIDAgICAgICAgICAgCiAgNDg0OiBGRjAwMTNBQzowMDg5
IDAwMDAwMDAwOjAwMDAgMDcgMDAwMDAwMDA6MDAwMDAwMDAgMDA6MDAwMDAwMDAgMDAwMDAwMDAg
ICAgIDAgICAgICAgIDAgNTI5OCAyIGZmZmY4ODAwMzlmYmQ1MDAgMCAgICAgICAgICAKICA0ODQ6
IDAxMDAxM0FDOjAwODkgMDAwMDAwMDA6MDAwMCAwNyAwMDAwMDAwMDowMDAwMDAwMCAwMDowMDAw
MDAwMCAwMDAwMDAwMCAgICAgMCAgICAgICAgMCA1Mjk3IDIgZmZmZjg4MDAzOWZiZDE4MCAwICAg
ICAgICAgIAogIDQ4NDogRkYwMjEzQUM6MDA4OSAwMDAwMDAwMDowMDAwIDA3IDAwMDAwMDAwOjAw
MDAwMDAwIDAwOjAwMDAwMDAwIDAwMDAwMDAwICAgICAwICAgICAgICAwIDUyOTQgMiBmZmZmODgw
MDM5ZmJjNzAwIDAgICAgICAgICAgCiAgNDg0OiAwMTAyMTNBQzowMDg5IDAwMDAwMDAwOjAwMDAg
MDcgMDAwMDAwMDA6MDAwMDAwMDAgMDA6MDAwMDAwMDAgMDAwMDAwMDAgICAgIDAgICAgICAgIDAg
NTI5MyAyIGZmZmY4ODAwMzlmYmMzODAgMCAgICAgICAgICAKICA0ODQ6IDAwMDAwMDAwOjAwODkg
MDAwMDAwMDA6MDAwMCAwNyAwMDAwMDAwMDowMDAwMDAwMCAwMDowMDAwMDAwMCAwMDAwMDAwMCAg
ICAgMCAgICAgICAgMCA1MjkwIDIgZmZmZjg4MDAzYmNiYWUwMCAwICAgICAgICAgIAogIDQ4NTog
RkYwMDEzQUM6MDA4QSAwMDAwMDAwMDowMDAwIDA3IDAwMDAwMDAwOjAwMDAwMDAwIDAwOjAwMDAw
MDAwIDAwMDAwMDAwICAgICAwICAgICAgICAwIDUzMDAgMiBmZmZmODgwMDM5ZmJkYzAwIDAgICAg
ICAgICAgCiAgNDg1OiAwMTAwMTNBQzowMDhBIDAwMDAwMDAwOjAwMDAgMDcgMDAwMDAwMDA6MDAw
MDAwMDAgMDA6MDAwMDAwMDAgMDAwMDAwMDAgICAgIDAgICAgICAgIDAgNTI5OSAyIGZmZmY4ODAw
MzlmYmQ4ODAgMCAgICAgICAgICAKICA0ODU6IEZGMDIxM0FDOjAwOEEgMDAwMDAwMDA6MDAwMCAw
NyAwMDAwMDAwMDowMDAwMDAwMCAwMDowMDAwMDAwMCAwMDAwMDAwMCAgICAgMCAgICAgICAgMCA1
Mjk2IDIgZmZmZjg4MDAzOWZiY2UwMCAwICAgICAgICAgIAogIDQ4NTogMDEwMjEzQUM6MDA4QSAw
MDAwMDAwMDowMDAwIDA3IDAwMDAwMDAwOjAwMDAwMDAwIDAwOjAwMDAwMDAwIDAwMDAwMDAwICAg
ICAwICAgICAgICAwIDUyOTUgMiBmZmZmODgwMDM5ZmJjYTgwIDAgICAgICAgICAgCiAgNDg1OiAw
MDAwMDAwMDowMDhBIDAwMDAwMDAwOjAwMDAgMDcgMDAwMDAwMDA6MDAwMDAwMDAgMDA6MDAwMDAw
MDAgMDAwMDAwMDAgICAgIDAgICAgICAgIDAgNTI5MSAyIGZmZmY4ODAwMzlmYmMwMDAgMCAgICAg
ICAgICAK

--Multipart=_Wed__16_Jan_2013_20_36_44_+0400_t/Xn0xog36TB27+i--

--Signature=_Wed__16_Jan_2013_20_36_44_+0400_VSYwZ4cgPJpc_rG=
Content-Type: application/pgp-signature

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v2.0.19 (GNU/Linux)

iEYEARECAAYFAlD21y8ACgkQ2anJBBcsZw1bdACdGXqsxRcRQKcIesJKzTYkyPtr
qh8An0yxmErh6McE/NtAp+9OD0AZ2OOe
=hIAX
-----END PGP SIGNATURE-----

--Signature=_Wed__16_Jan_2013_20_36_44_+0400_VSYwZ4cgPJpc_rG=--
