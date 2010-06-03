From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [Bugme-new] [Bug 16083] New: swapper: Page allocation failure
Date: Thu, 03 Jun 2010 23:13:23 +0200
Message-ID: <1275599603.2533.58.camel@edumazet-laptop>
References: <bug-16083-10286@https.bugzilla.kernel.org/>
	 <20100603130235.c372b38f.akpm@linux-foundation.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: "David S. Miller" <davem@davemloft.net>, netdev@vger.kernel.org
To: Andrew Morton <akpm@linux-foundation.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ww0-f46.google.com ([74.125.82.46]:54079 "EHLO
	mail-ww0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752589Ab0FCVN2 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 3 Jun 2010 17:13:28 -0400
Received: by wwb28 with SMTP id 28so425116wwb.19
        for <netdev@vger.kernel.org>; Thu, 03 Jun 2010 14:13:26 -0700 (PDT)
In-Reply-To: <20100603130235.c372b38f.akpm@linux-foundation.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Le jeudi 03 juin 2010 =C3=A0 13:02 -0700, Andrew Morton a =C3=A9crit :
> On Mon, 31 May 2010 15:55:12 GMT
> bugzilla-daemon@bugzilla.kernel.org wrote:
>=20
> > https://bugzilla.kernel.org/show_bug.cgi?id=3D16083
> >=20
> >            Summary: swapper: Page allocation failure
> >            Product: Memory Management
> >            Version: 2.5
> >     Kernel Version: 2.6.34
> >           Platform: All
> >         OS/Version: Linux
> >               Tree: Mainline
> >             Status: NEW
> >           Severity: normal
> >           Priority: P1
> >          Component: Other
> >         AssignedTo: akpm@linux-foundation.org
> >         ReportedBy: sgunderson@bigfoot.com
> >         Regression: No
> >=20
> >=20
> > Hi,
> >=20
> > Since upgrading from a Q9450 to 2xE5520 (and upgrading from 2.6.34-=
rc-something
> > to 2.6.34), I've started seeing these:
> >=20
> > [605882.372418] swapper: page allocation failure. order:2, mode:0x4=
020
> > [605882.378981] Pid: 0, comm: swapper Not tainted 2.6.34 #1
> > [605882.384617] Call Trace:
> > [605882.387499]  <IRQ>  [<ffffffff81096d5a>] __alloc_pages_nodemask=
+0x5b0/0x629
> > [605882.395068]  [<ffffffff81096de5>] __get_free_pages+0x12/0x4f
> > [605882.401103]  [<ffffffff810bdeb4>] __kmalloc_track_caller+0x4c/0=
x156
> > [605882.407817]  [<ffffffff81245986>] ? sock_alloc_send_pskb+0xdd/0=
x32d
> > [605882.414556]  [<ffffffff8124a515>] __alloc_skb+0x66/0x15b
>=20
> I wonder if we should switch __alloc_skb() over to __GFP_NOWARN.=20
> People keep on reporting events such as the above, and nobody's
> getting any value from this.
>=20

Then we could make __GFP_NOWARN for all allocations in kernel, why
network is so special ?

> Downsides:
>=20
> - the change would tend to deprive MM developers of prompt "hey you
>   broke it again" notifications.
>=20
> - if a system is getting enough allocation failures to impact
>   throughput, the operators won't *know* that it's happening, and so
>   they won't make the changes necessary to reduce the frequency of
>   memory allocation failures.
>=20

We should have SNMP counter increments=20

> If these are likely to be a problem, perhaps networking could provide
> some other form of "hey, you keep on running out of memory"
> notification, if it doesn't already do so.
>=20
> Thoughts?
>=20

order-2 ATOMIC allocations ?

skb =3D mld_newpack(dev, dev->mtu);

Let's face it : It can not work in the long term.

MTU=3D9000 on a system with 4K pages... Oh well...

maybe net/ipv6/mcast.c should cap dev->mtu to PAGE_SIZE-128 or
something, so that order-0 allocations are done.



