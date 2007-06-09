From: "Leonid Grossman" <Leonid.Grossman@neterion.com>
Subject: RE: [PATCH] NET: Multiqueue network device support.
Date: Sat, 9 Jun 2007 10:58:38 -0400
Message-ID: <78C9135A3D2ECE4B8162EBDCE82CAD7701B7D69C@nekter>
References: <1181168020.4064.46.camel@localhost> <D5C1322C3E673F459512FB59E0DDC32902FC61BF@orsmsx414.amr.corp.intel.com>
Mime-Version: 1.0
Content-Type: text/plain;
	charset="us-ascii"
Content-Transfer-Encoding: 8BIT
Cc: <davem@davemloft.net>, <netdev@vger.kernel.org>, <jeff@garzik.org>,
	"Kok, Auke-jan H" <auke-jan.h.kok@intel.com>,
	"Ramkrishna Vepa" <Ramkrishna.Vepa@neterion.com>,
	"Alex Aizman" <aaizman@neterion.com>
To: "Waskiewicz Jr, Peter P" <peter.p.waskiewicz.jr@intel.com>,
	<hadi@cyberus.ca>, "Patrick McHardy" <kaber@trash.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx.neterion.com ([72.1.205.142]:40852 "EHLO owa.neterion.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752874AbXFIPLd convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 9 Jun 2007 11:11:33 -0400
Content-class: urn:content-classes:message
In-Reply-To: <D5C1322C3E673F459512FB59E0DDC32902FC61BF@orsmsx414.amr.corp.intel.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org



> -----Original Message-----
> From: netdev-owner@vger.kernel.org [mailto:netdev-
> owner@vger.kernel.org] On Behalf Of Waskiewicz Jr, Peter P
> Sent: Wednesday, June 06, 2007 3:31 PM
> To: hadi@cyberus.ca; Patrick McHardy
> Cc: davem@davemloft.net; netdev@vger.kernel.org; jeff@garzik.org; Kok,
> Auke-jan H
> Subject: RE: [PATCH] NET: Multiqueue network device support.
> 
> > [Which of course leads to the complexity (and not optimizing
> > for the common - which is single ring NICs)].
> 
> The common for 100 Mbit and older 1Gbit is single ring NICs.  Newer
> PCI-X and PCIe NICs from 1Gbit to 10Gbit support multiple rings in the
> hardware, and it's all headed in that direction, so it's becoming the
> common case.

IMHO, in addition to current Intel and Neterion NICs, some/most upcoming
NICs are likely to be multiqueue, since virtualization emerges as a
major driver for hw designs (there are other things of course that drive
hw, but these are complimentary to multiqueue).

PCI-SIG IOV extensions for pci spec are almost done, and a typical NIC
(at least, typical 10GbE NIC that supports some subset of IOV) in the
near future is likely to have at least 8  independent channels with its
own tx/rx queue, MAC address, msi-x vector(s), reset that doesn't affect
other channels, etc.

Basically, each channel could be used as an independent NIC that just
happens to share pci bus and 10GbE PHY with other channels (but has
per-channel QoS and throughput guarantees).

In a non-virtualized system, such NICs could be used in a mode when each
channel runs on one core; this may eliminate some locking...  This mode
will require btw deterministic session steering, current hashing
approach in the patch is not sufficient; this is something we can
contribute once Peter's code is in. 
In general, a consensus on kernel support for multiqueue NICs will be
beneficial since multiqueue HW is here and other stacks already taking
advantage of it. 
