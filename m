From: "Brandeburg, Jesse" <jesse.brandeburg@intel.com>
Subject: RE: [PATCH] e1000: Fix for 32 bits platforms with 64 bits resources
Date: Wed, 28 Nov 2007 10:47:17 -0800
Message-ID: <36D9DB17C6DE9E40B059440DB8D95F5203DF7871@orsmsx418.amr.corp.intel.com>
References: <20071116073821.548CCDDDF4@ozlabs.org>
Mime-Version: 1.0
Content-Type: text/plain;
	charset="us-ascii"
Content-Transfer-Encoding: 8BIT
Cc: <netdev@vger.kernel.org>, <linuxppc-dev@ozlabs.org>,
	"Jeff Garzik" <jeff@garzik.org>
To: "Benjamin Herrenschmidt" <benh@kernel.crashing.org>,
	"Kok, Auke-jan H" <auke-jan.h.kok@intel.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga11.intel.com ([192.55.52.93]:15764 "EHLO mga11.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1750878AbXK1SrS convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 28 Nov 2007 13:47:18 -0500
Content-class: urn:content-classes:message
In-Reply-To: <20071116073821.548CCDDDF4@ozlabs.org>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Benjamin Herrenschmidt wrote:
> The e1000 driver stores the content of the PCI resources into
> unsigned long's before ioremapping. This breaks on 32 bits
> platforms that support 64 bits MMIO resources such as ppc 44x.
> 
> This fixes it by removing those temporary variables and passing
> directly the result of pci_resource_start/len to ioremap.

the patch is mostly fine, but looking through the tree, doesn't every
driver that has 64 bit capable resources have this problem?

in fact, skeleton module has this problem, if I'm not mistaken.  e1000
isn't the only one. :-)
 
> The side effect is that I removed the assignments to the netdev
> fields mem_start, mem_end and base_addr, which are totally useless
> for PCI devices.

also, concerning this, ifconfig shows the output of these variables, I
don't think we want to blatantly remove them, as it is actually removing
information that is, if not used, at least displayed to user space.

eth6      Link encap:Ethernet  HWaddr 00:0E:01:0C:02:03
          inet addr:134.134.3.121  Bcast:134.134.3.255
Mask:255.255.255.0
          inet6 addr: fe80::20e:1ff:fe0c:203/64 Scope:Link
          UP BROADCAST NOTRAILERS RUNNING MULTICAST  MTU:1500  Metric:1
          RX packets:9022519 errors:0 dropped:0 overruns:0 frame:0
          TX packets:1303701 errors:0 dropped:0 overruns:0 carrier:0
          collisions:0 txqueuelen:1000
          RX bytes:4044613454 (3857.2 Mb)  TX bytes:118365109 (112.8 Mb)
          Base address:0xf000 Memory:feac0000-feae0000
                                     ^^^^^^^^^^^^^^^^^
