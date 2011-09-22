From: tim <tim.c.chen@intel.com>
Subject: Re: [PATCH v2 net-next] af_unix: dont send SCM_CREDENTIALS by
 default
Date: Thu, 22 Sep 2011 09:15:26 -0700
Message-ID: <1316708126.1769.1.camel@schen9-lap>
References: <1315488497.2456.21.camel@edumazet-HP-Compaq-6005-Pro-SFF-PC>
	 <1315473888.2301.21.camel@schen9-mobl>
	 <1315544777.5410.19.camel@edumazet-laptop>
	 <20110918.210758.2207266633127640132.davem@davemloft.net>
	 <1316406528.2521.15.camel@edumazet-laptop>
	 <1316444524.2539.26.camel@edumazet-HP-Compaq-6005-Pro-SFF-PC>
	 <1316447547.2539.34.camel@edumazet-HP-Compaq-6005-Pro-SFF-PC>
	 <1316468398.4680.6.camel@schen9-DESK>
	 <6030.1316484637@turing-police.cc.vt.edu>
	 <1316492170.2455.43.camel@edumazet-laptop>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Valdis.Kletnieks@vt.edu, Tim Chen <tim.c.chen@linux.intel.com>,
	David Miller <davem@davemloft.net>, zheng.z.yan@intel.com,
	yanzheng@21cn.com, netdev@vger.kernel.org, sfr@canb.auug.org.au,
	jirislaby@gmail.com, sedat.dilek@gmail.com, alex.shi@intel.com
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga02.intel.com ([134.134.136.20]:25790 "EHLO mga02.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751251Ab1IVQN5 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 22 Sep 2011 12:13:57 -0400
In-Reply-To: <1316492170.2455.43.camel@edumazet-laptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, 2011-09-20 at 06:16 +0200, Eric Dumazet wrote:
> Le lundi 19 septembre 2011 =C3=A0 22:10 -0400, Valdis.Kletnieks@vt.ed=
u a
> =C3=A9crit :
> > On Mon, 19 Sep 2011 14:39:58 PDT, Tim Chen said:
> > > Do we have to worry about the case where peer socket changes its =
flag
> > > to SOCK_PASSCRED while packets are in flight?  If there isn't suc=
h
> > > pathological use case, the patch looks fine to me.
> >=20
> > I wouldn't think so - if you're sending a packet, and retroactively=
 trying to
> > change the flag and expect it to work, your program is too ugly to =
live.  After
> > all, if the scheduler had cut off your timeslice and scheduledthe r=
eceiving
> > process before you set the flag, that packet would be delivered and=
 done with
> > anyhow, and no amount of wishing will set that flag on an already-d=
elivered
> > packet.
> >=20
> > What *is* worth checking is that we DTRT if a process/thread is doi=
ng a send on
> > one CPU, and another process/thread with a shared file descriptor f=
or that
> > socket is diddling the flag.  But if we just define it as "atomic o=
p to change
> > the flag and other observers get whatever value their CPU sees at t=
hat
> > instant", I'm OK with that too.. ;)
> >=20
>=20
> Note : The man page does states :
>=20
> "To receive a struct ucred message the SO_PASSCRED option  must  be
> enabled  on  the socket."
>=20
> But it doesnt say if the SO_PASSCRED option must be enabled before th=
e
> sender sends its message, or before receiver attempts to read it.
>=20
> Once a message is queued on an unix socket, flipping SO_PASSCRED cant
> change its content (adding or removing credentials), since sender mig=
ht
> already have disappeared.
>=20
> So current code includes credentials in all sent messages, just in ca=
se
> receiver actually fetch credentials.
>=20
> There are probably programs that assume they can set SO_PASSCRED righ=
t
> before calling recvmsg(). Are we taking risk to break them, or are we
> gentle and provide a sysctl option to ease the transition, I dont
> know...
>=20

Should we reconsider the original approach of reducing the
pid/credential references, with your fixes to correct its flaws in the
streaming msg case?

Tim
