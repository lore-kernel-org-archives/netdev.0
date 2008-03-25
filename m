From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [Bugme-new] [Bug 10327] New: keyboard stops responding after
 "ifdown eth0"
Date: Tue, 25 Mar 2008 14:39:41 -0700
Message-ID: <20080325143941.300d415f.akpm@linux-foundation.org>
References: <bug-10327-10286@http.bugzilla.kernel.org/>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: bugme-daemon@bugzilla.kernel.org, linux-kernel@vger.kernel.org,
	linux-input@vger.kernel.org, netdev@vger.kernel.org
To: marcus@better.se
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp1.linux-foundation.org ([140.211.169.13]:54170 "EHLO
	smtp1.linux-foundation.org" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1761036AbYCYVjr (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 25 Mar 2008 17:39:47 -0400
In-Reply-To: <bug-10327-10286@http.bugzilla.kernel.org/>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


(switched to email.  Please respond via emailed reply-to-all, not via the
bugzilla web interface).

On Tue, 25 Mar 2008 14:22:51 -0700 (PDT)
bugme-daemon@bugzilla.kernel.org wrote:

> http://bugzilla.kernel.org/show_bug.cgi?id=10327
> 
>            Summary: keyboard stops responding after "ifdown eth0"
>            Product: Drivers
>            Version: 2.5
>      KernelVersion: 2.6.24, 2.6.25-rc6
>           Platform: All
>         OS/Version: Linux
>               Tree: Mainline
>             Status: NEW
>           Severity: normal
>           Priority: P1
>          Component: Network
>         AssignedTo: jgarzik@pobox.com
>         ReportedBy: marcus@better.se
> 
> 
> Latest working kernel version: unknown
> Earliest failing kernel version: 2.6.24
> Distribution: Debian testing/unstable
> Hardware Environment: LG LE50 Express laptop
> Software Environment: Debian i386, X.org 7.3, KDE 4
> Problem Description:
> 
> The keyboard stops working when I'm manipulating the Ethernet interface while
> in an X.org session. The session doesn't respond to keyboard input, although
> the magic SysReq key still works, and the mouse also works. The only way out is
> a reboot.
> 
> The bug is triggered consistently when I bring down the eth0 interface with
> "ifdown eth0". (I normally use only wireless, so I didn't notice this before.)
> 
> Steps to reproduce:
> 
> Boot up, log in to KDE, bring up eth0, assign an address and send some traffic,
> then "ifdown eth0".
> 

(this is using sky2)


> ~$ cat /proc/interrupts
>            CPU0
>   0:      32835  local-APIC-edge-fasteoi   timer
>   1:         10   IO-APIC-edge      i8042
>   8:          2   IO-APIC-edge      rtc
>  12:        138   IO-APIC-edge      i8042
>  14:      28322   IO-APIC-edge      ide0
>  15:      10618   IO-APIC-edge      ide1
>  16:        334   IO-APIC-fasteoi   HDA Intel
>  19:      19243   IO-APIC-fasteoi   ohci_hcd:usb1, ohci_hcd:usb2, ehci_hcd:usb3
>  20:         20   IO-APIC-fasteoi   firewire_ohci, yenta, tifm_7xx1,
> sdhc0:slot0, sdhc0:slot1, sdhc0:slot2
>  21:       1827   IO-APIC-fasteoi   acpi
>  22:      19159   IO-APIC-fasteoi   0000:08:02.0
> 223:          2   PCI-MSI-edge      eth0
> NMI:          0   Non-maskable interrupts
> LOC:    1415833   Local timer interrupts
> TRM:          0   Thermal event interrupts
> SPU:          0   Spurious interrupts
> ERR:          0
> MIS:          0

So it's not an ill-advised disable_irq().

I guess the first question is: did the ifdown just kill the keyboard, or
did more things die?

Perhaps you could try

	ifdown eth0 ; sleep 5 ; ifup eth0

and see if the machine recovers?

(I am just maxed out on bug reports at present - could someone please take
this up and see if we can get it fixed?)

