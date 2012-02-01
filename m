From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: RE: [PATCH] tcp: md5: fix md5 RST when both sides have listener
Date: Wed, 01 Feb 2012 08:53:53 +0100
Message-ID: <1328082833.22641.9.camel@edumazet-laptop>
References: <RE: [PATCH] tcp: md5: fix md5 RST when both sides have listener>
		 <1328053998-2498-1-git-send-email-shawn.lu@ericsson.com>
	 <1328072958.2617.34.camel@edumazet-laptop>
	 <62162DF05402B341B3DB59932A1FA992B5B5B932C9@EUSAACMS0702.eamcs.ericsson.se>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: "davem@davemloft.net" <davem@davemloft.net>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"xiaoclu@gmail.com" <xiaoclu@gmail.com>
To: Shawn Lu <shawn.lu@ericsson.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ww0-f44.google.com ([74.125.82.44]:50190 "EHLO
	mail-ww0-f44.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753759Ab2BAHx6 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 1 Feb 2012 02:53:58 -0500
Received: by wgbdt10 with SMTP id dt10so958489wgb.1
        for <netdev@vger.kernel.org>; Tue, 31 Jan 2012 23:53:56 -0800 (PST)
In-Reply-To: <62162DF05402B341B3DB59932A1FA992B5B5B932C9@EUSAACMS0702.eamcs.ericsson.se>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Le mercredi 01 f=C3=A9vrier 2012 =C3=A0 02:48 -0500, Shawn Lu a =C3=A9c=
rit :
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

By the way, is the patch going to work if netfilter conntrack is
enabled ?
