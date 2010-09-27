From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] net: reset skb queue mapping when rx'ing over tunnel
Date: Sun, 26 Sep 2010 18:48:56 -0700 (PDT)
Message-ID: <20100926.184856.229756077.davem@davemloft.net>
References: <1285293960.2380.23.camel@edumazet-laptop>
	<AANLkTimG9ZCZwDyo_9bYURShn7hk6ROzX4-qypo7nG5i@mail.gmail.com>
	<1285397350.2478.102.camel@edumazet-laptop>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=iso-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: therbert@google.com, netdev@vger.kernel.org, chavey@google.com
To: eric.dumazet@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:60203
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1757665Ab0I0Bsg convert rfc822-to-8bit
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Sun, 26 Sep 2010 21:48:36 -0400
In-Reply-To: <1285397350.2478.102.camel@edumazet-laptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

=46rom: Eric Dumazet <eric.dumazet@gmail.com>
Date: Sat, 25 Sep 2010 08:49:10 +0200

> Le vendredi 24 septembre 2010 =E0 09:18 -0700, Tom Herbert a =E9crit =
:
>> > Hmm...
>> >
>> > This would need to be reverted later when tunnels are updated to b=
e
>> > multiqueue aware ? I made an attempt with GRE some days ago.
>> >
>> > I dont understand why this patch is needed, since get_rps_cpu() ha=
s a
>> > check anyway
>> >
>> I think the skb queue_mapping should correspond to a queue in the
>> skb's device as an invariant.  In the case that an skb's device is
>> change from a multiqueue device to single queue device (like GRE), t=
he
>> inconsistency in the queue_mapping is fairly innocuous, we get one
>> warning but will pretty much take the unlikely branch for GRE packet=
s
>> then on.  But imagine a case where skb's device was change from one
>> multiqueue device to another, but the queue mapping was not also
>> updated.  This  would cause poor weighting in get_rps_cpus.  For
>> example, if the new device had fewer queues than the old one,
>> get_rps_cpu will bias toward using queue 0's rps mask.
>=20
> I believe your patch is fine. Thanks
>=20
> Acked-by: Eric Dumazet <eric.dumazet@gmail.com>

Applied, thanks everyone.
