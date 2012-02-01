From: Shawn Lu <shawn.lu@ericsson.com>
Subject: RE: [PATCH] tcp: md5: fix md5 RST when both sides have listener
Date: Wed, 1 Feb 2012 03:11:17 -0500
Message-ID: <62162DF05402B341B3DB59932A1FA992B5B5B932CF@EUSAACMS0702.eamcs.ericsson.se>
References: <RE: [PATCH] tcp: md5: fix md5 RST when both sides have
 listener>		 <1328053998-2498-1-git-send-email-shawn.lu@ericsson.com>
	 <1328072958.2617.34.camel@edumazet-laptop>
	 <62162DF05402B341B3DB59932A1FA992B5B5B932C9@EUSAACMS0702.eamcs.ericsson.se>
 <1328082833.22641.9.camel@edumazet-laptop>
Mime-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: "davem@davemloft.net" <davem@davemloft.net>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"xiaoclu@gmail.com" <xiaoclu@gmail.com>
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from imr3.ericy.com ([198.24.6.13]:51803 "EHLO imr3.ericy.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753684Ab2BAILV convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 1 Feb 2012 03:11:21 -0500
In-Reply-To: <1328082833.22641.9.camel@edumazet-laptop>
Content-Language: en-US
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Why? Do you mean packet is droped by netfilter before getting to tcp an=
d No RST is generated.=20

-----Original Message-----
=46rom: Eric Dumazet [mailto:eric.dumazet@gmail.com]=20
Sent: Tuesday, January 31, 2012 11:54 PM
To: Shawn Lu
Cc: davem@davemloft.net; netdev@vger.kernel.org; xiaoclu@gmail.com
Subject: RE: [PATCH] tcp: md5: fix md5 RST when both sides have listene=
r

Le mercredi 01 f=E9vrier 2012 =E0 02:48 -0500, Shawn Lu a =E9crit :
> Hi, Eric:
>=20
> How about change the title and log to following:
>=20
>   tcp: md5: RST: getting md5 key from listener
>=20
>     TCP RST mechanism is broken in TCP md5(RFC2385). When
>     connection is gone, md5 key is lost, sending RST
>     without md5 hash is deem to ignored by peer. This can
>     be a problem since RST help protocal like bgp to fast
>     recove from peer crash.
>=20
>     In most case, users of tcp md5, such as bgp and ldp,
>     have listener on both side to accept connection from peer.
>     md5 keys for peers are saved in listening socket.
>=20
>     There are two cases in finding md5 key when connection is
>     lost:
>     1.Passive receive RST: The message is send to well known port,
>     tcp will associate packet with listener. md5 key can be gotten
>     from listener.
>=20
>     2.Active receive RST (no sock): The message is send to ative
>     side, there is no socket associated with message. In this case,
>     finding listener from source port, then find md5 key from
>     listener.
>=20
>     we are not loosing sercuriy here:
>     packet is checked with md5 hash. No RST is generated
>     if md5 hash doesn't match or no md5 key can be found.
>=20
> Note:
> Will send out a new version that is on top of your new patch
> -- "tcp: md5: protects md5sig_info with RCU"
>=20

Seems good to me !

By the way, is the patch going to work if netfilter conntrack is enable=
d ?
