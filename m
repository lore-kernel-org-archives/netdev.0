From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [Bugme-new] [Bug 9270] New: sunhme requires lower MTU to handle
 802.1q frames
Date: Wed, 31 Oct 2007 15:43:01 -0700
Message-ID: <20071031154301.3cc0fbb9.akpm@linux-foundation.org>
References: <bug-9270-10286@http.bugzilla.kernel.org/>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: bugme-daemon@bugzilla.kernel.org, dev-null@telus.net
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp2.linux-foundation.org ([207.189.120.14]:42462 "EHLO
	smtp2.linux-foundation.org" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1760765AbXJaWnR (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 31 Oct 2007 18:43:17 -0400
In-Reply-To: <bug-9270-10286@http.bugzilla.kernel.org/>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Wed, 31 Oct 2007 14:54:06 -0700 (PDT)
bugme-daemon@bugzilla.kernel.org wrote:

> http://bugzilla.kernel.org/show_bug.cgi?id=9270
> 
>            Summary: sunhme requires lower MTU to handle 802.1q frames
>            Product: Drivers
>            Version: 2.5
>      KernelVersion: 2.6.18-3
>           Platform: All
>         OS/Version: Linux
>               Tree: Mainline
>             Status: NEW
>           Severity: normal
>           Priority: P1
>          Component: Network
>         AssignedTo: jgarzik@pobox.com
>         ReportedBy: dev-null@telus.net
> 
> 
> Most recent kernel where this bug did not occur: N/A
> Distribution: Debian 4.0r1 (Etch)
> Hardware Environment: Sun Netra T1 105
> Software Environment:
> Problem Description:
> sunhme requires lower MTU to handle 802.1q frames - even though the PCI
> driver supported VLAN tagging, you cannot do full MTU @ 1500 because the
> driver doesn't set the card to transfer more the extra bytes for a 802.1q
> frame at 1500 MTU.
> 
> Steps to reproduce:
> modprobe 8021q
> modprobe sunhme
> ifconfig eth0 up
> vconfig set_name_type DEV_PLUS_VID_NO_PAD
> vconfig add eth0 10
> ifconfig eth0.10 192.l68.0.1 netmask 255.255.255.252 broadcast 192.168.0.3 up
> # IP pkt size = 1496, Ethernet frame size = 1514
> ping -s 1468 -c 1 -w 1 192.168.0.2
> # IP pkt size = 1500, Ethernet frame size = 1518
> ping -s 1472 -c 1 -w 1 192.168.0.2
