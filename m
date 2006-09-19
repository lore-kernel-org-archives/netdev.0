From: Adam C Powell IV <hazelsct@debian.org>
Subject: Re: [Bugme-new] [Bug 7159] New: No networking on a machine with
	Ethernet Pro 100 and Realtek 8139
Date: Tue, 19 Sep 2006 14:19:50 -0400
Message-ID: <1158689990.14496.2.camel@doorstop.home.net>
References: <200609141804.k8EI433g025893@fire-2.osdl.org>
	 <20060914115313.1b90a684.akpm@osdl.org>  <1158518840.1616.12.camel@veryst>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: "bugme-daemon@kernel-bugs.osdl.org"
	<bugme-daemon@bugzilla.kernel.org>, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from alnrmhc14.comcast.net ([204.127.225.94]:59890 "EHLO
	alnrmhc14.comcast.net") by vger.kernel.org with ESMTP
	id S1030400AbWISSUe (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 19 Sep 2006 14:20:34 -0400
To: Andrew Morton <akpm@osdl.org>
In-Reply-To: <1158518840.1616.12.camel@veryst>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hello again,

It seems nobody received the message below; likely because the SMTP
server at work refused to forward a message from hazelsct@debian.org .
Sorry about the delay.

On Sun, 2006-09-17 at 15:12 -0400, Adam C Powell IV wrote:
> Hello, and apologies for the reply delay.  (This is a production
> machine, and I haven't been able to experiment until today, though I
> should have time Tuesday morning to try some things if needed.)
> 
> On Thu, 2006-09-14 at 11:53 -0700, Andrew Morton wrote:
> > (Switching from bugzilla to email - please retain all Cc's)
> > 
> > On Thu, 14 Sep 2006 11:04:03 -0700
> > bugme-daemon@bugzilla.kernel.org wrote:
> > 
> > > http://bugzilla.kernel.org/show_bug.cgi?id=7159
> > > 
> > >            Summary: No networking on a machine with Ethernet Pro 100 and
> > >                     Realtek 8139
> > >     Kernel Version: 2.6.16, 2.6.17, 2.6.18-rc6
> > >             Status: NEW
> > >           Severity: normal
> > >              Owner: jgarzik@pobox.com
> > >          Submitter: hazelsct@debian.org
> > > 
> > > 
> > > Most recent kernel where this bug did not occur: 2.6.8
> > > Distribution: Debian
> > > Hardware Environment: Dual-PIII, Ethernet Pro 100 and Realtek 8139 PCI interfaces
> > > Software Environment: Debian Etch (Testing)
> > > Problem Description: The network is not reachable, though the kernel does seem
> > > to sense line presence on both interfaces.
> > > 
> > > On boot, udev/discover loads e100, 8139cp and 8139too.  /etc/modules does not
> > > have any network modules (needs eepro100 for 2.6.8, but I removed it, no
> > > change).  The relevant lspci listings
> > > are:
> > > 
> > > 00:09.0 Ethernet controller: Intel Corporation 82557/8/9 [Ethernet Pro 100] (rev 05)
> > > 00:0b.0 Ethernet controller: Realtek Semiconductor Co., Ltd.
> > > RTL-8139/8139C/8139C+ (rev 10)
> > > 
> > > Both interfaces work fine under 2.6.8 as long as eepro100 is loaded.
> > > 
> > > More information (lspci -v, /proc/interrupts, /proc/ioports) can be found at the
> > > Debian bug: http://bugs.debian.org/386972
> > > 
> > > Steps to reproduce: Boot, try to use network.
> > > 
> > 
> > This is all a bit peculiar.  I'd be assuming that you're not getting
> > any interrupts through for those NICs.
> > 
> > Could you please check /proc/interrupts, see if the interrupt counts
> > related to the NICs can be made to increase?
> 
> Can't do it.  Connecting/disconnecting, ping from inside and out,
> nothing increments the interrupt counts.
> 
> > Also, the full `dmesg -s 1000000' output might help.
> > 
> > We might also get some interesting info if you can compile your own kernel,
> > build thsoe net drivers into vmlinux, capture the dmesg output.
> > 
> > If it _is_ an IRQ problem then you might find that fiddling with ACPI
> > helps: disable it in config or boot with `acpi=off', see if that helps.
> 
> Yes!  The network works just fine now.
> 
> > Also
> > try booting with the `pci=routeirq' option.
> 
> By itself, this does not cure the network problem.  But all of my GNOME
> applets work with this; without it, the panel hangs after opening a few
> of them.  Different few every time, so it's hard to peg which one is the
> problem.
> 
> With both acpi=off and pci=routeirq, the network works and GNOME applets
> work.  Hooray!
> 
> Not so fast.  The machine hung completely once, then the next two boots,
> everything in X hung except the cursor.  I was able to ssh in, and grab
> interrupts and dmesg.
> 
> Output of "dmesg -s 1000000" and "cat /proc/interrupts" is at
> http://lyre.mit.edu/~powell/temp/ (oops, I had done "ifdown eth0; ifdown
> eth1" before catching interrupts-acpi=off; that's why those are absent.)
> 
> > There are various options described under acpi= and pci= in
> > Documentation/kernel-parameters.txt which it would be useful for you to
> > experiment with.
> 
> I think the acpi=off boot option did the trick.  The config is Debian
> stock 2.6.17-2-686 with 'enter' at all new questions in make oldconfig.
> This problem is also in the Debian stock 2.6.17 and 2.6.16 kernels, so I
> suspect a different .config might clear it up.
> 
> Any suggestions there for a .config which will work with ACPI and
> non-ACPI machines?  Debian stock 2.6.8 seems fine (but of course is
> missing the fancy new features).
> 
> The X apps hang is a separate problem.  I'll pursue it with the Debian
> people before opening a separate bug.  Feel free to close this one.
> 
> Thank you again.
> 
> -Adam
-- 
GPG fingerprint: D54D 1AEE B11C CE9B A02B  C5DD 526F 01E8 564E E4B6

Welcome to the best software in the world today cafe!
http://www.take6.com/albums/greatesthits.html
