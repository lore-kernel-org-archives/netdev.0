From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [Bugme-new] [Bug 9440] New: Problem in joinning a socket to
 ipv6 multicast address in specific scenario
Date: Thu, 22 Nov 2007 17:23:42 -0800
Message-ID: <20071122172342.721ee232.akpm@linux-foundation.org>
References: <bug-9440-10286@http.bugzilla.kernel.org/>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: bugme-daemon@bugzilla.kernel.org, aviad.yehezkel5@gmail.com
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp2.linux-foundation.org ([207.189.120.14]:52218 "EHLO
	smtp2.linux-foundation.org" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1752202AbXKWBYA (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 22 Nov 2007 20:24:00 -0500
In-Reply-To: <bug-9440-10286@http.bugzilla.kernel.org/>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Thu, 22 Nov 2007 11:02:04 -0800 (PST) bugme-daemon@bugzilla.kernel.org wrote:

> http://bugzilla.kernel.org/show_bug.cgi?id=9440
> 
>            Summary: Problem in joinning a socket to ipv6 multicast address
>                     in specific scenario
>            Product: Networking
>            Version: 2.5
>      KernelVersion: 2.6
>           Platform: All
>         OS/Version: Linux
>               Tree: Mainline
>             Status: NEW
>           Severity: high
>           Priority: P1
>          Component: IPV6
>         AssignedTo: yoshfuji@linux-ipv6.org
>         ReportedBy: aviad.yehezkel5@gmail.com
> 
> 
> Hi,
> I have a problem in joinning a socket to multicast address in the following
> scenario (maybe kernel bug):
> 
> 1. I am changing the mtu size of the eth device to a small size - "ifconfig
> eth1 mtu 100"
> 
> 2. After that i am resizing the mtu for it's orginal size - "ifconfig eth1 mtu
> 1500"
> 
> 3. Now i am running a program i wrote in c that opens a dgram socket
> (sock_fd[i] = socket(test_data->protocol, SOCK_DGRAM, 0);)  and join it to
> multicast ipv6 address. 
> if i am running this program after steps 1+2 i get the following error:
> "Resource temporarily unavailable" when trying to join the socket to the
> multicast ipv6 address by the
> system call : 
> 
> struct ipv6_mreq maddr6_group; 
> ...
> setsockopt(sock_fd,
>        IPPROTO_IPV6,
>        IPV6_JOIN_GROUP,
>        (char *)&maddr6_group,
>        sizeof(maddr6_group));
> 
> but if i am running my program after reset of the driver (before steps 1+2) it
> is working fine.
> if i am trying to run the program and join a socket to ipv4 multicast address
> (instead of ipv6) i get no errors - this doesn't work only when trying to join
> to ipv6 multicast address. 
> 
> I got this error in broadcom device ("Broadcom Corporation NetXtreme BCM5721
> Gigabit Ethernet PCI Express (rev 21)") but i don't think this is a bug in
> broadcom driver,
> because i tried it on differnt devices, in some devices i got the following
> error instead: "Invalid argument" with the same multicast address.
> As i said before if i am trying to join a socket to multicast ipv6 address
> before resizing the mtu size it is working fine, all the problems are after
> step 1+2.
> 
> All my tries were OS:
> 1. SLES10.0 - 2.6.16.21-0.8-smp 
> 2. REDHAT5.0 - 2.6.18-8.el5 #1 SMP.
> 
> 
> I am waiting for an answer,
> thanks a lot,
> Aviad Yehezkel.
> 
> 
> -- 
> Configure bugmail: http://bugzilla.kernel.org/userprefs.cgi?tab=email
> ------- You are receiving this mail because: -------
> You are on the CC list for the bug, or are watching someone who is.
