From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH] tcp: md5: fix md5 RST when both sides have listener
Date: Wed, 01 Feb 2012 05:08:33 +0100
Message-ID: <1328069313.2617.15.camel@edumazet-laptop>
References: <1328057424-11962-1-git-send-email-shawn.lu@ericsson.com>
	 <1328057424-11962-2-git-send-email-shawn.lu@ericsson.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: davem@davemloft.net, netdev@vger.kernel.org, xiaoclu@gmail.com
To: Shawn Lu <shawn.lu@ericsson.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ww0-f44.google.com ([74.125.82.44]:60355 "EHLO
	mail-ww0-f44.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752994Ab2BAEIj (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 31 Jan 2012 23:08:39 -0500
Received: by wgbdt10 with SMTP id dt10so790266wgb.1
        for <netdev@vger.kernel.org>; Tue, 31 Jan 2012 20:08:37 -0800 (PST)
In-Reply-To: <1328057424-11962-2-git-send-email-shawn.lu@ericsson.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Le mardi 31 janvier 2012 =C3=A0 16:50 -0800, Shawn Lu a =C3=A9crit :
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
>  net/ipv4/tcp_ipv4.c |   45 +++++++++++++++++++++++++++++++++++++++++=
+---
>  net/ipv6/tcp_ipv6.c |   43 +++++++++++++++++++++++++++++++++++++++++=
--
>  2 files changed, 83 insertions(+), 5 deletions(-)
>=20

Hmm, ok but using RCU for the md5 lookup (instead of mere sock lock as
done today) also means we need to protect struct tcp_md5sig_info itself

I send a patch for this in a separate patch first, then David can apply
your patch when I add my "Signed-off-by: ..."
