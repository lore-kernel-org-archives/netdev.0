From: "Fischer, Anna" <anna.fischer@hp.com>
Subject: RE: [PATCH][RFC] net/bridge: add basic VEPA support
Date: Wed, 12 Aug 2009 14:32:32 +0000
Message-ID: <0199E0D51A61344794750DC57738F58E6D6AE9A0C1@GVW1118EXC.americas.hpqcorp.net>
References: <0199E0D51A61344794750DC57738F58E67D2DCECBB@GVW1118EXC.americas.hpqcorp.net>
 <0199E0D51A61344794750DC57738F58E6D6AE99C53@GVW1118EXC.americas.hpqcorp.net>
 <001001ca1a93$b6e50ee0$24af2ca0$@edu> <200908121519.36808.arnd@arndb.de>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 8BIT
Cc: "Paul Congdon (UC Davis)" <ptcongdon@ucdavis.edu>,
	'Stephen Hemminger' <shemminger@linux-foundation.org>,
	"bridge@lists.linux-foundation.org"
	<bridge@lists.linux-foundation.org>,
	"linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"virtualization@lists.linux-foundation.org"
	<virtualization@lists.linux-foundation.org>,
	"evb@yahoogroups.com" <evb@yahoogroups.com>,
	"davem@davemloft.net" <davem@davemloft.net>,
	"kaber@trash.net" <kaber@trash.net>,
	"adobriyan@gmail.com" <adobriyan@gmail.com>,
	'Eric Biederman' <ebiederm@xmission.com>
To: Arnd Bergmann <arnd@arndb.de>
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S1753187AbZHLOcv@vger.kernel.org>
In-Reply-To: <200908121519.36808.arnd@arndb.de>
Content-Language: en-US
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

> Subject: Re: [PATCH][RFC] net/bridge: add basic VEPA support
> 
> On Tuesday 11 August 2009, Paul Congdon (UC Davis) wrote:
> > > >
> > > > The patch from Eric Biederman to allow macvlan to bridge between
> > > > its slave ports is at
> > > >
> > > > http://kerneltrap.org/mailarchive/linux-netdev/2009/3/9/5125774
> > >
> > > Looking through the discussions here, it does not seem as if a
> decision
> > > was made to integrate those patches, because they would make the
> > > macvlan interface behave too much like a bridge.
> 
> Right, that question is still open, and dont't see it as very important
> right now, as long as we can still use it for VEPA.

Yes, for the basic VEPA this is not important. For MultiChannel VEPA, it 
would be nice if a macvlan device could operate as VEPA and as a typical
VEB (VEB = traditional bridge but no learning).
 
Basically, what we would need to be able to support is running a VEB and
a VEPA simultaneously on the same uplink port (e.g. the physical device). 
A new component (called the S-Component) would then multiplex frames
to the VEB or the VEPA based on a tagging scheme.

I could see this potentially working with macvlan, if it can operate in
both VEPA and VEB mode. But you are right that for basic VEPA, it would 
not be an immediate requirement.


> > Also, is there a solution, or plans for a solution, to address
> macvtap
> > interfaces that are set to 'promiscuous' mode?  It would seem fairly
> easy to
> > support this for interfaces that are simply trying to listen to the
> port
> > (e.g. Wireshark).
> 
> If you want to use tcpdump or wireshark on all ports simulateously in a
> pure
> VEPA, you can still attach it to the 'lowerdev', e.g. eth0 or eth0.2
> (for macvlan
> nested in vlan).
> If we allow bridge ports, we might want to extend the local delivery
> to also go through all the hooks of the external port, so that you can
> attach packet sockets there.

I think the question here was whether there is a way for a macvlan interface
to be set to promiscuous mode. At the moment, I believe a macvlan interface
only receives packets based on its destination address (this is for unicast
packets now). What if a macvlan interface wanted to get all packets that
are being received (either on the physical device, or on a particular
VLAN if using macvlan nested in vlan). Would this work easily? Imagine
you have a virtual machine attached to that macvlan / macvtap device and
this VM wants to do packet inspection or network traffic monitoring on 
all packets flowing through the virtualized server.
 
Anna
