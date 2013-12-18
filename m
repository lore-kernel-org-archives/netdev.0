From: Ding Tianhong <dthxman@gmail.com>
Subject: Re: [PATCH net] net: neighbour: add neighbour dead check for neigh_timer_handler()
Date: Wed, 18 Dec 2013 23:12:51 +0800
Message-ID: <52B1BB73.20005@gmail.com>
References: <529FF066.1070307@huawei.com> <52B142AF.8070708@huawei.com> <20131218075131.GD27460@order.stressinduktion.org> <52B15A9F.6030301@huawei.com> <20131218084106.GF27460@order.stressinduktion.org> <52B1635D.7020205@huawei.com> <20131218092815.GA3505@order.stressinduktion.org> <52B172B9.7030609@huawei.com> <20131218102132.GB3505@order.stressinduktion.org> <52B18DB4.80403@gmail.com> <20131218142715.GC3505@order.stressinduktion.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
To: Ding Tianhong <dingtianhong@huawei.com>,
	Eric Dumazet <eric.dumazet@gmail.com>,
	David Miller <davem@davemloft.net>, yoshfuji@linux-ipv6.org,
	joe@perches.com, vfalico@redhat.com, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pd0-f174.google.com ([209.85.192.174]:34164 "EHLO
	mail-pd0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754807Ab3LRPYX (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 18 Dec 2013 10:24:23 -0500
Received: by mail-pd0-f174.google.com with SMTP id x10so185404pdj.5
        for <netdev@vger.kernel.org>; Wed, 18 Dec 2013 07:24:23 -0800 (PST)
In-Reply-To: <20131218142715.GC3505@order.stressinduktion.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

=E4=BA=8E 2013/12/18 22:27, Hannes Frederic Sowa =E5=86=99=E9=81=93:
> On Wed, Dec 18, 2013 at 07:57:40PM +0800, Ding Tianhong wrote:
>> yes, I cannot repruduce the bug again.
>=20
> Hmm, it actually seems hard to hit even if the race happens. Even if =
slab
> poisoning is active it would only hit if ->solicit would be called ag=
ain,
> because that is the only pointer dereference directly used in the old=
 memory.
>=20
> neigh_alloc allocates memory with kzalloc, so it would null out that =
memory,
> so the race would not only have to race with kfree, the memory needs =
to be
> reallocated in the mean time.
>=20
> I would suggest adding some poisoning manually in neigh_release befor=
e kfree
> and check for this in all periodic called functions. Maybe we can see=
 it
> again?
>=20
> Greetings,
>=20
>   Hannes
>=20

Great, thanks for your help, I think make the neigh_release not kfree n=
eighbour until
the timer is over is a clear way to  fix this, maybe you could another =
idea, glad to
hear your opinion.

Regards
Ding

>=20
