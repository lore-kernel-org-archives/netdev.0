From: Grant Likely <grant.likely@secretlab.ca>
Subject: Re: [RFC v2] virtio: add virtio-over-PCI driver
Date: Tue, 14 Apr 2009 16:16:34 -0600
Message-ID: <fa686aa40904141516s1ca2965fted07bf2a6f5ce390@mail.gmail.com>
References: <20090224000002.GA578@ovro.caltech.edu> <fa686aa40904141328oa57fb1bsffd0549a52eca90@mail.gmail.com>
	<49E4FED0.1020003@ovro.caltech.edu> <fa686aa40904141445x6a125e12r391e0853d89baf72@mail.gmail.com>
	<49E505B3.5070005@ovro.caltech.edu>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Ira Snyder <iws@ovro.caltech.edu>, Arnd Bergmann <arnd@arndb.de>,
	Jan-Bernd Themann <THEMANN@de.ibm.com>, netdev@vger.kernel.org,
	Rusty Russell <rusty@rustcorp.com.au>,
	linux-kernel@vger.kernel.org, linuxppc-dev@ozlabs.org
To: David Hawkins <dwh@ovro.caltech.edu>
Return-path: <netdev-owner@vger.kernel.org>
Received: from rv-out-0506.google.com ([209.85.198.229]:24540 "EHLO
	rv-out-0506.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750982AbZDNWQu convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 14 Apr 2009 18:16:50 -0400
In-Reply-To: <49E505B3.5070005@ovro.caltech.edu>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, Apr 14, 2009 at 3:52 PM, David Hawkins <dwh@ovro.caltech.edu> w=
rote:
> Hi Grant,
>
>> Thanks David. =A0I haven't looked closely at the xilinx pci data she=
et
>> yet, but I don't expect too many issues in this area. =A0As you say,=
 it
>> won't take much to code it up. =A0I'll be poking my VHDL engineer to
>> make it do what I want it to. =A0:-)
>
> The key aspects of the core will be that it is Master/Target
> so that it can take over the PCI bus, and that it has a
> DMA engine that can take care of most of the work. In
> your case, since you have a DMA controller on the host
> (MPC5200) and the target (Xilinx), your driver might end
> up having nicer symmetry than our application. The
> most efficient implementation will be the one that
> uses PCI writes, i.e., MPC5200 DMAs to the Xilinx core,
> and the Xilinx core DMAs to the MPC5200.

Hmmm, I hadn't thought about this.  I was intending to use the
Virtex's memory region for all virtio, but if I can allocate memory
regions on both sides of the PCI bus, then that may be best.

> If you use
> a PCI Target only core, then the MPC5200 DMA controller
> will have to do all the work, and read transfers might
> be slightly less efficient.

I'll definitely intend to enable master mode on the Xilinx PCI controll=
er.

> Our target boards (PowerPC) live in compactPCI backplanes
> and talk to x86 boards that do not have DMA controllers.
> So the PCI target board DMA controllers are used to
> transfer data efficiently to the x86 host (writes)
> and less efficiently from the host to the boards
> (reads). Our bandwidth requirements are 'to the host',
> so we can live with the asymmetry in performance.

=46ortunately I don't have very high bandwidth requirements for the
first spin, so I have some room to experiment.  :-)

g.

--=20
Grant Likely, B.Sc., P.Eng.
Secret Lab Technologies Ltd.
