From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net] udp: fix dst races with multicast early demux
Date: Mon, 03 Aug 2015 22:20:57 -0700 (PDT)
Message-ID: <20150803.222057.510107185355144530.davem@davemloft.net>
References: <1438337866.2748.5.camel@edumazet-glaptop2.roam.corp.google.com>
	<1438341449.2748.9.camel@edumazet-glaptop2.roam.corp.google.com>
	<1438424073.2748.28.camel@edumazet-glaptop2.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=iso-8859-2
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Gregory.Hoggarth@alliedtelesis.co.nz, sbohrer@rgmadvisors.com,
	netdev@vger.kernel.org, alexgartrell@gmail.com, mkubecek@suse.cz
To: eric.dumazet@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:47206 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752171AbbHDFU6 convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 4 Aug 2015 01:20:58 -0400
In-Reply-To: <1438424073.2748.28.camel@edumazet-glaptop2.roam.corp.google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

=46rom: Eric Dumazet <eric.dumazet@gmail.com>
Date: Sat, 01 Aug 2015 12:14:33 +0200

> From: Eric Dumazet <edumazet@google.com>
>=20
> Multicast dst are not cached. They carry DST_NOCACHE.
>=20
> As mentioned in commit f8864972126899 ("ipv4: fix dst race in
> sk_dst_get()"), these dst need special care before caching them
> into a socket.
>=20
> Caching them is allowed only if their refcnt was not 0, ie we
> must use atomic_inc_not_zero()
>=20
> Also, we must use READ_ONCE() to fetch sk->sk_rx_dst, as mentioned
> in commit d0c294c53a771 ("tcp: prevent fetching dst twice in early de=
mux
> code")
>=20
> Fixes: 421b3885bf6d ("udp: ipv4: Add udp early demux")
> Signed-off-by: Eric Dumazet <edumazet@google.com>
> Reported-by: Gregory Hoggarth <Gregory.Hoggarth@alliedtelesis.co.nz>
> Reported-by: Alex Gartrell <agartrell@fb.com>
> Cc: Michal Kube=E8ek <mkubecek@suse.cz>
> ---
> David : I will be on vacation for following 7 days, no internet acces=
s.
> Please wait for tests done by Gregory & Alex before merging this ?
> Thanks !

Now that this has been tested by Gregory, applied and queued up for
-stable thanks!
