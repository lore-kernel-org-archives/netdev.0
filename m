From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: Scalability of interface creation and deletion
Date: Sat, 07 May 2011 18:37:57 +0200
Message-ID: <1304786277.3207.12.camel@edumazet-laptop>
References: <891B02256A0667292521A4BF@Ximines.local>
	 <1304770926.2821.1157.camel@edumazet-laptop>
	 <0F4A638C2A523577CDBC295E@Ximines.local>
	 <1304783684.9216.2.camel@edumazet-laptop>
	 <4DC571F1.2020108@candelatech.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Alex Bligh <alex@alex.org.uk>, netdev@vger.kernel.org
To: Ben Greear <greearb@candelatech.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ww0-f44.google.com ([74.125.82.44]:64594 "EHLO
	mail-ww0-f44.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751067Ab1EGQiB (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 7 May 2011 12:38:01 -0400
Received: by wwa36 with SMTP id 36so4462254wwa.1
        for <netdev@vger.kernel.org>; Sat, 07 May 2011 09:38:00 -0700 (PDT)
In-Reply-To: <4DC571F1.2020108@candelatech.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Le samedi 07 mai 2011 =C3=A0 09:23 -0700, Ben Greear a =C3=A9crit :

> I wonder if it would be worth having a 'delete me soon'
> method to delete interfaces that would not block on the
> RCU code.
>=20
> The controlling programs could use netlink messages to
> know exactly when an interface was truly gone.
>=20
> That should allow some batching in the sync-net logic
> too, if user-space code deletes 1000 interfaces very
> quickly, for instance...
>=20

I suggested in the past to have an extension of batch capabilities, so
that one kthread could have 3 separate lists of devices being destroyed
in //,

This daemon would basically loop on one call to synchronize_rcu(), and
transfert list3 to deletion, list2 to list3, list1 to list2, loop,
eventually releasing RTNL while blocked in synchronize_rcu()

This would need to allow as you suggest an asynchronous deletion method=
,
or use a callback to wake the process blocked on device delete.

Right now, we hold RTNL for the whole 3 steps process, so we cannot use
any parallelism.



