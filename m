From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 1/2 v2] af-packet: Use existing netdev reference for
 bound sockets.
Date: Fri, 27 May 2011 16:15:42 -0400 (EDT)
Message-ID: <20110527.161542.568477840432205227.davem@davemloft.net>
References: <1306467745.2543.60.camel@edumazet-laptop>
	<4DDF2463.3020001@candelatech.com>
	<1306526921.2533.7.camel@edumazet-laptop>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=iso-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: greearb@candelatech.com, netdev@vger.kernel.org
To: eric.dumazet@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([198.137.202.13]:38640 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753005Ab1E0UPu convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 27 May 2011 16:15:50 -0400
In-Reply-To: <1306526921.2533.7.camel@edumazet-laptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

=46rom: Eric Dumazet <eric.dumazet@gmail.com>
Date: Fri, 27 May 2011 22:08:41 +0200

> Le jeudi 26 mai 2011 =E0 21:11 -0700, Ben Greear a =E9crit :
>> On 05/26/2011 08:42 PM, Eric Dumazet wrote:
>> > Le jeudi 26 mai 2011 =E0 16:55 -0700, greearb@candelatech.com a =E9=
crit :
>>=20
>> >>   out_free:
>> >>   	kfree_skb(skb);
>> >>   out_unlock:
>> >> -	if (dev)
>> >> +	if (dev&&  need_rls_dev)
>> >>   		dev_put(dev);
>> >>   out:
>> >>   	return err;
>> >
>> > Hmmm, I wonder why you want this Ben.
>> >
>> > IMHO this is buggy, because we can sleep in this function.
>> >
>> > We must take a ref on device (its really cheap these days, now we =
have a
>> > percpu device refcnt)
>>=20
>> Why must you take the reference?  And if we must, why isn't the
>> current code that assigns the prot_hook.dev without taking a
>> reference OK?
>>=20
>=20
> If we sleep, device can disappear under us.
>=20
> The only way to not take a reference is to hold rcu_read_lock(), but
> you're not allowed to sleep under rcu_read_lock().

You still have not addresses Ben's point.

Why is it ok for the po->prot_hook.dev handling to not take a
reference?  It's been doing this forever.  Ben is just borrowing this
behavior for his uses.

After some more research I think it happens to be OK because
->prot_hook.dev is used _only_ for pointer comparisons, it is never
actually dereferenced or used in any other way.  Probably, we should
just use ->ifindex for this.

