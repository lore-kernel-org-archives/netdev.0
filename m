From: Patrick McHardy <kaber@trash.net>
Subject: Re: [PATCH net-next-2.6] macvlan: add multiqueue capability
Date: Thu, 03 Sep 2009 20:27:45 +0200
Message-ID: <4AA00AA1.6040504@trash.net>
References: <4A9F9661.7020301@gmail.com> <4AA002BC.3050507@trash.net> <4AA008C9.4000805@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-15
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: "David S. Miller" <davem@davemloft.net>,
	Linux Netdev List <netdev@vger.kernel.org>
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from stinky.trash.net ([213.144.137.162]:45120 "EHLO
	stinky.trash.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754006AbZICS1r (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 3 Sep 2009 14:27:47 -0400
In-Reply-To: <4AA008C9.4000805@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Eric Dumazet wrote:
> Patrick McHardy a =E9crit :
>> The patch looks fine, but it just occured to me that this won't
>> have any effect since both VLAN and macvlan use a tx_queue_len of 0,
>> so they will by default have queueing disabled. In fact this
>> will increase costs for the default case since we're now hashing
>> every packet.
>=20
> Just read again dev_queue_xmit(), in case we have no queueing
> on macvlan/vlan
>=20
> Having mutiple txq should help multi flow / multi cpus setups,
> since hashing will provide more chances to hit different txq/locks,
> and let several cpus run concurrently, each one on a different queue.

You're right, I missed that we're also perfoming locking in the
noqueue case. Sorry :)
