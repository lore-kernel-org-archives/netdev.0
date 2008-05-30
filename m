From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [Bugme-new] [Bug 10835] New: vanilla kernel 2.6.25.4 + TLAN NIC
 driver oops or so...
Date: Thu, 29 May 2008 22:42:37 -0700
Message-ID: <20080529224237.26c9d2e2.akpm@linux-foundation.org>
References: <bug-10835-10286@http.bugzilla.kernel.org/>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: bugme-daemon@bugzilla.kernel.org, netdev@vger.kernel.org
To: wizard580@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp1.linux-foundation.org ([140.211.169.13]:53188 "EHLO
	smtp1.linux-foundation.org" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1752510AbYE3Fmj (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 30 May 2008 01:42:39 -0400
In-Reply-To: <bug-10835-10286@http.bugzilla.kernel.org/>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


(switched to email.  Please respond via emailed reply-to-all, not via the
bugzilla web interface).

On Thu, 29 May 2008 22:22:36 -0700 (PDT) bugme-daemon@bugzilla.kernel.org wrote:

> http://bugzilla.kernel.org/show_bug.cgi?id=10835
> 
>            Summary: vanilla kernel 2.6.25.4 + TLAN NIC driver oops or so...
>            Product: Drivers
>            Version: 2.5
>      KernelVersion: 2.6.25.4
>           Platform: All
>         OS/Version: Linux
>               Tree: Mainline
>             Status: NEW
>           Severity: normal
>           Priority: P1
>          Component: Network
>         AssignedTo: jgarzik@pobox.com
>         ReportedBy: wizard580@gmail.com
> 
> 
> Latest working kernel version: 2.6.25.4

I assume you meant 2.6.25.1 here.

> Earliest failing kernel version: 2.6.25.4
> Distribution: debian sid
> Hardware Environment: Compaq Deskpro (some old comp)
> Software Environment: latest updates
> 
> Problem Description: 
> after some time of normal work I lost connect to my router. no ping, no ssh.
> nothing. I come to router, switched on monitor and see infinetely looping
> messages about some error like this: TLAN: Could't allocate memory for... and
> some memory dumps. It's quickly scrolling so exact error message I can't read.

It could only have been

	"TLAN:  Couldn't allocate memory for received data.\n"

however the stupid driver prints the same string from three different
places.

> On keyboard "caps Lock" and "scroll lock" are blinking...

hm, that might mean it oopses as well.

> Alt+Ctrl+Del don't reboot system. So I reset it and all run fine again... I
> don't know for how long it will...
> 
> There is one vlan on tlan interface. If it's help...
> 
> As I remember, on 2.6.25.1 there was no errors for much more time (maybe it's
> my luck). So I think may be something changed between 2.6.25.1 and 2.6.25.4
> that break memory allocations for that driver or so...
> 
> lspci:
> 00:00.0 Host bridge: Intel Corporation 440LX/EX - 82443LX/EX Host bridge (rev
> 03)
> 00:01.0 PCI bridge: Intel Corporation 440LX/EX - 82443LX/EX AGP bridge (rev 03)
> 00:0d.0 Ethernet controller: Realtek Semiconductor Co., Ltd.
> RTL-8139/8139C/8139C+ (rev 10)
> 00:0e.0 Ethernet controller: Realtek Semiconductor Co., Ltd.
> RTL-8139/8139C/8139C+ (rev 10)
> 00:0f.0 SCSI storage controller: Adaptec AIC-7860 (rev 03)
> 00:10.0 Network controller: Compaq Computer Corporation Netelligent 10/100 TX
> Embedded UTP (rev 10)
> 00:12.0 Ethernet controller: Realtek Semiconductor Co., Ltd.
> RTL-8139/8139C/8139C+ (rev 10)
> 00:14.0 ISA bridge: Intel Corporation 82371AB/EB/MB PIIX4 ISA (rev 01)
> 00:14.1 IDE interface: Intel Corporation 82371AB/EB/MB PIIX4 IDE (rev 01)
> 00:14.2 USB Controller: Intel Corporation 82371AB/EB/MB PIIX4 USB (rev 01)
> 00:14.3 Bridge: Intel Corporation 82371AB/EB/MB PIIX4 ACPI (rev 01)
> 01:00.0 VGA compatible controller: Matrox Graphics, Inc. MGA 2164W [Millennium
> II] AGP
> 
> 
> Steps to reproduce:
> try to use such hardware... or simply tlan NIC.

Alas, no significant changes have been made to tlan.c in ages.

