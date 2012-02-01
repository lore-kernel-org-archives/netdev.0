From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] tcp: md5: RST: getting md5 key from listener
Date: Wed, 01 Feb 2012 12:44:26 -0500 (EST)
Message-ID: <20120201.124426.592024530798207293.davem@davemloft.net>
References: <RE:_[PATCH]_tcp:_md5:_fix_md5_RST_when_both_sides_have_listener>
	<1328085348-6771-1-git-send-email-shawn.lu@ericsson.com>
	<1328090095.2595.13.camel@edumazet-HP-Compaq-6005-Pro-SFF-PC>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=iso-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: shawn.lu@ericsson.com, netdev@vger.kernel.org, xiaoclu@gmail.com
To: eric.dumazet@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([198.137.202.13]:32800 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752942Ab2BARof convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 1 Feb 2012 12:44:35 -0500
In-Reply-To: <1328090095.2595.13.camel@edumazet-HP-Compaq-6005-Pro-SFF-PC>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

=46rom: Eric Dumazet <eric.dumazet@gmail.com>
Date: Wed, 01 Feb 2012 10:54:55 +0100

> Le mercredi 01 f=E9vrier 2012 =E0 00:35 -0800, Shawn Lu a =E9crit :
>> TCP RST mechanism is broken in TCP md5(RFC2385). When
>> connection is gone, md5 key is lost, sending RST
>> without md5 hash is deem to ignored by peer. This can
>> be a problem since RST help protocal like bgp to fast
>> recove from peer crash.
>>=20
>> In most case, users of tcp md5, such as bgp and ldp,
>> have listener on both sides to accept connection from peer.
>> md5 keys for peers are saved in listening socket.
>>=20
>> There are two cases in finding md5 key when connection is
>> lost:
>> 1.Passive receive RST: The message is send to well known port,
>> tcp will associate it with listner. md5 key is gotten from
>> listener.
>>=20
>> 2.Active receive RST (no sock): The message is send to ative
>> side, there is no socket associated with the message. In this
>> case, finding listener from source port, then find md5 key from
>> listener.
>>=20
>> we are not loosing sercuriy here:
>> packet is checked with md5 hash. No RST is generated
>> if md5 hash doesn't match or no md5 key can be found.
>>=20
>> Signed-off-by: Shawn Lu <shawn.lu@ericsson.com>
>> ---
>> v4: change title and change log.=20
>> regerated after  "tcp: md5: protects md5sig_info with RCU"
>=20
>=20
> Signed-off-by: Eric Dumazet <eric.dumazet@gmail.com>

Applied, thanks everyone.
