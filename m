From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [Bugme-new] [Bug 26632] New: rtl8169 slow to come up and not
 allowing telnetd-ssl negotiation
Date: Wed, 19 Jan 2011 14:59:04 -0800
Message-ID: <20110119145904.d750d49d.akpm@linux-foundation.org>
References: <bug-26632-10286@https.bugzilla.kernel.org/>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: bugzilla-daemon@bugzilla.kernel.org,
	bugme-daemon@bugzilla.kernel.org, arthur.marsh@internode.on.net
To: netdev@vger.kernel.org, Jan Engelhardt <jengelh@medozas.de>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp1.linux-foundation.org ([140.211.169.13]:57379 "EHLO
	smtp1.linux-foundation.org" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1754261Ab1ASW7p (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 19 Jan 2011 17:59:45 -0500
In-Reply-To: <bug-26632-10286@https.bugzilla.kernel.org/>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


(switched to email.  Please respond via emailed reply-to-all, not via the
bugzilla web interface).

On Thu, 13 Jan 2011 09:53:26 GMT
bugzilla-daemon@bugzilla.kernel.org wrote:

> https://bugzilla.kernel.org/show_bug.cgi?id=26632
> 
>            Summary: rtl8169 slow to come up and not allowing telnetd-ssl
>                     negotiation
>            Product: Drivers
>            Version: 2.5
>     Kernel Version: 2.6.37-git9
>           Platform: All
>         OS/Version: Linux
>               Tree: Mainline
>             Status: NEW
>           Severity: high
>           Priority: P1
>          Component: Network
>         AssignedTo: drivers_network@kernel-bugs.osdl.org
>         ReportedBy: arthur.marsh@internode.on.net
>                 CC: arthur.marsh@internode.on.net
>         Regression: Yes
> 
> 
> I have an ASUS M3A78 Pro motherboard (AMD64, RS780 chipset) with onboard
> Realtek 8169. Normally the ethernet connection comes up quickly, including with
> kernel 2.6.37-git7. With kernel 2.6.37-git9, I get the following in dmesg:
> 
> $ dmesg|grep eth0
> [    0.878911] r8169 0000:02:00.0: eth0: RTL8168c/8111c at 0xffffc9000007a000,
> 00:23:54:5e:5d:d5, XID 1c4000c0 IRQ 40
> [   11.156602] r8169 0000:02:00.0: eth0: link down
> [   11.156639] r8169 0000:02:00.0: eth0: link down
> [   11.157333] ADDRCONF(NETDEV_UP): eth0: link is not ready
> [   12.780948] r8169 0000:02:00.0: eth0: link up
> [   12.783051] ADDRCONF(NETDEV_CHANGE): eth0: link becomes ready
> 
> At this stage I can connect to the internet with HTTP/HTTPS but a telnet-ssl
> <address-of-this-machine> or telnet-ssl from another machine to this one fails
> at the telnet negotiation stage. telnet-ssl from this machine to another works.
> 

This regression was bisected to

0ab03c2b1478f2438d2c80204f7fef65b1bca9cf is the first bad commit
commit 0ab03c2b1478f2438d2c80204f7fef65b1bca9cf
Author: Jan Engelhardt <jengelh@medozas.de>
Date:   Fri Jan 7 03:15:05 2011 +0000

    netlink: test for all flags of the NLM_F_DUMP composite


