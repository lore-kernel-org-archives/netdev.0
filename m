From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: netlink stats: Ability to get stats for a single device?
Date: Tue, 26 Oct 2010 21:56:26 +0200
Message-ID: <1288122986.2652.20.camel@edumazet-laptop>
References: <4CC72C80.9010802@candelatech.com>
	 <20101026.123811.13746869.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: greearb@candelatech.com, netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ew0-f46.google.com ([209.85.215.46]:35779 "EHLO
	mail-ew0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1758821Ab0JZT4b (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 26 Oct 2010 15:56:31 -0400
Received: by ewy7 with SMTP id 7so5785062ewy.19
        for <netdev@vger.kernel.org>; Tue, 26 Oct 2010 12:56:30 -0700 (PDT)
In-Reply-To: <20101026.123811.13746869.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Le mardi 26 octobre 2010 =C3=A0 12:38 -0700, David Miller a =C3=A9crit =
:
> From: Ben Greear <greearb@candelatech.com>
> Date: Tue, 26 Oct 2010 12:31:12 -0700
>=20
> > Am I missing something, or do I just need to write up a patch
> > to have netlink pay attention to the ifindex?
>=20
> Setting the ->ifi_index or IFLA_IFNAME attribute values appropriately
> in the getlink request doesn't work?
>=20
> That should give you back, amonst other things, the rtnl_link_stats
> for the device in the netlink response.
> --

Yep, it should be easy to change iproute2 to not ask a full dump
in ip/ipaddress.c :

if (rtnl_wilddump_request(&rth, preferred_family, RTM_GETLINK) < 0) ...

and instead use rtnl_send() or something like that, if user provided on=
e
specific interface name   (or index)

ip link show dev eth0




