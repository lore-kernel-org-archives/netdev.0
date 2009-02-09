From: =?ISO-8859-1?Q?Ra=FAl_Hern=E1ndez?= <rauhersu@gmail.com>
Subject: high rate injection and fragmentation
Date: Mon, 9 Feb 2009 16:20:34 +0100
Message-ID: <3f847c820902090720w98e2ca8pc66f55716c030194@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-bw0-f161.google.com ([209.85.218.161]:65217 "EHLO
	mail-bw0-f161.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753938AbZBIPUi convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 9 Feb 2009 10:20:38 -0500
Received: by bwz5 with SMTP id 5so1424740bwz.13
        for <netdev@vger.kernel.org>; Mon, 09 Feb 2009 07:20:35 -0800 (PST)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi there,

I am trying to understand the behavior of the IP stack regarding
fragmentation when injecting at high speed ratio : so far I am seeing
that TCP starts multiplexing the application level protocol (in my
case, diameter: previously 1 diameter message =3D 1 TCP message, when
the rate increases, multiple diameter messages are coalesced in one
TCP messages - similar to a Nagle control -).

At that very moment is when we start finding issues regarding packet
length checking with ethereal: frames start growing due the multiplex
above and ethereal shows captured packets >3000 bytes ! (IP total
lenght makes sense as well according to that figure). The thing is
that I am working under ethernet law (1500 bytes) and I have checked
through iproute this is the MTU set for the link (neither
DONT_FRAGMENT ip options for the socket regarding nor MTU
modifications have been introduced) so my understanding is that no
packet > 1500 bytes should be allowed with my configuration (would
need fragmentation).

Checking the IP header with ethereal, "dont fragment" is set and
"fragment offset"=3D0. IOW, It seems that IP is not fragmenting the
packet although > MTU which I am not able to understand.

Any idea why Linux tries to work with MTU > 1500 bytes when not
configured explicitly to do so (may I have missed more
options/checkings) ? Hope not to be cheated by Ethereal ...

Thx !

Best regards,
Raul



--=20
Los viajes son en la juventud una parte de educaci=F3n y, en la vejez,
una parte de experiencia -- Francis Bacon
