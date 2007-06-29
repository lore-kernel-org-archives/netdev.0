From: "Kok, Auke" <auke-jan.h.kok@intel.com>
Subject: RFR: New e1000 driver (e1000new), was: Re: e1000: backport ich9 support
 from 7.5.5 ?
Date: Fri, 29 Jun 2007 16:24:39 -0700
Message-ID: <468594B7.6070309@intel.com>
References: <1183138159.17243.16.camel@blaa>	<20070629175006.GB3917@falooley.org>	<468571C6.3090305@garzik.org>	<46857C08.4030303@intel.com> <20070629150350.414553d4.akpm@linux-foundation.org> <4685838D.9080108@garzik.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Jeff Garzik <jeff@garzik.org>,
	Andrew Morton <akpm@linux-foundation.org>,
	Jason Lunz <lunz@reflexsecurity.com>,
	Mark McLoughlin <markmc@redhat.com>,
	e1000-devel@lists.sourceforge.net,
	Arjan van de Ven <arjan@linux.intel.com>,
	"Ronciak, John" <john.ronciak@intel.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga01.intel.com ([192.55.52.88]:28944 "EHLO mga01.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753457AbXF2XYq (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 29 Jun 2007 19:24:46 -0400
In-Reply-To: <4685838D.9080108@garzik.org>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Jeff Garzik wrote:
> Andrew Morton wrote:
>> On Fri, 29 Jun 2007 14:39:20 -0700
>> "Kok, Auke" <auke-jan.h.kok@intel.com> wrote:
>>
>>> That's why we want to introduce a second e1000 driver (named differently, pick 
>>> any name) that contains the new code base, side-by-side into the kernel with the 
>>> current e1000.
>> Sounds like a reasonable approach to me (it has plenty of precedent).  But
>> I forget what all the other issues were, so ignore me.
> 
> Given past history with duplicate drivers and the problems that they 
> cause -- I know, I've caused some of those problems :( -- I strongly 
> recommend against when it can be avoided.
> 
> Leaving e1000 with current hardware, and a new e1001 for newer hardware 
> should be easier to manage for all involved, without the headaches that 
> duplicate drivers cause.
> 
> An "e1001" approach also means we have a much greater chance of 
> encouraging Intel down the path of clean driver-ness.

ok, FWIW, here is this new driver:


I've posted this new driver (currently called "e1000new") on my git tree:

    git-pull git://lost.foo-projects.org/~ahkok/git/netdev-2.6 e1000new

It contains a single git-commit with the following content (on top of current 
master branch from Jeff's netdev tree):

---
commit d2ec375736ac23a3432534112e0f8fc172ee9db4
Author: Auke Kok <auke-jan.h.kok@intel.com>
Date:   Fri Jun 29 15:48:04 2007 -0700

     e1000new: new e1000 driver for current e1000 hardware

     This driver is a cleaned up version of the current e1000 driver. It
     introduces a fully rewritten abstraction between MAC, PHY, NVM
     and other low-level hardware features such as manageability. Per-
     hardware family specific code.

     Mac type checks are almost completely eliminated and replaced with
     hardware feature/issue or capability flags. This allows us much
     easier going forward to add new hardware support or debug issues.

     Finally, the driver structures were reorganized and restructured
     to align better and remove holes. tx and rx structures are now
     basically the same and simplify setup code etc.

     Signed-off-by: Auke Kok <auke-jan.h.kok@intel.com>

:100644 100644 7d57f4a... 0bad8f3... M  drivers/net/Kconfig
:100644 100644 a77affa... 0b58e78... M  drivers/net/Makefile
:000000 100644 0000000... 5bdf481... A  drivers/net/e1000new/80003es2lan.c
:000000 100644 0000000... f139050... A  drivers/net/e1000new/80003es2lan.h
:000000 100644 0000000... 1279521... A  drivers/net/e1000new/82540.c
:000000 100644 0000000... dc20510... A  drivers/net/e1000new/82541.c
:000000 100644 0000000... 5fab7ff... A  drivers/net/e1000new/82541.h
:000000 100644 0000000... e18a1be... A  drivers/net/e1000new/82542.c
:000000 100644 0000000... dad89ae... A  drivers/net/e1000new/82543.c
:000000 100644 0000000... 6d14aba... A  drivers/net/e1000new/82543.h
:000000 100644 0000000... 3283841... A  drivers/net/e1000new/82571.c
:000000 100644 0000000... 5912f47... A  drivers/net/e1000new/82571.h
:000000 100644 0000000... 703d938... A  drivers/net/e1000new/Makefile
:000000 100644 0000000... 2de032e... A  drivers/net/e1000new/api.c
:000000 100644 0000000... e429f8c... A  drivers/net/e1000new/api.h
:000000 100644 0000000... 59f34db... A  drivers/net/e1000new/defines.h
:000000 100644 0000000... 71b775d... A  drivers/net/e1000new/e1000.h
:000000 100644 0000000... 803ed2c... A  drivers/net/e1000new/ethtool.c
:000000 100644 0000000... 848debc... A  drivers/net/e1000new/hw.h
:000000 100644 0000000... e5adbff... A  drivers/net/e1000new/ich8lan.c
:000000 100644 0000000... 557858f... A  drivers/net/e1000new/ich8lan.h
:000000 100644 0000000... 8f589a3... A  drivers/net/e1000new/mac.c
:000000 100644 0000000... 075e326... A  drivers/net/e1000new/mac.h
:000000 100644 0000000... 3b6f6bc... A  drivers/net/e1000new/main.c
:000000 100644 0000000... e5fee2e... A  drivers/net/e1000new/manage.c
:000000 100644 0000000... 27606ea... A  drivers/net/e1000new/manage.h
:000000 100644 0000000... 2c9ccb4... A  drivers/net/e1000new/nvm.c
:000000 100644 0000000... e59c8ad... A  drivers/net/e1000new/nvm.h
:000000 100644 0000000... 3c943f1... A  drivers/net/e1000new/param.c
:000000 100644 0000000... 45338ef... A  drivers/net/e1000new/phy.c
:000000 100644 0000000... 957957d... A  drivers/net/e1000new/phy.h
:000000 100644 0000000... 669ad03... A  drivers/net/e1000new/regs.h
---


You can also get it through http:

http://foo-projects.org/~sofar/e1000new.patch      [883KB]
http://foo-projects.org/~sofar/e1000new.patch.bz2  [121KB]

Unfortunately it's too big to send directly to the list.

While I understand everyone's reservation for going a certain course forward, I 
would really appreciate it if people would review this driver and give it 
attention. Any feedback is appreciated, and whatever course we might end up 
going, can be used.

Thanks,

Auke
