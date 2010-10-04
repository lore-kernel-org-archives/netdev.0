From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH net-next V3] net: dynamic ingress_queue allocation
Date: Mon, 04 Oct 2010 14:52:00 +0200
Message-ID: <1286196720.18293.196.camel@edumazet-laptop>
References: <1285689517.3154.76.camel@edumazet-laptop>
	 <20100928180447.GA1880@del.dom.local> <1285757817.3561.2.camel@bigi>
	 <1285887509.2705.33.camel@edumazet-laptop> <1285933506.3553.176.camel@bigi>
	 <1285941388.2641.175.camel@edumazet-laptop>
	 <20101002093255.GA2049@del.dom.local>
	 <1286035915.2582.2472.camel@edumazet-laptop>
	 <20101003094221.GA2028@del.dom.local>
	 <1286181729.18293.8.camel@edumazet-laptop>
	 <20101004120626.GA2022@del.dom.local>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: hadi@cyberus.ca, David Miller <davem@davemloft.net>,
	netdev <netdev@vger.kernel.org>
To: Jarek Poplawski <jarkao2@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-fx0-f46.google.com ([209.85.161.46]:63496 "EHLO
	mail-fx0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755803Ab0JDMwH (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 4 Oct 2010 08:52:07 -0400
Received: by fxm14 with SMTP id 14so1655758fxm.19
        for <netdev@vger.kernel.org>; Mon, 04 Oct 2010 05:52:05 -0700 (PDT)
In-Reply-To: <20101004120626.GA2022@del.dom.local>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Le lundi 04 octobre 2010 =C3=A0 14:06 +0200, Jarek Poplawski a =C3=A9cr=
it :

> Right, but then at least in qdisc_lookup():
>=20
> if (dev_ingress_queue(dev))
> 	q =3D qdisc_match_from_root(dev_ingress_queue(dev), handle);
>=20
> you should use a variable instead of the second dereference (rtnl isn=
't
> mandatory here).

I am lost.

If rntl is not mandatory, what is the lock that protects us ?

qdisc_lookup() _is_ called under the protection of a lock.
Or as soon as we return from it, result could change under us.

Please name it, and I'll use it :

rcu_dereference_protected(dev->ingress_queue, lockdep_is_held(THISLOCK)=
)



