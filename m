From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: DDoS attack causing bad effect on conntrack searches
Date: Fri, 23 Apr 2010 07:44:38 +0200
Message-ID: <1272001478.7895.7545.camel@edumazet-laptop>
References: <Pine.LNX.4.64.1004222213290.10919@ask.diku.dk>
	 <1271970199.7895.6482.camel@edumazet-laptop>
	 <1271970893.7895.6507.camel@edumazet-laptop>
	 <20100422.164425.171794554.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: hawk@diku.dk, paulmck@linux.vnet.ibm.com, kaber@trash.net,
	xiaosuo@gmail.com, hawk@comx.dk, netdev@vger.kernel.org,
	netfilter-devel@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-bw0-f225.google.com ([209.85.218.225]:51369 "EHLO
	mail-bw0-f225.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755884Ab0DWFov (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 23 Apr 2010 01:44:51 -0400
In-Reply-To: <20100422.164425.171794554.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Le jeudi 22 avril 2010 =C3=A0 16:44 -0700, David Miller a =C3=A9crit :
> Eric, I wonder if we run into some kind of issue on 32-bit systems
> because we always lose a bit of the conntrack hash value when we stor=
e
> it into the 'nulls' area?
>=20
> Wouldn't that make the "get_nulls_value(n) !=3D hash" fail?
> --


Well, 'hash' at this time is not the result of the jhash() transform [0
- 0xFFFFFFFF], but a slot number in htable [0 - (300032-1)].


And we can have a nulls_value up to 0x7FFFFFFF  (31 bits)

static inline unsigned long get_nulls_value(const struct hlist_nulls_no=
de *ptr)
{
        return ((unsigned long)ptr) >> 1;
}




