From: Willy Tarreau <w@1wt.eu>
Subject: Re: Wrong network usage reported by /proc
Date: Tue, 5 May 2009 07:04:37 +0200
Message-ID: <20090505050435.GK570@1wt.eu>
References: <20090504171408.3e13822c@python3.es.egwn.lan> <49FF2BB2.4030700@cosmosbay.com> <20090504211151.74622f29@python3.es.egwn.lan>
Mime-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Eric Dumazet <dada1@cosmosbay.com>, linux-kernel@vger.kernel.org,
	Linux Netdev List <netdev@vger.kernel.org>
To: Matthias Saou
	<thias@spam.spam.spam.spam.spam.spam.spam.egg.and.spam.freshrpms.net>
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S1755384AbZEEFFF@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <20090504211151.74622f29@python3.es.egwn.lan>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Mon, May 04, 2009 at 09:11:51PM +0200, Matthias Saou wrote:
> Eric Dumazet wrote :
>=20
> > Matthias Saou a =E9crit :
> > > Hi,
> > >=20
> > > I'm posting here as a last resort. I've got lots of heavily used =
RHEL5
> > > servers (2.6.18 based) that are reporting all sorts of impossible
> > > network usage values through /proc, leading to unrealistic snmp/c=
acti
> > > graphs where the outgoing bandwidth used it higher than the physi=
cal
> > > interface's maximum speed.
> > >=20
> > > For some details and a test script which compares values from /pr=
oc
> > > with values from tcpdump :
> > > https://bugzilla.redhat.com/show_bug.cgi?id=3D489541
> > >=20
> > > The values collected using tcpdump always seem realistic and matc=
h the
> > > values seen on the remote network equipments. So my obvious concl=
usion
> > > (but possibly wrong given my limited knowledge) is that something=
 is
> > > wrong in the kernel, since it's the one exposing the /proc interf=
ace.
> > >=20
> > > I've reproduced what seems to be the same problem on recent kerne=
ls,
> > > including the 2.6.27.21-170.2.56.fc10.x86_64 I'm running right no=
w. The
> > > simple python script available here allows to see it quite easily=
 :
> > > https://www.redhat.com/archives/rhelv5-list/2009-February/msg0016=
6.html
> > >=20
> > >  * I run the script on my Workstation, I have an FTP server enabl=
ed
> > >  * I download a DVD ISO from a remote workstation : The values ma=
tch
> > >  * I start ping floods from remote workstations : The values repo=
rted
> > >    by /proc are much higher than the ones reported by tcpdump. I =
used
> > >    "ping -s 500 -f myworkstation" from two remote workstations
> > >=20
> > > If there's anything flawed in my debugging, I'd love to have some=
one
> > > point it out to me. TIA to anyone willing to have a look.
> > >=20
> > > Matthias
> > >=20
> >=20
> > I could not reproduce this here... what kind of NIC are you using o=
n
> > affected systems ? Some ethernet drivers report stats from card its=
elf,
> > and I remember seeing some strange stats on some hardware, but I ca=
nnot
> > remember which one it was (we were reading NULL values instead of
> > real ones, once in a while, maybe it was a firmware issue...)
>=20
> My workstation has a Broadcom BCM5752 (tg3 module). The servers which
> are most affected have Intel 82571EB (e1000e). But the issue is that
> with /proc, the values are a lot _higher_ than with tcpdump, and the
> tcpdump values seem to be the correct ones.

the e1000 chip reports stats every 2 seconds. So you have to collect
stats every 2 seconds otherwise you get "camel-looking" stats.

Willy
