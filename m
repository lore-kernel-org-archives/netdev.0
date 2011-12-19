From: David Miller <davem@davemloft.net>
Subject: Re: linux-3.0.x regression with ipv4 routes having mtu
Date: Mon, 19 Dec 2011 15:09:03 -0500 (EST)
Message-ID: <20111219.150903.108164273331779302.davem@davemloft.net>
References: <20111216122147.GJ6348@secunet.com>
	<4EEB5602.2060806@iki.fi>
	<20111219135259.GK6348@secunet.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=iso-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: timo.teras@iki.fi, netdev@vger.kernel.org
To: steffen.klassert@secunet.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([198.137.202.13]:58258 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752948Ab1LSUJS convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 19 Dec 2011 15:09:18 -0500
In-Reply-To: <20111219135259.GK6348@secunet.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

=46rom: Steffen Klassert <steffen.klassert@secunet.com>
Date: Mon, 19 Dec 2011 14:52:59 +0100

> On Fri, Dec 16, 2011 at 04:30:26PM +0200, Timo Ter=E4s wrote:
>> On 12/16/2011 02:21 PM, Steffen Klassert wrote:
>> >=20
>> > "ip route flush cache" does not even flush the routing cache,
>> > it just markes the routing cache as invalid by changing the
>> > rt_genid which make the old routes invisible. And since we don't
>> > have rt_check_expire() anymore, we have to wait until we have
>> > collected gc_thresh (1024) useless routes before rt_garbage_collec=
t()
>> > starts to remove some of them (btw. is this intentional).
>> >=20
>> > I think we need a trigger in rt_cache_invalidate() that expires
>> > all cached pmtu values similar to the routing cache entries.
>> > For a moment I thought we could just reset the __rt_peer_genid
>> > value back to zero to mark all cached pmtu values as expired,
>> > but that's apparently not save to do. So I came to no conclusion
>> > how to fix this today. Any ideas?
>>=20
>> Oh, right. This problem is secondary. As long as the mtu value is
>> reflected properly, I'll be happy :)
>>=20
>=20
> Well, "ip route flush cache" flushed the cached pmtu informations
> in 2.6.38 and before, now it does not do it anymore. I guess
> some users rely on the old behaviour, so it would be nice if we
> could restore it. I think we can fix this by adding a pmtu_genid,
> exactly in the same way as we have now the redirect_genid.
> I'll give this a try.

Actually, adding yet another ID is pointless.

Just get rid of redirect_genid, and use net->ipv4.rt_genid for all of
the necessary purposes.  Let there be one ID in the inetpeer and use
the net->ipv4.rt_genid to drive it.
