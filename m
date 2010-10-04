From: Jarek Poplawski <jarkao2@gmail.com>
Subject: Re: [PATCH net-next V3] net: dynamic ingress_queue allocation
Date: Mon, 4 Oct 2010 16:24:15 +0200
Message-ID: <20101004142415.GA2049@del.dom.local>
References: <1285757817.3561.2.camel@bigi>
 <1285887509.2705.33.camel@edumazet-laptop>
 <1285933506.3553.176.camel@bigi>
 <1285941388.2641.175.camel@edumazet-laptop>
 <20101002093255.GA2049@del.dom.local>
 <1286035915.2582.2472.camel@edumazet-laptop>
 <20101003094221.GA2028@del.dom.local>
 <1286181729.18293.8.camel@edumazet-laptop>
 <20101004120626.GA2022@del.dom.local>
 <1286196720.18293.196.camel@edumazet-laptop>
Mime-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: hadi@cyberus.ca, David Miller <davem@davemloft.net>,
	netdev <netdev@vger.kernel.org>
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ww0-f44.google.com ([74.125.82.44]:61748 "EHLO
	mail-ww0-f44.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751181Ab0JDOYV (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 4 Oct 2010 10:24:21 -0400
Received: by wwj40 with SMTP id 40so4165790wwj.1
        for <netdev@vger.kernel.org>; Mon, 04 Oct 2010 07:24:20 -0700 (PDT)
Content-Disposition: inline
In-Reply-To: <1286196720.18293.196.camel@edumazet-laptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, Oct 04, 2010 at 02:52:00PM +0200, Eric Dumazet wrote:
> Le lundi 04 octobre 2010 ?? 14:06 +0200, Jarek Poplawski a =E9crit :
>=20
> > Right, but then at least in qdisc_lookup():
> >=20
> > if (dev_ingress_queue(dev))
> > 	q =3D qdisc_match_from_root(dev_ingress_queue(dev), handle);
> >=20
> > you should use a variable instead of the second dereference (rtnl i=
sn't
> > mandatory here).
>=20
> I am lost.
>=20
> If rntl is not mandatory, what is the lock that protects us ?
>=20
> qdisc_lookup() _is_ called under the protection of a lock.
> Or as soon as we return from it, result could change under us.
>=20
> Please name it, and I'll use it :
>=20
> rcu_dereference_protected(dev->ingress_queue, lockdep_is_held(THISLOC=
K))
>=20

You are right! There is no other lock. (I forgot I removed
qdisc_list_lock already ;-)

Sorry,
Jarek P.
