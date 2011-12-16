From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH 00/10 net-next] Introduce per interface ipv4 statistics
Date: Fri, 16 Dec 2011 17:50:44 +0100
Message-ID: <1324054244.25554.56.camel@edumazet-HP-Compaq-6005-Pro-SFF-PC>
References: <igorm@etf.rs> <1324049163-11207-1-git-send-email-igorm@etf.rs>
	  <1324050080.25554.34.camel@edumazet-HP-Compaq-6005-Pro-SFF-PC>
	  <CAFdo_mWY3030_WsL_awXFMaviMA5MGJP_gMs0cM=6KeGQft6-Q@mail.gmail.com>
	 <1324053184.25554.47.camel@edumazet-HP-Compaq-6005-Pro-SFF-PC>
	 <alpine.DEB.2.00.1112161043080.26765@router.home>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: igorm@etf.rs, netdev@vger.kernel.org, davem@davemloft.net
To: Christoph Lameter <cl@linux.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ww0-f44.google.com ([74.125.82.44]:65020 "EHLO
	mail-ww0-f44.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752164Ab1LPQus (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 16 Dec 2011 11:50:48 -0500
Received: by wgbdr13 with SMTP id dr13so6520598wgb.1
        for <netdev@vger.kernel.org>; Fri, 16 Dec 2011 08:50:47 -0800 (PST)
In-Reply-To: <alpine.DEB.2.00.1112161043080.26765@router.home>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Le vendredi 16 d=C3=A9cembre 2011 =C3=A0 10:44 -0600, Christoph Lameter=
 a =C3=A9crit :
> On Fri, 16 Dec 2011, Eric Dumazet wrote:
>=20
> > > Also I did it because ipv6 has per interface stats.
> >
> > I was considering _removing_ them, or make it optional.
> >
> > Memory costs are huge for percpu data.
> >
>=20
> And these costs are going to increase as we add more processors. Inte=
l is
> talking about hundred in the future.
>=20
> So maybe we need to change the per cpu subsystem to be able to alloca=
te
> these only for subsets of cpus and then only allow the operation of
> the network subsystems on the same subset? That would also increase c=
ache
> hotness. Pretty radical but I think at some point we will have to con=
sider
> that given that the number of cpus keep growing.
>=20

Or we could use a hierarchical split : Say 16 (or 32 or 64) cpus share
same counters (must be atomic if NR_CPUS > 16/32/64)

percpu_alloc() -> percpugroup_alloc()
