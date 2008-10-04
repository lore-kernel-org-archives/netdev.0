From: Jarek Poplawski <jarkao2@gmail.com>
Subject: Re: ax25 rose Re: kernel panic linux-2.6.27-rc7
Date: Sat, 4 Oct 2008 21:11:14 +0200
Message-ID: <20081004191114.GA15152@ami.dom.local>
References: <20081002194845.GB2664@ami.dom.local> <20081003073418.GA5235@ff.dom.local> <20081003074351.GB5235@ff.dom.local> <1223145027.23358.20.camel@f6bvp-5>
Mime-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Linux Netdev List <netdev@vger.kernel.org>,
	Ralf Baechle DL5RB <ralf@linux-mips.org>,
	David Miller <davem@davemloft.net>
To: "Bernard, f6bvp" <f6bvp@free.fr>
Return-path: <netdev-owner@vger.kernel.org>
Received: from ug-out-1314.google.com ([66.249.92.173]:50118 "EHLO
	ug-out-1314.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752516AbYJDTFk (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 4 Oct 2008 15:05:40 -0400
Received: by ug-out-1314.google.com with SMTP id k3so1435454ugf.37
        for <netdev@vger.kernel.org>; Sat, 04 Oct 2008 12:05:38 -0700 (PDT)
Content-Disposition: inline
In-Reply-To: <1223145027.23358.20.camel@f6bvp-5>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sat, Oct 04, 2008 at 08:30:26PM +0200, Bernard, f6bvp wrote:
> Jarek,
>=20
> Following your indications I did it both ways !
> Without ???commit 30902dc3cb0ea1cfc7ac2b17bcf478ff98420d74 patch
> kernel-2.6.27-rc7 is no longer subject to kernel panic when running R=
OSE
> applications.
> Reversely, when this patch is applied to rose-patched 2.6.25.10 kerne=
l,
> this one reboots a few seconds after ROSE application are started.
> Otherwise it is very stable.
> I checked about three times this behaviour for both kernels with and
> without the incriminated patch.
> This confirms without doubt that it is responsible of observed kernel
> panic.
> Is there however a possibility to find a solution to cure the problem
> this patch was dedicated to ?=20

Sure it is! We only need some know-how... (I added David to Cc.)

In the meantime I'll try figure out something too (and maybe prepare
some debugging).

BTW, I think there is an additional, not serious problem with freeing
unorphaned sockets by netrom (as seen in your debugging logs with non
zero in the 2-nd, and 6 in the 3-rd column). So, it would be nice to
check if my #4 patch could help for this. (You need then 2.6.27-rc
with patches #1(debugging), #3, #4 as signed in my previous message,
and of course above mentioned one reverted).

Thanks,
Jarek P.

> Le vendredi 03 octobre 2008 ?? 07:43 +0000, Jarek Poplawski a =E9crit=
 :
> > On Fri, Oct 03, 2008 at 07:34:18AM +0000, Jarek Poplawski wrote:
> > > On 02-10-2008 21:48, Jarek Poplawski wrote:
> > > > On Thu, Oct 02, 2008 at 08:20:18PM +0200, Bernard, f6bvp wrote:
> > > ...
> > > >> Although I did not change anything, and contrarily to my previ=
ous
> > > >> observation, the system instability as shown above occurs
> > > >> systematically.
> > > >> There was no problem with Kernel 2.6.25-10 I was using before =
(with
> > > >> patches for AX25 and ROSE that are now included in 2.6.27-rc7)=
=2E
> > >=20
> > > Then it could be useful to try our luck with reverting some other
> > > "suspicious" changes added in the meantime. My first candidate is
> > > attached below. (So you could test this with vanilla 2.6.27-rc7 o=
r
> > > later, with or without any of the patches in this thread, and the
> > > patch below reverted.)
> >=20
> > Hmm... Of course, you could do this other way as well: 2.6.25-10 et=
c.
> > with this patch applied.
> >=20
> > Jarek P.
> >=20
> > >=20
> > > >> I did not try 2.6.26 on this machine, thus I cannot tell if th=
e bug was
> > > >> already present.
> > > >> Would it be worth to test 2.6.26 ?  =20
> > > >=20
> > > > Yes, but only if you think you can do it safely.
> > >=20
> > > This is still valid (it can wait).
> > >=20
> > > Jarek P.
> > >=20
> > > -------->
> > >=20
> > > commit 30902dc3cb0ea1cfc7ac2b17bcf478ff98420d74
> > > Author: David S. Miller <davem@davemloft.net>
> > > Date:   Tue Jun 17 21:26:37 2008 -0700
> > >=20
> > >     ax25: Fix std timer socket destroy handling.
> > >    =20
> > >     Tihomir Heidelberg - 9a4gl, reports:
> > >    =20
> > >     --------------------
> > >     I would like to direct you attention to one problem existing =
in ax.25
> > >     kernel since 2.4. If listening socket is closed and its SKB q=
ueue is
> > >     released but those sockets get weird. Those "unAccepted()" so=
ckets
> > >     should be destroyed in ax25_std_heartbeat_expiry, but it will=
 not
> > >     happen. And there is also a note about that in ax25_std_timer=
=2Ec:
> > >     /* Magic here: If we listen() and a new link dies before it
> > >     is accepted() it isn't 'dead' so doesn't get removed. */
> > >    =20
> > >     This issue cause ax25d to stop accepting new connections and =
I had to
> > >     restarted ax25d approximately each day and my services were u=
navailable.
> > >     Also netstat -n -l shows invalid source and device for those =
listening
> > >     sockets. It is strange why ax25d's listening socket get weird=
 because of
> > >     this issue, but definitely when I solved this bug I do not ha=
ve problems
> > >     with ax25d anymore and my ax25d can run for months without pr=
oblems.
> > >     --------------------
> > >    =20
> > >     Actually as far as I can see, this problem is even in release=
s
> > >     as far back as 2.2.x as well.
> > >    =20
> > >     It seems senseless to special case this test on TCP_LISTEN st=
ate.
> > >     Anything still stuck in state 0 has no external references an=
d
> > >     we can just simply kill it off directly.
> > >    =20
> > >     Signed-off-by: David S. Miller <davem@davemloft.net>
> > >=20
> > > diff --git a/net/ax25/ax25_std_timer.c b/net/ax25/ax25_std_timer.=
c
> > > index 96e4b92..cdc7e75 100644
> > > --- a/net/ax25/ax25_std_timer.c
> > > +++ b/net/ax25/ax25_std_timer.c
> > > @@ -39,11 +39,9 @@ void ax25_std_heartbeat_expiry(ax25_cb *ax25)
> > > =20
> > >  	switch (ax25->state) {
> > >  	case AX25_STATE_0:
> > > -		/* Magic here: If we listen() and a new link dies before it
> > > -		   is accepted() it isn't 'dead' so doesn't get removed. */
> > > -		if (!sk || sock_flag(sk, SOCK_DESTROY) ||
> > > -		    (sk->sk_state =3D=3D TCP_LISTEN &&
> > > -		     sock_flag(sk, SOCK_DEAD))) {
> > > +		if (!sk ||
> > > +		    sock_flag(sk, SOCK_DESTROY) ||
> > > +		    sock_flag(sk, SOCK_DEAD)) {
> > >  			if (sk) {
> > >  				sock_hold(sk);
> > >  				ax25_destroy_socket(ax25);
> >=20
>=20
