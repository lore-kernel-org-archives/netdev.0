From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: Scalability of interface creation and deletion
Date: Sat, 07 May 2011 21:24:57 +0200
Message-ID: <1304796297.3207.35.camel@edumazet-laptop>
References: <891B02256A0667292521A4BF@Ximines.local>
	 <1304770926.2821.1157.camel@edumazet-laptop>
	 <0F4A638C2A523577CDBC295E@Ximines.local>
	 <1304785589.3207.5.camel@edumazet-laptop>
	 <178E8895FB84C07251538EF7@Ximines.local>
	 <1304793174.3207.22.camel@edumazet-laptop>
	 <270382A9E068495F7E8A14CC@Ximines.local>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org
To: Alex Bligh <alex@alex.org.uk>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wy0-f174.google.com ([74.125.82.174]:45635 "EHLO
	mail-wy0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756029Ab1EGTZC (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 7 May 2011 15:25:02 -0400
Received: by wya21 with SMTP id 21so3082811wya.19
        for <netdev@vger.kernel.org>; Sat, 07 May 2011 12:25:01 -0700 (PDT)
In-Reply-To: <270382A9E068495F7E8A14CC@Ximines.local>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Le samedi 07 mai 2011 =C3=A0 19:51 +0100, Alex Bligh a =C3=A9crit :
>=20
> --On 7 May 2011 20:32:54 +0200 Eric Dumazet <eric.dumazet@gmail.com> =
wrote:
>=20
> > Well, there is also one rcu_barrier() call that is expensive.
> > (It was changed from one synchronize_rcu() to one rcu_barrier() lat=
ely
> > in commit ef885afb , in 2.6.36 kernel)
>=20
> I think you are saying it may be waiting in rcu_barrier(). I'll
> instrument that later plus synchronize_sched().
>=20
> > http://git2.kernel.org/?p=3Dlinux/kernel/git/torvalds/linux-2.6.git=
;a=3Dcommi
> > tdiff;h=3Def885afbf8a37689afc1d9d545e2f3e7a8276c17
>=20
> OK, so in head, which I am using, rollback_registered_many which
> previously had 2 calls to synchronize_net(), now has one, followed
> by a call to rc_barrier() at the bottom.
>=20

each device dismantle needs 2 synchronize_rcu() and one rcu_barrier()


> Right, that's what I patched before (see patch attached to
> message from earlier today) to do an exponential backoff (see
> previous entry), i.e. do a 5ms sleep, then a 10ms, then a 20ms, but
> never more than 250ms. It made no difference.
>=20

Oh well. How many time are you going to tell us about this ?

We suggested to wait no more than 1 ms, or even shout asap.

If after synchronize_rcu() and rcu_barrier() calls, they are still
references to the device, then there is a BUG somewhere.

Since these bugs are usually not fatal, we just wait a bit.


