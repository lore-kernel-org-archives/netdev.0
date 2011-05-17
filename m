From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: small RPS cache for fragments?
Date: Tue, 17 May 2011 22:14:48 +0200
Message-ID: <1305663288.2691.2.camel@edumazet-laptop>
References: <20110517.143342.1566027350038182221.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wy0-f174.google.com ([74.125.82.174]:57449 "EHLO
	mail-wy0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932112Ab1EQUOw (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 17 May 2011 16:14:52 -0400
Received: by wya21 with SMTP id 21so689213wya.19
        for <netdev@vger.kernel.org>; Tue, 17 May 2011 13:14:51 -0700 (PDT)
In-Reply-To: <20110517.143342.1566027350038182221.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Le mardi 17 mai 2011 =C3=A0 14:33 -0400, David Miller a =C3=A9crit :
> It seems to me that we can solve the UDP fragmentation problem for
> flow steering very simply by creating a (saddr/daddr/IPID) entry in a
> table that maps to the corresponding RPS flow entry.
>=20
> When we see the initial frag with the UDP header, we create the
> saddr/daddr/IPID mapping, and we tear it down when we hit the
> saddr/daddr/IPID mapping and the packet has the IP_MF bit clear.
>=20

> We only inspect the saddr/daddr/IPID cache when iph->frag_off is
> non-zero.
>=20

> It's best effort and should work quite well.
>=20
> Even a one-behind cache, per-NAPI instance, would do a lot better tha=
n
> what happens at the moment.  Especially since the IP fragments mostly
> arrive as one packet train.
> --

OK but do we have workloads actually needing this optimization at all ?

(IP defrag hits a read_lock(&ip4_frags.lock)), so maybe steer all frags
on a given cpu ?)




