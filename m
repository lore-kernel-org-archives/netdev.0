From: Lennert Buytenhek <buytenh@wantstofly.org>
Subject: Re: crappy/good gigabit chipsets?
Date: Sat, 27 Nov 2004 21:14:39 +0100
Message-ID: <20041127201439.GE27762@xi.wantstofly.org>
References: <41A81C15.5080905@gmx.net> <20041127111009.GB23139@xi.wantstofly.org> <20041127134706.GA28907@electric-eye.fr.zoreil.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Netdev <netdev@oss.sgi.com>
Return-path: <netdev-bounce@oss.sgi.com>
To: Francois Romieu <romieu@fr.zoreil.com>
Content-Disposition: inline
In-Reply-To: <20041127134706.GA28907@electric-eye.fr.zoreil.com>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Sat, Nov 27, 2004 at 02:47:06PM +0100, Francois Romieu wrote:

> > I tried r8169 (Realtek gigabit chipset, used in various el-cheapo
> > GigE cards) in a cheap Asus mainboard in a 32/33 slot, and when
> > driver spewing out various scary-looking PCI errors to the console.
> > throwing enough packets at it the card would just stall with the
> 
> <r8169 maintainer hat on>
> 
> - which chipset on the motherboard ?

Not sure, I'd have to open up the box.  Can't remember the mobo model off
the top of my hat either.  This is the lspci output (I swapped the r8169
for an e1000):

00:00.0 Host bridge: Silicon Integrated Systems [SiS] 651 Host (rev 02)
00:01.0 PCI bridge: Silicon Integrated Systems [SiS] Virtual PCI-to-PCI bridge (AGP)
00:02.0 ISA bridge: Silicon Integrated Systems [SiS] SiS962 [MuTIOL Media IO] (rev 25)
00:02.1 SMBus: Silicon Integrated Systems [SiS] SiS961/2 SMBus Controller
00:02.5 IDE interface: Silicon Integrated Systems [SiS] 5513 [IDE]
00:02.7 Multimedia audio controller: Silicon Integrated Systems [SiS] Sound Controller (rev a0)
00:03.0 USB Controller: Silicon Integrated Systems [SiS] USB 1.0 Controller (rev 0f)
00:03.1 USB Controller: Silicon Integrated Systems [SiS] USB 1.0 Controller (rev 0f)
00:03.2 USB Controller: Silicon Integrated Systems [SiS] USB 2.0 Controller
00:04.0 Ethernet controller: Silicon Integrated Systems [SiS] SiS900 PCI Fast Ethernet (rev 91)
00:0d.0 Ethernet controller: Intel Corp. 82541GI/PI Gigabit Ethernet Controller
01:00.0 VGA compatible controller: Silicon Integrated Systems [SiS] 65x/M650/740 PCI/AGP VGA Display Adapter


> - do you have some (even gross) figures for the required packet rate ?

I was blasting ~600kpps at it, and it couldn't handle that.  It seemed
to handle ~100kpps okay.  Didn't check anything else.

Half of the time the r8169 negotiates 100Mb/s with my other box' e1000
and half of the time it negotiates 1000Mb/s, even though there's only a
~1m cross-cable between the two, which is another reason why I swapped
it with the e1000 in the end.


> - is your computer with the r8169 adapter still available for testing ?

Sure, tell me what to do.


> People, please report such behavior. Even if you do not have time to
> further help fixing it, it really helps me to know own many hit the
> issue. Bugzilla or mail are fine with me.

I'm guilty and I'm sorry.  I wanted to do some more tests before sending
in a report but never got round to doing that testing.


> 4) misc pci error reports on x86 since the code for it has been added.
>    The pattern is not clear (chipset of the mobo ? cooling ? wtf ?).

I have a bunch of other PC that I can try this card in as well if that'd
help.  (Pity that my sparc doesn't take PCI cards.)


> > On an intel board with independent PCI buses, I see an e1000 'desktop'
> > NIC filling the pipe for any packet size > ~350 when the card sits on
> > its own PCI bus.  This is while running at 32/66, CPU being a 2.4GHz
> > Xeon.
> 
> How do you fill it ?

Non-cheesy hardware, dedicated PCI bus, and Robert Olsson's pktgen.  (Not
the one in the current 2.6 kernel but his new-and-updated version that's
somewhere on ftp://robur.slu.se/ )


--L
