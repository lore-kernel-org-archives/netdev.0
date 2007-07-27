From: "Kok, Auke" <auke-jan.h.kok@intel.com>
Subject: RFC/Progress update: e1000e pci-express -only e1000 driver
Date: Fri, 27 Jul 2007 14:12:24 -0700
Message-ID: <46AA5FB8.9090600@intel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Arjan van de Ven <arjan@linux.intel.com>,
	"Ronciak, John" <john.ronciak@intel.com>
To: Jeff Garzik <jgarzik@pobox.com>, NetDev <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga02.intel.com ([134.134.136.20]:52685 "EHLO mga02.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S934495AbXG0VM2 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 27 Jul 2007 17:12:28 -0400
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


All,

Here's a short update on progress with e1000e, the future pci-express -only 
version of the current e1000 driver. Since about a month ago, a lot has changed 
so I'd like to keep everyone posted on progress and solicit ideas.

What happened since I posted "e1000new" ? Here's a summary:

* e1000new was renamed to e1000e and all non-pcie hardware support was dropped 
from this driver (all 8254* chipsets).
* after this stage, I removed all code that handled the flags (32 or so) that 
are no longer used or obsolete since they are always enabled (e.g. all devices 
have msi)
* Removed non-essential module parameters (e.g. speed, duplex, flowcontrol)
* Removed all multi-queue code
* Filtered all unused macro's and define's out (about 700 or so)
* converted the bitfields into other flag types
* filtered out unreached code (for non-supported phy types, bus types in the 
pci-e adapters)

Please note that I'm basically coding e1000e for all pcie adapters, but the 
first merge will only enable ich9 devices (by masking the device IDs). This will 
allow me to develop the code with an eye on all devices and structure, while not 
removing code that we might need later anyway.

After that the main issue is the internal API. I've started to give it a diet 
mainly for two reasons:

1) lots of obfuscating wrappers and indirection
2) once I remove the lot of those where possible, things should become a bit 
more clear where we can go since it's going to be more easy to find the cases we 
can eliminate or cleanup.

I'm now at this phase and still working on it, so this is all major work in 
progress.

Since this obviously is going to take me more time, I hope to post these updates 
every two weeks or so, so people can give the driver a try (it's largely 
untested of course) and review the direction that I'm headed in.

The patches are available on http:

     http://foo-projects.org/~sofar/e1000e-1.patch      [585k]
     http://foo-projects.org/~sofar/e1000e-1.patch.bz2  [93k]


Feel free to suggest and comment. Better now then later ;)

Cheers,

Auke


