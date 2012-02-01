From: Shawn Lu <shawn.lu@ericsson.com>
Subject: RE: [PATCH] tcp: md5: RST: getting md5 key from listener
Date: Wed, 1 Feb 2012 13:48:00 -0500
Message-ID: <62162DF05402B341B3DB59932A1FA992B5B5C22B35@EUSAACMS0702.eamcs.ericsson.se>
References: <RE: [PATCH] tcp: md5: fix md5 RST when both sides have
 listener>	 <1328085348-6771-1-git-send-email-shawn.lu@ericsson.com>
 <1328090095.2595.13.camel@edumazet-HP-Compaq-6005-Pro-SFF-PC>
Mime-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: "davem@davemloft.net" <davem@davemloft.net>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"xiaoclu@gmail.com" <xiaoclu@gmail.com>
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from imr4.ericy.com ([198.24.6.9]:57932 "EHLO imr4.ericy.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751890Ab2BASsV convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 1 Feb 2012 13:48:21 -0500
In-Reply-To: <1328090095.2595.13.camel@edumazet-HP-Compaq-6005-Pro-SFF-PC>
Content-Language: en-US
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi,Eric

With linux support for TCP AO not in picture right now.=20
Are you interested in putting patch to enable md5 key change( RFC4808)?

Or do you anybody else is working on linux implementation of TCP AO?

I posted this question before and get no response yet.


Thanks!
Shawn =20

-----Original Message-----
=46rom: Eric Dumazet [mailto:eric.dumazet@gmail.com]=20
Sent: Wednesday, February 01, 2012 1:55 AM
To: Shawn Lu
Cc: davem@davemloft.net; netdev@vger.kernel.org; xiaoclu@gmail.com
Subject: Re: [PATCH] tcp: md5: RST: getting md5 key from listener

Le mercredi 01 f=E9vrier 2012 =E0 00:35 -0800, Shawn Lu a =E9crit :
> TCP RST mechanism is broken in TCP md5(RFC2385). When connection is=20
> gone, md5 key is lost, sending RST without md5 hash is deem to ignore=
d=20
> by peer. This can be a problem since RST help protocal like bgp to=20
> fast recove from peer crash.
>=20
> In most case, users of tcp md5, such as bgp and ldp, have listener on=
=20
> both sides to accept connection from peer.
> md5 keys for peers are saved in listening socket.
>=20
> There are two cases in finding md5 key when connection is
> lost:
> 1.Passive receive RST: The message is send to well known port, tcp=20
> will associate it with listner. md5 key is gotten from listener.
>=20
> 2.Active receive RST (no sock): The message is send to ative side,=20
> there is no socket associated with the message. In this case, finding=
=20
> listener from source port, then find md5 key from listener.
>=20
> we are not loosing sercuriy here:
> packet is checked with md5 hash. No RST is generated if md5 hash=20
> doesn't match or no md5 key can be found.
>=20
> Signed-off-by: Shawn Lu <shawn.lu@ericsson.com>
> ---
> v4: change title and change log.=20
> regerated after  "tcp: md5: protects md5sig_info with RCU"


Signed-off-by: Eric Dumazet <eric.dumazet@gmail.com>

Thanks !
