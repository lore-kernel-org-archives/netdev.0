From: =?ISO-8859-2?Q?Nicolas_de_Peslo=FCan?=
	<nicolas.2p.debian@gmail.com>
Subject: Re: [patch net-next-2.6 6/8] bonding: move processing of recv handlers
 into handle_frame()
Date: Sun, 06 Mar 2011 18:37:28 +0100
Message-ID: <4D73C658.6080004@gmail.com>
References: <1299320969-7951-1-git-send-email-jpirko@redhat.com>	<1299320969-7951-7-git-send-email-jpirko@redhat.com>	<4D7249BA.8030401@gmail.com>	<20110305144314.GC8573@psychotron.redhat.com>	<4D724DB4.9020207@gmail.com>	<4D737D00.20406@gmail.com>	<20110306133413.GB2795@psychotron.redhat.com>	<4D739947.6040603@gmail.com> <AANLkTi=Gt_ArqOVPJjnrAExO8Fihu8WzUhYSb_O6URQ_@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-2;
	format=flowed
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Jiri Pirko <jpirko@redhat.com>, netdev@vger.kernel.org,
	davem@davemloft.net, shemminger@linux-foundation.org,
	kaber@trash.net, fubar@us.ibm.com, eric.dumazet@gmail.com,
	andy@greyhouse.net
To: =?ISO-8859-2?Q?Micha=B3_Miros=B3aw?= <mirqus@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ww0-f44.google.com ([74.125.82.44]:63250 "EHLO
	mail-ww0-f44.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750726Ab1CFRhg (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 6 Mar 2011 12:37:36 -0500
Received: by wwb22 with SMTP id 22so4397781wwb.1
        for <netdev@vger.kernel.org>; Sun, 06 Mar 2011 09:37:35 -0800 (PST)
In-Reply-To: <AANLkTi=Gt_ArqOVPJjnrAExO8Fihu8WzUhYSb_O6URQ_@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Le 06/03/2011 17:32, Micha=B3 Miros=B3aw a =E9crit :
[snip]

> Is there a particular reason why this ARP monitoring can't be done in
> userspace (e.g. on AF_PACKET with suitable filter)? Marking slaves
> up/down as their link goes in that direction is easy, but as more and
> more link-state detecting methods/algorithms get added this is
> becoming more of a mess.

Moving as much as possible of bonding into userspace is a long standing=
 target.

I think we currently lack a good way to notify the bonding driver that =
a given slave is available or=20
not. Bringing the slave down on link failure is not appropriate, becaus=
e it would prevent userspace=20
from receiving the ARP packets that would bring the slave up again upon=
 link return.

The only thing we can do is writing into /sys/class/net/bond0/bonding/a=
ctive_slave, to force the=20
active_slave. And this is strictly limited to active-backup mode.

I will let Jay / Andy comment on the general problem.

	Nicolas.
