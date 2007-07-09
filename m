From: "Kok, Auke" <auke-jan.h.kok@intel.com>
Subject: Re: Splitting e1000 (Was: Re: e1000: backport ich9 support from 7.5.5
 ?)
Date: Mon, 09 Jul 2007 13:46:51 -0700
Message-ID: <46929EBB.3000809@intel.com>
References: <46857C08.4030303@intel.com>	<20070629150350.414553d4.akpm@linux-foundation.org>	<4685838D.9080108@garzik.org>	<c0a09e5c0706291657kd5e4baawb113a17ca5ab2191@mail.gmail.com>	<46859F3F.305@garzik.org>	<4685C09B.7040908@intel.com>	<20070630082520.GA20140@infradead.org>	<468AD23A.4090904@intel.com>	<468D8B32.9020305@garzik.org>	<468EDAF9.3020606@intel.com>	<20070707190431.GA26341@electric-eye.fr.zoreil.com>	<46900B83.1060902@intel.com> <20070707183244.19d21893@freepuppy.rosehill.hemminger.net> <469110F6.2030902@linux.intel.com> <4691279C.8030603@garzik.org> <46914382.8090801@linux.intel.com> <469280F5.8000909@garzik.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Arjan van de Ven <arjan@linux.intel.com>,
	"Kok, Auke" <auke-jan.h.kok@intel.com>,
	Stephen Hemminger <shemminger@linux-foundation.org>,
	Francois Romieu <romieu@fr.zoreil.com>,
	Christoph Hellwig <hch@infradead.org>,
	Andrew Grover <andy.grover@gmail.com>,
	Andrew Morton <akpm@linux-foundation.org>,
	e1000-devel@lists.sourceforge.net, netdev@vger.kernel.org,
	"Ronciak, John" <john.ronciak@intel.com>,
	"David S. Miller" <davem@davemloft.net>,
	Andy Gospodarek <andy@greyhouse.net>
To: Jeff Garzik <jeff@garzik.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga02.intel.com ([134.134.136.20]:27173 "EHLO mga02.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754962AbXGIUrB (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 9 Jul 2007 16:47:01 -0400
In-Reply-To: <469280F5.8000909@garzik.org>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Jeff Garzik wrote:
> Ignoring small potatoes, the merge stoppers in my mind are:
> 
> 1) Transition plan.  I strongly oppose switching all e1000 users en 
> masse to a new driver, especially so soon.  Flag day transitions to 
> unproven drivers suck.  Defaults don't work:  users use the old driver 
> until the default changes, which means the new driver gets little field 
> testing.
> 
> Regardless of my opinion of old-e1000 maintainability, top priority is 
> to keep users running on a stable driver until new driver is stable.  I 
> would propose merging a new driver with only the PCI IDs not already in 
> the kernel, get that stable, then consider moving the rest of the 
> PCI-Express PCI IDs (or others?).

I would strongly vote for taking a stripped down e1000new then, mask out all the 
pci id's except ich9, remove all code for pre-pci-e silicon and remove the most 
annoying and needlessly complexing code like the semi-implemented multiqueue 
code that is in there.

How we are going to improve the internal api then can subsequently be done 
upstream in steps: implement using phylib, reorganize the code. This would give 
the community a view on the progress.

I fear that if I spend yet another 2 months offline working on making a minimal 
ich9 driver I will lose even more time and patience: Even though the current 
driver (with pre-pci-e stripped) might not be as nice as you want, at least we 
can work together on it. I would rather go with something I know that works, 
isn't too bad, and we have time and start reviewing upstream immediately.

> 2) Internal API.  An "it can do anything" API is a hint that the driver 
> should be structured differently.  Perhaps a divorce between pre-PCIe 
> and PCIe will help things (or 8257x vs other?).  I tend to think that 
> both e1000 and e1000new could be cleaned up substantially by such a 
> split.  Also, specifically for PHYs, we already have a phy layer that 
> can be used a focal point for PHY modularity.

Agreed. All current e1000 pci-e hardware is based on the same mac, so it's the 
logical split. The differences are PHYs and manageability, but the interface is 
rather similar throughout, as well as features.

> Overall, within minor chip revs you'll probably create standard 
> branches.  But within major chip revs, you really should be looking at 
> separate code paths rather than trying to shoehorn a wide variety of 
> chips down the same (highly modular!) hot path.  That slows down 
> everybody to the same speed (least common denominator), and makes it 
> more difficult to follow the code path for a single chip.

looking at this with respect to e1000e (a pci-e only e1000 driver) - this would 
make perfect sense: most of the irq and rx/tx paths are identical across the 
board. So this confirms IMO that we should not split beyond this.


Auke
