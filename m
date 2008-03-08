From: Jarek Poplawski <jarkao2@gmail.com>
Subject: Re: PROBLEM: A set of networking related oopses
Date: Sat, 8 Mar 2008 18:57:21 +0100
Message-ID: <20080308175721.GA3582@ami.dom.local>
References: <D04F01C2-03F0-4FBC-933D-62899456BEE9@solitudo.net> <47D26201.2060201@gmail.com> <0CFB0535-DE03-4C13-8EC5-9471CED9B6BE@solitudo.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org
To: Tuomas Jormola <tj@solitudo.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from fg-out-1718.google.com ([72.14.220.153]:7649 "EHLO
	fg-out-1718.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750703AbYCHRsv (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 8 Mar 2008 12:48:51 -0500
Received: by fg-out-1718.google.com with SMTP id e21so1132564fga.17
        for <netdev@vger.kernel.org>; Sat, 08 Mar 2008 09:48:50 -0800 (PST)
Content-Disposition: inline
In-Reply-To: <0CFB0535-DE03-4C13-8EC5-9471CED9B6BE@solitudo.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sat, Mar 08, 2008 at 06:13:55PM +0200, Tuomas Jormola wrote:
...
> (18:08:32)(tj@shakti)(~)$ cat /proc/interrupts
>            CPU0       CPU1
...
>  18:     875645     873991   IO-APIC-fasteoi   uhci_hcd:usb1,  
> uhci_hcd:usb6, eth0
>  19:          2          1   IO-APIC-fasteoi   uhci_hcd:usb5, ohci1394
>  20:          0          0   IO-APIC-fasteoi   uhci_hcd:usb2
>  21:          0          0   IO-APIC-fasteoi   uhci_hcd:usb4,  
> ehci_hcd:usb8
>  22:          4          3   IO-APIC-fasteoi   heci
> 217:     498561     498427   PCI-MSI-edge      eth1
> 218:   88587922   88715380   PCI-MSI-edge      ahci
...
> So I would be able to bind eth0 to CPU0 by running
>
> echo 1 > /proc/irq/18/smp_affinity
>
> right? http://www.cs.uwaterloo.ca/~brecht/servers/apic/SMP-affinity.txt 
> says that smp affinity only works for drivers that support IO-APIC. The 
> eth1 card is an old Intel card, and looks like it doesn't support this. I 
> guess I'll replace the card with a newer one.

Should be right. If it's possibile, you can try if moving eth0 to
another slot could give it it's own irq.

I think it should work with both of your cards: eth1 uses newer type
of interrupts - are you sure it's e100?

You can also check if it really fixes the problem by booting with
a kernel parameter: noirqbalance.

Jarek P.
