From: Jarek Poplawski <jarkao2@gmail.com>
Subject: Re: [PATCH net-next-2.6] net: force a fresh timestamp for ingress
 packets
Date: Thu, 16 Dec 2010 23:08:38 +0100
Message-ID: <20101216220838.GB2191@del.dom.local>
References: <1292428252.3427.342.camel@edumazet-laptop>
 <20101216211744.GA2191@del.dom.local>
 <1292535039.2655.13.camel@edumazet-laptop>
Mime-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: David Miller <davem@davemloft.net>,
	Changli Gao <xiaosuo@gmail.com>,
	netdev <netdev@vger.kernel.org>,
	Patrick McHardy <kaber@trash.net>
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ww0-f44.google.com ([74.125.82.44]:43654 "EHLO
	mail-ww0-f44.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754040Ab0LPWIo (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 16 Dec 2010 17:08:44 -0500
Received: by wwa36 with SMTP id 36so37581wwa.1
        for <netdev@vger.kernel.org>; Thu, 16 Dec 2010 14:08:43 -0800 (PST)
Content-Disposition: inline
In-Reply-To: <1292535039.2655.13.camel@edumazet-laptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, Dec 16, 2010 at 10:30:39PM +0100, Eric Dumazet wrote:
> Le jeudi 16 d=E9cembre 2010 ?? 22:17 +0100, Jarek Poplawski a =E9crit=
 :
> > On Wed, Dec 15, 2010 at 04:50:52PM +0100, Eric Dumazet wrote:
> > > In commit 8caf153974f2 (net: sch_netem: Fix an inconsistency in i=
ngress
> > > netem timestamps.), Jarek added a logic to refresh timestamps of
> > > ingressed packets going through netem.
> > >=20
> > > I believe we should generalize this, forcing a refresh of timesta=
mps in
> > > dev_queue_xmit_nit() for all ingress packets, whatever qdisc/clas=
s they
> > > used before being delivered.
> > >=20
> > > This way, we can have a good idea when packets are delivered to o=
ur
> > > stack (tcpdump -i ifb0), while a tcpdump on original device gives
> > > timestamps right before ingressing.
> >=20
> > I don't think we should do it. IMHO netem on ingress is a special c=
ase,
> > obviously for testing, and otherwise the real (first) timestamp mig=
ht
> > be valuable for some users.
>=20
> Well, I find difficult to check sfq is actually correctly working
> because timestamps are mixed.
>=20
> After this patch, I found the SFQ allot error for example.
>=20
> I dont know, I feel adding a sysctl like netdev_tstamp_prequeue is no=
t
> worth it...

Hmm... Do you expect more people start debugging SFQ or I missed your
point? ;-) Maybe such a change would be reasonable on a cloned skb?

Jarek P.=20
