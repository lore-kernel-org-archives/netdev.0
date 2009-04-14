From: David Hawkins <dwh@ovro.caltech.edu>
Subject: Re: [RFC v2] virtio: add virtio-over-PCI driver
Date: Tue, 14 Apr 2009 14:52:51 -0700
Message-ID: <49E505B3.5070005@ovro.caltech.edu>
References: <20090224000002.GA578@ovro.caltech.edu> <fa686aa40904141328oa57fb1bsffd0549a52eca90@mail.gmail.com> 	<49E4FED0.1020003@ovro.caltech.edu> <fa686aa40904141445x6a125e12r391e0853d89baf72@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Ira Snyder <iws@ovro.caltech.edu>, Arnd Bergmann <arnd@arndb.de>,
	Jan-Bernd Themann <THEMANN@de.ibm.com>, netdev@vger.kernel.org,
	Rusty Russell <rusty@rustcorp.com.au>,
	linux-kernel@vger.kernel.org, linuxppc-dev@ozlabs.org
To: Grant Likely <grant.likely@secretlab.ca>
Return-path: <netdev-owner@vger.kernel.org>
Received: from ovro.ovro.caltech.edu ([192.100.16.2]:44299 "EHLO
	ovro.ovro.caltech.edu" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751630AbZDNVwu (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 14 Apr 2009 17:52:50 -0400
In-Reply-To: <fa686aa40904141445x6a125e12r391e0853d89baf72@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi Grant,

> Thanks David.  I haven't looked closely at the xilinx pci data sheet
> yet, but I don't expect too many issues in this area.  As you say, it
> won't take much to code it up.  I'll be poking my VHDL engineer to
> make it do what I want it to.  :-)

The key aspects of the core will be that it is Master/Target
so that it can take over the PCI bus, and that it has a
DMA engine that can take care of most of the work. In
your case, since you have a DMA controller on the host
(MPC5200) and the target (Xilinx), your driver might end
up having nicer symmetry than our application. The
most efficient implementation will be the one that
uses PCI writes, i.e., MPC5200 DMAs to the Xilinx core,
and the Xilinx core DMAs to the MPC5200. If you use
a PCI Target only core, then the MPC5200 DMA controller
will have to do all the work, and read transfers might
be slightly less efficient.

Our target boards (PowerPC) live in compactPCI backplanes
and talk to x86 boards that do not have DMA controllers.
So the PCI target board DMA controllers are used to
transfer data efficiently to the x86 host (writes)
and less efficiently from the host to the boards
(reads). Our bandwidth requirements are 'to the host',
so we can live with the asymmetry in performance.

> I'll keep you up to date on my progress.

Sounds good.

Cheers,
Dave
