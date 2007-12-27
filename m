From: Andreas Mohr <andi@lisas.de>
Subject: Re: [PATCH 2.6.24-rc3] Fix /proc/net breakage
Date: Thu, 27 Dec 2007 18:40:56 +0100
Message-ID: <20071227174056.GA17350@rhlx01.hs-esslingen.de>
References: <20071119191000.GA1560@elf.ucw.cz> <200711192304.25087.rjw@sisk.pl> <4743026B.2020907@openvz.org> <m1hcj8mz1p.fsf_-_@ebiederm.dsl.xmission.com> <1197003097.13978.557.camel@pmac.infradead.org> <20071207022342.806ee4ee.akpm@linux-foundation.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: David Woodhouse <dwmw2@infradead.org>,
	"Eric W. Biederman" <ebiederm@xmission.com>,
	Linus Torvalds <torvalds@linux-foundation.org>,
	"Rafael J. Wysocki" <rjw@sisk.pl>, Pavel Machek <pavel@ucw.cz>,
	kernel list <linux-kernel@vger.kernel.org>,
	netdev <netdev@vger.kernel.org>,
	Pavel Emelyanov <xemul@openvz.org>,
	"Denis V. Lunev" <den@openvz.org>
To: Andrew Morton <akpm@linux-foundation.org>
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S1753607AbXL0RlL@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <20071207022342.806ee4ee.akpm@linux-foundation.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hi,

On Fri, Dec 07, 2007 at 02:23:42AM -0800, Andrew Morton wrote:
> > (commit 2b1e300a9dfc3196ccddf6f1d74b91b7af55e416)
> > 
> > This seems to have broken the use of /proc/bus/usb as a mountpoint. It
> > always appears empty now, whatever's supposed to be mounted there.
> > 
> 
> Yes.  Denis and Eric are tossing around competing patches but afaik nobody
> is happy with any of them.  Guys, could we get this sorted soonish please?

"Soonish" being rather earlier than 20071227?
'cause it's still throwing a fit for me on 2.6.24-rc6-mm1(!) (plus hotfix),
nothing visible in /proc/bus/usb, thus WLAN driver won't probe
anything.
Side note: later upgraded from hotplug-based setup to udev,
but didn't change status quo of problem of empty mount.
Now back again to a 2.6.19ish kernel, since this is the only one
that I could always fall back on after a sizeable number of attempts
to get to run anything newer trouble-free in this environment.
Frankly I'm slightly getting fed up with the number of regressions
I'm hitting in my smallish environment lately. But that's sorta
what you pay for when going experimental.
Just the same day I also had to discover that e100 doesn't usefully
support (IOW, fatal resource probing error) my Intel BNC combo 645477-004,
as opposed to eepro100. Swapped the card from this ""production""
headless box to an easily accessible one for followup debugging of e100.


K6-3@150 headless, Debian stable.

mount 2.12r-19
usbutils 0.72-7

fstab:
none /proc/bus/usb usbfs defaults 0 0

lsmod (NOTE: from 2.6.19-cks2, sorry):

Module                  Size  Used by
act_police              6980  1 
sch_ingress             3712  1 
cls_u32                 7300  5 
sch_tbf                 6400  1 
sch_sfq                 5888  4 
sch_htb                16128  1 
ppp_async              11648  1 
crc_ccitt               2304  1 ppp_async
ipt_ULOG                7940  1 
xt_state                2304  4 
xt_limit                2816  11 
xt_tcpudp               3200  48 
xt_multiport            3200  10 
iptable_mangle          2944  0 
iptable_nat             7044  1 
iptable_filter          3200  1 
ip_tables              12360  3 iptable_mangle,iptable_nat,iptable_filter
ip_nat_tftp             2048  0 
ip_conntrack_tftp       4504  1 ip_nat_tftp
ip_nat_h323             7296  0 
ip_conntrack_h323      48028  1 ip_nat_h323
ip_nat_irc              2816  0 
ip_nat_ftp              3456  0 
ip_conntrack_irc        6928  1 ip_nat_irc
ip_conntrack_ftp        7312  1 ip_nat_ftp
ipt_MASQUERADE          3840  1 
ip_nat                 16684  6 iptable_nat,ip_nat_tftp,ip_nat_h323,ip_nat_irc,ip_nat_ftp,ipt_MASQUERADE
ip_conntrack           43884  12 xt_state,iptable_nat,ip_nat_tftp,ip_conntrack_tftp,ip_nat_h323,ip_conntrack_h323,ip_nat_irc,ip_nat_ftp,ip_conntrack_irc,ip_conntrack_ftp,ipt_MASQUERADE,ip_nat
ipt_REJECT              4608  0 
ipt_LOG                 6784  11 
x_tables               14468  10 ipt_ULOG,xt_state,xt_limit,xt_tcpudp,xt_multiport,iptable_nat,ip_tables,ipt_MASQUERADE,ipt_REJECT,ipt_LOG
isdn                  109920  0 
sis5595                14472  0 
i2c_isa                 6528  1 sis5595
at76c503_rfmd           5900  0 
firmware_class          9728  1 at76c503_rfmd
i2c_sis5595             8196  0 
at76c503               85856  1 at76c503_rfmd
at76_usbdfu             5636  1 at76c503
i2c_sis630              9100  0 
i2c_core               22656  4 sis5595,i2c_isa,i2c_sis5595,i2c_sis630
ohci_hcd               31748  0 
usbcore               135044  5 at76c503_rfmd,at76c503,at76_usbdfu,ohci_hcd
e100                   33800  0 
3c59x                  41384  0 

