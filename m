From: Oliver Hartkopp <socketcan@hartkopp.net>
Subject: Re: [RFC net-next-2.6] can: replace spinlocks with mutexes
Date: Wed, 20 Apr 2011 18:18:40 +0200
Message-ID: <4DAF0760.6000904@hartkopp.net>
References: <4DAEFC55.2010500@hartkopp.net> <1303313954.3186.117.camel@edumazet-laptop>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: David Miller <davem@davemloft.net>,
	Linux Netdev List <netdev@vger.kernel.org>,
	Kurt Van Dijck <kurt.van.dijck@eia.be>,
	Urs Thuermann <urs@isnogud.escape.de>
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mo-p00-ob.rzone.de ([81.169.146.162]:40967 "EHLO
	mo-p00-ob.rzone.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753790Ab1DTQSq (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 20 Apr 2011 12:18:46 -0400
In-Reply-To: <1303313954.3186.117.camel@edumazet-laptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 20.04.2011 17:39, Eric Dumazet wrote:
> Le mercredi 20 avril 2011 =C3=A0 17:31 +0200, Oliver Hartkopp a =C3=A9=
crit :
>> This patch removes spinlocks for the CAN netdevice specific receive =
lists.
>> The RCU-based receive lists can be modified from process context or =
from the
>> netdevice notifier call. As both might sleep we can safely replace t=
he
>> spinlocks with mutexes.
>>
>> Signed-off-by: Oliver Hartkopp <socketcan@hartkopp.net>
>>
>> ---
>=20
> But... why ?
>=20
> A spinlock is faster/smaller than a mutex.

Hm, i expected the mutex to have some advantages especially in multicor=
e
systems ...

But if it doesn't has any vital advantage, we can leave it as-is.

> Maybe you wanted to _remove_ spinlock, since/if writer hold RTNL and
> doesnt need to exclude another writer(s) ?

That's an interesting idea. The filters are modified at socket
creation/removal time and can also be modified in between using sockopt=
s by
_ordinary_ users. Could that be a problem?

> Note : I did not check the RTNL assertion, you might add appropriate
> ASSERT_RTNL() calls just to be 100% safe.

I'll investigate some similar places in the networking code and then re=
place
the spinlocks with rtnl_locks for some testing.

Thanks for the feedback,
Oliver

