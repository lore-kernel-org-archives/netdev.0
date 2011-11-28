From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 5/5] tcp: skip cwnd moderation in TCP_CA_Open in
 tcp_try_to_open
Date: Sun, 27 Nov 2011 19:01:20 -0500 (EST)
Message-ID: <20111127.190120.2116987138205753451.davem@davemloft.net>
References: <alpine.DEB.2.00.1111201024080.22397@melkinpaasi.cs.helsinki.fi>
	<CAK6E8=cNBCJbQs9dKcOwU1yZMC6czgMEuZt4Ubt=t-kBzHfFmw@mail.gmail.com>
	<alpine.DEB.2.00.1111221146060.31705@wel-95.cs.helsinki.fi>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=iso-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: ycheng@google.com, ncardwell@google.com, netdev@vger.kernel.org,
	nanditad@google.com, therbert@google.com
To: ilpo.jarvinen@helsinki.fi
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([198.137.202.13]:47958 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754208Ab1K1ABa convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 27 Nov 2011 19:01:30 -0500
In-Reply-To: <alpine.DEB.2.00.1111221146060.31705@wel-95.cs.helsinki.fi>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

=46rom: "Ilpo J=E4rvinen" <ilpo.jarvinen@helsinki.fi>
Date: Tue, 22 Nov 2011 13:47:13 +0200 (EET)

> On Mon, 21 Nov 2011, Yuchung Cheng wrote:
>=20
>> AFAIK cwnd moderation is to lower bursty drops not to discourage
>> (dsack) cheating. I believe the reason is the same in
>> tcp_try_to_open(). We are in common cases, e.g., loss-recovery, this
>> logic hurts performance.
>=20
> Quote from the patch description: "Senders were overriding cwnd value=
s=20
> picked during an undo by calling tcp_moderate_cwnd()" ...so after all=
 it=20
> has to do with undo being limited. IMHO only up to orig_cwnd/2+IW is =
safe=20
> due to cheating opportunities. Also FRTO uses orig_cwnd/2 due to same=
=20
> reason (it could do the +IW too but IIRC it is only /2 currently). Wh=
at=20
> would be the safeguard there after this one is removed? I kind of see=
 your=20
> point about this particular line being related to burst mitigation bu=
t on=20
> the same time the end result of removal is that undo becomes potentia=
lly=20
> much more aggressive.

I'm apply this patch to net-next now, but Neil and Yucheng are on the h=
ook
to fully look into the issues Ilpo has raised.

Thanks.
