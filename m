From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: Scalability of interface creation and deletion
Date: Sat, 07 May 2011 18:51:05 +0200
Message-ID: <1304787065.3207.17.camel@edumazet-laptop>
References: <891B02256A0667292521A4BF@Ximines.local>
	 <1304770926.2821.1157.camel@edumazet-laptop>
	 <0F4A638C2A523577CDBC295E@Ximines.local>
	 <1304783684.9216.2.camel@edumazet-laptop>
	 <4DC571F1.2020108@candelatech.com>
	 <1304786277.3207.12.camel@edumazet-laptop>
	 <4DC57702.4090606@candelatech.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Alex Bligh <alex@alex.org.uk>, netdev@vger.kernel.org
To: Ben Greear <greearb@candelatech.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wy0-f174.google.com ([74.125.82.174]:46542 "EHLO
	mail-wy0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752352Ab1EGQvJ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 7 May 2011 12:51:09 -0400
Received: by wya21 with SMTP id 21so3037988wya.19
        for <netdev@vger.kernel.org>; Sat, 07 May 2011 09:51:08 -0700 (PDT)
In-Reply-To: <4DC57702.4090606@candelatech.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Le samedi 07 mai 2011 =C3=A0 09:44 -0700, Ben Greear a =C3=A9crit :
> On 05/07/2011 09:37 AM, Eric Dumazet wrote:
> > Le samedi 07 mai 2011 =C3=A0 09:23 -0700, Ben Greear a =C3=A9crit :
> >
> >> I wonder if it would be worth having a 'delete me soon'
> >> method to delete interfaces that would not block on the
> >> RCU code.
> >>
> >> The controlling programs could use netlink messages to
> >> know exactly when an interface was truly gone.
> >>
> >> That should allow some batching in the sync-net logic
> >> too, if user-space code deletes 1000 interfaces very
> >> quickly, for instance...
> >>
> >
> > I suggested in the past to have an extension of batch capabilities,=
 so
> > that one kthread could have 3 separate lists of devices being destr=
oyed
> > in //,
> >
> > This daemon would basically loop on one call to synchronize_rcu(), =
and
> > transfert list3 to deletion, list2 to list3, list1 to list2, loop,
> > eventually releasing RTNL while blocked in synchronize_rcu()
> >
> > This would need to allow as you suggest an asynchronous deletion me=
thod,
> > or use a callback to wake the process blocked on device delete.
>=20
> I'd want to at least have the option to not block the calling
> process...otherwise, it would be a lot more difficult to
> quickly delete 1000 interfaces.  You'd need 1000 threads, or
> sockets, or something to parallelize it otherwise, eh?

Yes, if you can afford not receive a final notification of device being
fully freed, it should be possible.


