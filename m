From: Eric Dumazet <dada1@cosmosbay.com>
Subject: Re: [PATCH] [net/ipv4]: fib_seq_show function adjustment to get a
 more sensable output of /proc/net/route
Date: Mon, 22 Oct 2007 21:31:40 +0200
Message-ID: <471CFA9C.7010300@cosmosbay.com>
References: <1193077582-4790-1-git-send-email-crquan@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1;
	format=flowed
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: "David S. Miller" <davem@davemloft.net>,
	Jeff Garzik <jgarzik@pobox.com>, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: Denis Cheng <crquan@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from gw1.cosmosbay.com ([86.65.150.130]:35799 "EHLO
	gw1.cosmosbay.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751681AbXJVTfS (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 22 Oct 2007 15:35:18 -0400
In-Reply-To: <1193077582-4790-1-git-send-email-crquan@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Denis Cheng a =E9crit :
> the temporary bf[127] char array is redundant, and the specified widt=
h 127 make the output of /proc/net/route include many trailing spaces;
> since most terminal's cols are less than 127, this made every fib ent=
ry occupy two lines,
>=20
> after applied this patch, the output of /proc/net/route is more sensa=
ble like this:
>=20
> Iface	Destination	Gateway 	Flags	RefCnt	Use	Metric	Mask		MTU	Window	I=
RTT
> eth0	0001A8C0	00000000	0001	0	0	0	00FFFFFF	0	0	0
> lo	0000007F	00000000	0001	0	0	0	000000FF	0	0	0
> eth0	00000000	0101A8C0	0003	0	0	0	00000000	0	0	0
>=20
> Signed-off-by: Denis Cheng <crquan@gmail.com>

Hum... did you test your patch with many routes declared ? (more than 3=
2 on=20
i386/x86_64)

127 is not a random value, but chosen as a power of two minus 1.
PAGE_SIZE is garanted to be a multiple of 128 (127 chars + line_feed) o=
n all=20
arches.

So each read() on /proc/net/route delivers PAGE_SIZE/128 lines.

With your patch, some lines might be truncated (one every 32 on i386)