lspci -v (2.6.19-cks2):

00:00.0 Host bridge: Silicon Integrated Systems [SiS] 5591/5592 Host (rev 02)
	Flags: bus master, medium devsel, latency 64
	Memory at e8000000 (32-bit, non-prefetchable) [size=64M]
	Capabilities: [c0] AGP version 1.0

00:00.1 IDE interface: Silicon Integrated Systems [SiS] 5513 [IDE] (rev d0) (prog-if 8a [Master SecP PriP])
	Flags: bus master, fast devsel, latency 64, IRQ 14
	I/O ports at <ignored>
	I/O ports at <ignored>
	I/O ports at <ignored>
	I/O ports at <ignored>
	I/O ports at 4000 [size=16]

00:01.0 ISA bridge: Silicon Integrated Systems [SiS] SiS85C503/5513 (LPC Bridge) (rev 01)
	Flags: bus master, medium devsel, latency 0

00:01.1 Class ff00: Silicon Integrated Systems [SiS] ACPI
	Flags: medium devsel

00:01.2 USB Controller: Silicon Integrated Systems [SiS] USB 1.0 Controller (rev 11) (prog-if 10 [OHCI])
	Flags: bus master, medium devsel, latency 64, IRQ 12
	Memory at f0102000 (32-bit, non-prefetchable) [size=4K]

00:02.0 PCI bridge: Silicon Integrated Systems [SiS] Virtual PCI-to-PCI bridge (AGP) (prog-if 00 [Normal decode])
	Flags: bus master, fast devsel, latency 0
	Bus: primary=00, secondary=01, subordinate=01, sec-latency=64
	I/O behind bridge: 0000d000-0000dfff
	Memory behind bridge: ec000000-edffffff
	Prefetchable memory behind bridge: e0000000-e7ffffff

00:09.0 Ethernet controller: Intel Corporation 82557/8/9 [Ethernet Pro 100] (rev 08)
	Subsystem: Intel Corporation EtherExpress PRO/100+ Management Adapter
	Flags: bus master, medium devsel, latency 64, IRQ 11
	Memory at f0100000 (32-bit, non-prefetchable) [size=4K]
	I/O ports at e000 [size=64]
	Memory at f0000000 (32-bit, non-prefetchable) [size=1M]
	Expansion ROM at ee000000 [disabled] [size=1M]
	Capabilities: [dc] Power Management version 2

00:0f.0 Ethernet controller: 3Com Corporation 3c905B Deluxe Etherlink 10/100/BNC [Cyclone]
	Subsystem: 3Com Corporation 3c905B Deluxe Etherlink 10/100/BNC [Cyclone]
	Flags: bus master, medium devsel, latency 64, IRQ 10
	I/O ports at e400 [size=128]
	Memory at f0101000 (32-bit, non-prefetchable) [size=128]
	Expansion ROM at ef000000 [disabled] [size=128K]
	Capabilities: [dc] Power Management version 1

01:00.0 VGA compatible controller: ATI Technologies Inc Radeon RV100 QY [Radeon 7000/VE] (prog-if 00 [VGA])
	Subsystem: ATI Technologies Inc Unknown device 110a
	Flags: bus master, stepping, 66MHz, medium devsel, latency 64
	Memory at e0000000 (32-bit, prefetchable) [size=128M]
	I/O ports at d000 [size=256]
	Memory at ed000000 (32-bit, non-prefetchable) [size=64K]
	[virtual] Expansion ROM at ec000000 [disabled] [size=128K]
	Capabilities: [58] AGP version 2.0
	Capabilities: [50] Power Management version 2

Thanks,

Andreas Mohr
