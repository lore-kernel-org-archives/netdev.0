From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: Network hangs with 2.6.30.5
Date: Tue, 01 Sep 2009 12:47:46 +0200
Message-ID: <4A9CFBD2.2050206@gmail.com>
References: <7D2F0769-2994-4BB8-B107-DEF2B1346B3A@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org
To: Clifford Heath <clifford.heath@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from gw1.cosmosbay.com ([212.99.114.194]:39900 "EHLO
	gw1.cosmosbay.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753197AbZIAKrq (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 1 Sep 2009 06:47:46 -0400
In-Reply-To: <7D2F0769-2994-4BB8-B107-DEF2B1346B3A@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Clifford Heath a =E9crit :
> I sent this email last Friday, but received no response.
>=20
> As far as I can see, some recent work in the stable
> Linux kernel has broken the TCP stack, at least on my
> (pretty common) hardware. Can anyone confirm that
> they've seen and perhaps fixed similar symptoms, or
> at least tell me what else I need to do to help them
> identify the problem?
>=20
> I recently upgraded my Debian system (a Dell Optiplex GX270) from a
> 2.6.16.11 kernel to a 2.6.30.5 one (current stable). My networking is
> now misbehaving. If I could revert to an earlier kernel, I would (and
> did, it worked), but now I can't because of the glibc version change;
> the old kernel panics on startup. This leaves me with a *broken
> computer* which I cannot use for my regular work, and cannot afford t=
o
> completely re-install.
>=20
> POP, IMAP, and NNTP connect ok (multiple packets each way, viewed usi=
ng
> a logging proxy; no tcpdump but I can get one for you) but as soon as=
 a
> message should start coming down, the connection hangs and then times
> out. I think it's the first large packet that causes this, and I saw
> that the net team have been working on some features to increase
> throughput through read aggregation or something... Whatever it is, i=
t's
> clearly broken (on my hardware at least).
>=20
> My kernel .config file and the output of "lspci" are included below.
> Thanks for any help you can give. Let me know if you need more inform=
ation.
>=20

You could provide a tcpdump for example, and tell us which way is broke=
n=20
(your machine receiving a big packet, or sending a big packet)

You might try to change /proc/sys/net/ipv4/tcp_ecn to 0
echo 0 >/proc/sys/net/ipv4/tcp_ecn

You might try to change device settings

ethtool -K eth0 sg off
and various settings as well (tso, gso ...)

