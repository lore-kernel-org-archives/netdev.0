From: Andrew Morton <akpm@osdl.org>
Subject: Re: [Bugme-new] [Bug 7159] New: No networking on a machine with
 Ethernet Pro 100 and Realtek 8139
Date: Thu, 14 Sep 2006 11:53:13 -0700
Message-ID: <20060914115313.1b90a684.akpm@osdl.org>
References: <200609141804.k8EI433g025893@fire-2.osdl.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, hazelsct@debian.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp.osdl.org ([65.172.181.4]:60320 "EHLO smtp.osdl.org")
	by vger.kernel.org with ESMTP id S1751015AbWINSxr (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 14 Sep 2006 14:53:47 -0400
To: "bugme-daemon@kernel-bugs.osdl.org"
	<bugme-daemon@bugzilla.kernel.org>
In-Reply-To: <200609141804.k8EI433g025893@fire-2.osdl.org>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


(Switching from bugzilla to email - please retain all Cc's)

On Thu, 14 Sep 2006 11:04:03 -0700
bugme-daemon@bugzilla.kernel.org wrote:

> http://bugzilla.kernel.org/show_bug.cgi?id=7159
> 
>            Summary: No networking on a machine with Ethernet Pro 100 and
>                     Realtek 8139
>     Kernel Version: 2.6.16, 2.6.17, 2.6.18-rc6
>             Status: NEW
>           Severity: normal
>              Owner: jgarzik@pobox.com
>          Submitter: hazelsct@debian.org
> 
> 
> Most recent kernel where this bug did not occur: 2.6.8
> Distribution: Debian
> Hardware Environment: Dual-PIII, Ethernet Pro 100 and Realtek 8139 PCI interfaces
> Software Environment: Debian Etch (Testing)
> Problem Description: The network is not reachable, though the kernel does seem
> to sense line presence on both interfaces.
> 
> On boot, udev/discover loads e100, 8139cp and 8139too.  /etc/modules does not
> have any network modules (needs eepro100 for 2.6.8, but I removed it, no
> change).  The relevant lspci listings
> are:
> 
> 00:09.0 Ethernet controller: Intel Corporation 82557/8/9 [Ethernet Pro 100] (rev 05)
> 00:0b.0 Ethernet controller: Realtek Semiconductor Co., Ltd.
> RTL-8139/8139C/8139C+ (rev 10)
> 
> Both interfaces work fine under 2.6.8 as long as eepro100 is loaded.
> 
> More information (lspci -v, /proc/interrupts, /proc/ioports) can be found at the
> Debian bug: http://bugs.debian.org/386972
> 
> Steps to reproduce: Boot, try to use network.
> 

This is all a bit peculiar.  I'd be assuming that you're not getting
any interrupts through for those NICs.

Could you please check /proc/interrupts, see if the interrupt counts
related to the NICs can be made to increase?

Also, the full `dmesg -s 1000000' output might help.

We might also get some interesting info if you can compile your own kernel,
build thsoe net drivers into vmlinux, capture the dmesg output.

If it _is_ an IRQ problem then you might find that fiddling with ACPI
helps: disable it in config or boot with `acpi=off', see if that helps.  Also
try booting with the `pci=routeirq' option.

There are various options described under acpi= and pci= in
Documentation/kernel-parameters.txt which it would be useful for you to
experiment with.

