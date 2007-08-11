From: Michael Buesch <mb@bu3sch.de>
Subject: Re: [PATCH] b44-ssb: Fix the SSB dependency hell
Date: Sat, 11 Aug 2007 11:36:46 +0200
Message-ID: <200708111136.46781.mb@bu3sch.de>
References: <200708110208.21624.mb@bu3sch.de> <1186793856.4862.16.camel@johannes.berg> <20070811014111.GB22213@stusta.de>
Mime-Version: 1.0
Content-Type: text/plain;
  charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: Johannes Berg <johannes@sipsolutions.net>,
	John Linville <linville@tuxdriver.com>,
	Andrew Morton <akpm@linux-foundation.org>,
	Linux Netdev List <netdev@vger.kernel.org>
To: Adrian Bunk <bunk@stusta.de>
Return-path: <netdev-owner@vger.kernel.org>
Received: from static-ip-62-75-166-246.inaddr.intergenia.de ([62.75.166.246]:32795
	"EHLO vs166246.vserver.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751123AbXHKJip (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 11 Aug 2007 05:38:45 -0400
In-Reply-To: <20070811014111.GB22213@stusta.de>
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Saturday 11 August 2007 03:41:11 Adrian Bunk wrote:
> On Sat, Aug 11, 2007 at 02:57:36AM +0200, Johannes Berg wrote:
> > On Sat, 2007-08-11 at 02:43 +0200, Adrian Bunk wrote:
> > 
> > > -ENOMENUCONFIGPATCH
> > 
> > Has anybody decided how it could possibly even look like anyhow? It
> > should be fixed, but nobody has a plan.
> 
> The simplest idea would be that an option select'ing some other option 
> inherits the dependencies of the latter. That should fix all problems 
> select currently has.
> 
> There are for sure some problems hidden that will show up during 
> implementation, but since noone is implementing it we'll never know...
> 
> > > That's horrible - you shouldn't force the user to manually enable three 
> > > options.
> > 
> > Well, akpm says: "select is broken. do not ever use it"
> 
> select works fine if you understand the pitfalls.
> 
> Kconfig is a _user interface_, and making using it easy for the user 
> is therefore important.
> 
> Whenever there's a mistake in a help text or something confusing
> users will run into problems with the kernel they compiled.
> 
> > > config SSB_PCIHOST_POSSIBLE
> > [...]
> > 
> > > 	depends on SSB_PCIHOST_POSSIBLE
> > > 	select SSB
> > > 	select SSB_PCIHOST
> > 
> > That would, indeed, be possible. But it's ... ugly ... you've now
> > effectively pushed the information on what *SSB* depends on into each
> > SSB *user* instead of SSB itself...
> 
> No, this information is still in drivers/ssb/Kconfig.
> 
> This would replace:
> 
> config B44
> 	depends on SSB_PCIHOST
> 
> with:
> 
> config B44
> 	depends on SSB_PCIHOST_POSSIBLE
> 	select SSB_PCIHOST
> 
> That's an easily understandable pattern without redundant information
> about the required dependencies of SSB_PCIHOST.
> 
> > > Is there any extremely good reason why options like SSB or SSB_PCIHOST 
> > > have to be user visible? 
> > 
> > Yes. Embedded systems like the small Linksys routers come with SSB as
> > the system bus. No PCI/PCIHOST.
> 
> OK.
> 
> > > And according to the kconfig help text, we should remove the B44_PCI 
> > > option and enable the code unconditionally?
> > > (Or what was the person writing this help text smoking^Wthinking when
> > >  writing it?)
> > 
> > Same reason. They have a b44 core there but no pci.
> 
> OK, that's understandable.
> 
> But the kconfig user currently only gets:
> 
> config B44_PCI
>         bool "Broadcom 440x PCI device support"
> 	...
> 	help
>           Support for Broadcom 440x PCI devices.
> 
>           Say Y, unless you know what you are doing.
>           If you say N here I will _not_ listen to your
>           bugreports!
> 
> An example how to make it better:
> 
> config USB_OHCI_HCD_SSB
>         bool "OHCI support for the Broadcom SSB OHCI core (embedded systems only)"
> 	...
>         help
>           Support for the Sonics Silicon Backplane (SSB) attached
>           Broadcom USB OHCI core.
> 
>           This device is only present in some embedded devices with
>           Broadcom based SSB bus.
> 
>           If unsure, say N.
> 
> That's the difference between a silly sounding help text ("I will _not_ 
> listen to your bugreports!") and a help text that gives the kconfig user 
> all required information ("only present in some embedded devices").
> 
> 
> And I'm not yet convinced B44_PCI is really worth bothering the user 
> with - what about automatically enabling PCI support in the driver if 
> PCI support is enabled in the kernel?


That's all a silly discussion, guys.
I personally do _not_ care which way we do this.
BUT: My users do care. There is currently no way telling them to first enable
SSB, when they want to select b44 (for example).
Select _does_ introduce breakage. I did use select and I am pretty sure
I got the dependencies right. And it _still_ broken on weird architectures.

So, I do not care how this is implemented. I do care however, that users
do get an advice (at least) on what to do. And that's what my patch does.
If someone has a better idea, please provide a patch.

-- 
Greetings Michael.
