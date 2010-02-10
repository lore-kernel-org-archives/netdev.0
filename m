From: Tiago Pierezan Camargo <tcamargo@gmail.com>
Subject: Re: Problem with VLANs and via-velocity driver
Date: Wed, 10 Feb 2010 16:43:37 +0000 (UTC)
Message-ID: <loom.20100210T171704-457@post.gmane.org>
References: <20091113033217.GQ838@cubit> <4AFCFF67.3060802@trash.net> <20091116005750.GR838@cubit>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from lo.gmane.org ([80.91.229.12]:45372 "EHLO lo.gmane.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754943Ab0BJQpI (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 10 Feb 2010 11:45:08 -0500
Received: from list by lo.gmane.org with local (Exim 4.69)
	(envelope-from <linux-netdev-2@m.gmane.org>)
	id 1NfFgX-0007US-8b
	for netdev@vger.kernel.org; Wed, 10 Feb 2010 17:45:05 +0100
Received: from 189-74-249-213.paemt702.e.brasiltelecom.net.br ([189-74-249-213.paemt702.e.brasiltelecom.net.br])
        by main.gmane.org with esmtp (Gmexim 0.1 (Debian))
        id 1AlnuQ-0007hv-00
        for <netdev@vger.kernel.org>; Wed, 10 Feb 2010 17:45:05 +0100
Received: from tcamargo by 189-74-249-213.paemt702.e.brasiltelecom.net.br with local (Gmexim 0.1 (Debian))
        id 1AlnuQ-0007hv-00
        for <netdev@vger.kernel.org>; Wed, 10 Feb 2010 17:45:05 +0100
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

> Kevin Shanahan <kmshanah <at> disenchant.net> writes:

Hi
Sorry for resurrecting an old thread, but I'm having the same problem h=
ere.

> On Fri, Nov 13, 2009 at 07:40:39AM +0100, Patrick McHardy wrote:
> > Kevin Shanahan wrote:
> > > Hi,
> > >=20
> > > I've had some problems with getting a fairly simple (I thought) V=
LAN
> > > configuration working with the on board Via NICs on my Via M700
> > > board. Looks like as soon as a tagged VLAN interface is added, th=
e
> > > underlying "raw" (untagged) interface stops responding.

My setup is a bit different: I want to sniff all network activity, incl=
uding
possible tagged traffic. No tagged interfaces are created.

> > > A bit of searching found a few references to similar problems goi=
ng
> > > back a few years (2005, 2007). Sounded like there were some drive=
r
> > > issues, but it wasn't clear from the messages I found whether the=
y
> > > were believed to be fixed or not. I tried the same test using a
> > > differnt NIC with the tg3 driver and there were no problems, so i=
t
> > > looks to me like it's still a via-velocity issue. Unfortunately I
> > > don't have room to add NICs to this machine and need to use the o=
n
> > > board Via hardware.
> >=20
> > There's some special-casing for VID 0 in velocity_init_cam_filter()=
=2E
> > Does "ip link add link eth0 type vlan id 0" make any difference?
>=20
> Thanks Patrick, this command got the untagged interface working again
> (eth1 in my case). I can use this as a work around.

Unfortunately, Patrick's workaround doesn't work for me. To see any tag=
ged
packet I need to create a vlan that matches the packet vlan (same id).

R=C3=A9gis' promiscous mode patch (http://lists.openwall.net/netdev/200=
8/10/08/106)
does not work either. I tried to completely disable hw vlan filtering w=
ithout
success. It seems my board uses a different register/offset to disable =
filtering.

06:0a.0 0200: 1106:3119 (rev 11)
        Subsystem: 1106:0110
        Control: I/O+ Mem+ BusMaster- SpecCycle- MemWINV+ VGASnoop- Par=
Err-
Stepping- SERR- FastB2B- DisINTx-
        Status: Cap+ 66MHz+ UDF- FastB2B- ParErr- DEVSEL=3Dmedium >TAbo=
rt-
<TAbort- <MAbort- >SERR- <PERR- INTx-
        Interrupt: pin A routed to IRQ 16
        Region 0: I/O ports at e000 [size=3D256]
        Region 1: Memory at fbfff400 (32-bit, non-prefetchable) [size=3D=
256]
        Capabilities: [50] Power Management version 2
                Flags: PMEClk- DSI- D1+ D2+ AuxCurrent=3D0mA
PME(D0+,D1+,D2+,D3hot+,D3cold+)
                Status: D3 NoSoftRst- PME-Enable- DSel=3D0 DScale=3D0 P=
ME-
        Kernel driver in use: via-velocity
        Kernel modules: via-velocity

Any suggestions?

Thanks!

- Tiago

