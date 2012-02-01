From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH] tcp: md5: fix md5 RST when both sides have listener
Date: Wed, 01 Feb 2012 06:09:18 +0100
Message-ID: <1328072958.2617.34.camel@edumazet-laptop>
References: <RE: [PATCH] tcp: md5: fix md5 RST when both sides have listener>
	 <1328053998-2498-1-git-send-email-shawn.lu@ericsson.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: davem@davemloft.net, netdev@vger.kernel.org, xiaoclu@gmail.com
To: Shawn Lu <shawn.lu@ericsson.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wi0-f174.google.com ([209.85.212.174]:61359 "EHLO
	mail-wi0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751057Ab2BAFJY (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 1 Feb 2012 00:09:24 -0500
Received: by wics10 with SMTP id s10so599089wic.19
        for <netdev@vger.kernel.org>; Tue, 31 Jan 2012 21:09:23 -0800 (PST)
In-Reply-To: <1328053998-2498-1-git-send-email-shawn.lu@ericsson.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Le mardi 31 janvier 2012 =C3=A0 15:53 -0800, Shawn Lu a =C3=A9crit :
> TCP RST mechanism is broken in TCP md5(RFC2385). When
> connection is gone, md5 key is lost, sending RST
> without md5 hash is deem to ignored by peer. This can
> be a problem since RST help protocal like bgp to fast
> recove from peer crash.
>=20
> In most case, users of tcp md5, such as bgp and ldp,
> have listeners on both sides. md5 keys for peers are
> saved in listening socket. When passive side connection
> is gone, we can still get md5 key from listening socket.
> When active side of connection is gone, we can try to
> find listening socket through source port, and then md5
> key.
> we are not loosing sercuriy here:
> packet is valified checked with md5 hash. No RST is generated
> if md5 hash doesn't match or no md5 key can be found.
>=20
> Signed-off-by: Shawn Lu <shawn.lu@ericsson.com>
> ---

Small notes :=20

1) Always add [PATCH Vx] on your submission if it was a new version of =
a
previous patch. (V2, V3, V4, ...)

If possible, add after the "---" separator an explanation of what
changed in your new submission :

V3: added some rcu_read_lock()/rcu_read_unlock() sections

2) Also patch title and changelog are a bit confusing.

Only the machine receiving the TCP message and answering by RST message
needs a listener, in case tcp frame cannot be associated to an existing
tcp socket (ESTABLISHED or TIMEWAIT).

The other side doesnt need a listener, only a client using TCP MD5
option in its socket.

Other than that, your patch seems fine to me.

Acked-by: Eric Dumazet <eric.dumazet@gmail.com>

Thanks !
