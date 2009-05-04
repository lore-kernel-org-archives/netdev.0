From: Matthias Saou
	<thias@spam.spam.spam.spam.spam.spam.spam.egg.and.spam.freshrpms.net>
Subject: Re: Wrong network usage reported by /proc
Date: Mon, 4 May 2009 21:11:51 +0200
Message-ID: <20090504211151.74622f29@python3.es.egwn.lan>
References: <20090504171408.3e13822c@python3.es.egwn.lan>
	<49FF2BB2.4030700@cosmosbay.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: linux-kernel@vger.kernel.org,
	Linux Netdev List <netdev@vger.kernel.org>
To: Eric Dumazet <dada1@cosmosbay.com>
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S1754235AbZEDTMR@vger.kernel.org>
In-Reply-To: <49FF2BB2.4030700@cosmosbay.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Eric Dumazet wrote :

> Matthias Saou a =E9crit :
> > Hi,
> >=20
> > I'm posting here as a last resort. I've got lots of heavily used RH=
EL5
> > servers (2.6.18 based) that are reporting all sorts of impossible
> > network usage values through /proc, leading to unrealistic snmp/cac=
ti
> > graphs where the outgoing bandwidth used it higher than the physica=
l
> > interface's maximum speed.
> >=20
> > For some details and a test script which compares values from /proc
> > with values from tcpdump :
> > https://bugzilla.redhat.com/show_bug.cgi?id=3D489541
> >=20
> > The values collected using tcpdump always seem realistic and match =
the
> > values seen on the remote network equipments. So my obvious conclus=
ion
> > (but possibly wrong given my limited knowledge) is that something i=
s
> > wrong in the kernel, since it's the one exposing the /proc interfac=
e.
> >=20
> > I've reproduced what seems to be the same problem on recent kernels=
,
> > including the 2.6.27.21-170.2.56.fc10.x86_64 I'm running right now.=
 The
> > simple python script available here allows to see it quite easily :
> > https://www.redhat.com/archives/rhelv5-list/2009-February/msg00166.=
html
> >=20
> >  * I run the script on my Workstation, I have an FTP server enabled
> >  * I download a DVD ISO from a remote workstation : The values matc=
h
> >  * I start ping floods from remote workstations : The values report=
ed
> >    by /proc are much higher than the ones reported by tcpdump. I us=
ed
> >    "ping -s 500 -f myworkstation" from two remote workstations
> >=20
> > If there's anything flawed in my debugging, I'd love to have someon=
e
> > point it out to me. TIA to anyone willing to have a look.
> >=20
> > Matthias
> >=20
>=20
> I could not reproduce this here... what kind of NIC are you using on
> affected systems ? Some ethernet drivers report stats from card itsel=
f,
> and I remember seeing some strange stats on some hardware, but I cann=
ot
> remember which one it was (we were reading NULL values instead of
> real ones, once in a while, maybe it was a firmware issue...)

My workstation has a Broadcom BCM5752 (tg3 module). The servers which
are most affected have Intel 82571EB (e1000e). But the issue is that
with /proc, the values are a lot _higher_ than with tcpdump, and the
tcpdump values seem to be the correct ones.

Matthias

--=20
Clean custom Red Hat Linux rpm packages : http://freshrpms.net/
=46edora release 10 (Cambridge) - Linux kernel
2.6.27.21-170.2.56.fc10.x86_64 Load : 2.20 0.88 0.42
