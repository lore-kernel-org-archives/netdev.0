From: Laurent DENIEL <laurent.deniel@thalesatm.com>
Subject: Re: [Bonding-devel] Re: [SET 2][PATCH 2/8][bonding] Propagating
 master'ssettings toslaves
Date: Tue, 12 Aug 2003 16:36:40 +0200
Sender: netdev-bounce@oss.sgi.com
Message-ID: <3F38FB78.4536593A@thalesatm.com>
References: <E791C176A6139242A988ABA8B3D9B38A014C9474@hasmsx403.iil.intel.com>
		 <200308111720.38472.shmulik.hen@intel.com>
		 <1060612481.1034.15.camel@jzny.localdomain>
		 <200308111925.38278.shmulik.hen@intel.com> <3F37C7C3.7070807@pobox.com>
		 <3F37D2ED.B4B9223C@thalesatm.com> <3F37D5BF.8000702@pobox.com>
		 <3F3889C7.1B4EC2BE@thalesatm.com>
		 <1060693157.1027.87.camel@jzny.localdomain>
		 <20030812060845.0e0ba2e8.davem@redhat.com>
		 <3F38F569.C1EC7769@thalesatm.com> <1060698412.1063.7.camel@jzny.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Transfer-Encoding: quoted-printable
Cc: "David S. Miller" <davem@redhat.com>, jgarzik@pobox.com,
   shmulik.hen@intel.com, bonding-devel@lists.sourceforge.net,
   netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: hadi@cyberus.ca
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

jamal a =E9crit :
>=20
> On Tue, 2003-08-12 at 10:10, Laurent DENIEL wrote:
> > "David S. Miller" a =E9crit :
>=20
> > That's why in really *safe* systems, we do not use routing daemon
> > but only static routes ;-)
> >
> > And there is a BIG difference :
> >
> > When user level daemon dies, you have to be sure that some stuff
> > exists to monitor and recover from that situation (either by
> > restarting the faulty deamon (if it could recover in time which
> > I doubt with the bonding case), or by switching to a new machine
> > in a fault tolerant configuration). With kernel ooops, there is
> > NOTHING to do in such in such a fault tolerant systems, since the
> > machine is unusable (this is the same as a hardware failure).
> >
> > But people does not understand the constraints of really safe
> > systems.
> >
>=20
> We have hardware watchdog timers to put the kernel into a known state b=
y
> rebooting. If you were not aware of all these RAS efforts on Linux
> (projects like kexec for example) I suggest you start looking at them.

I am aware of this great stuff but see below.

> The kernel will oops and the app will die because of one thing: _A
> software bug_. It doesnt matter what causes the death of the kernel or
> app ( a misconfig for example causing a broadcast loop making the app
> die is a bug).
> If you want a safe system then you donot trust software neither do you
> trust hardware - You must have workarounds incase they go beserk. Heck
> the only entity you should trust is God and thats assuming you believe
> in God.

Hardware / software watchdogs are great but do not necessarily=20
solve all problems especially where timing constraints are important.
I prefer to rely on the timing of the bonding kernel code to switch
NIC in milli seconds that to wait seconds or minutes that a user space
daemon have the hand to handle the problem (and yes, I am aware of=20
real time class scheduling and so on, but you say don't trust the=20
software, and I agree so I prefer a direct kernel hang than nothing=20
or something too late (software watchdog will not help in that case).

Laurent
