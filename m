From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [Bugme-new] [Bug 11147] New: tg3 + jumbo frames +
 scatter-gather == inoperative NIC
Date: Tue, 22 Jul 2008 13:14:00 -0700
Message-ID: <20080722131400.1b133926.akpm@linux-foundation.org>
References: <bug-11147-10286@http.bugzilla.kernel.org/>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: bugme-daemon@bugzilla.kernel.org,
	jnelson-kernel-bugzilla@jamponi.net
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp1.linux-foundation.org ([140.211.169.13]:35809 "EHLO
	smtp1.linux-foundation.org" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1752012AbYGVUOD (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 22 Jul 2008 16:14:03 -0400
In-Reply-To: <bug-11147-10286@http.bugzilla.kernel.org/>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


(switched to email.  Please respond via emailed reply-to-all, not via the
bugzilla web interface).

On Tue, 22 Jul 2008 12:45:54 -0700 (PDT)
bugme-daemon@bugzilla.kernel.org wrote:

> http://bugzilla.kernel.org/show_bug.cgi?id=11147
> 
>            Summary: tg3 + jumbo frames + scatter-gather == inoperative NIC
>            Product: Drivers
>            Version: 2.5
>      KernelVersion: 2.6.25.9
>           Platform: All
>         OS/Version: Linux
>               Tree: Mainline
>             Status: NEW
>           Severity: normal
>           Priority: P1
>          Component: Network
>         AssignedTo: jgarzik@pobox.com
>         ReportedBy: jnelson-kernel-bugzilla@jamponi.net
> 
> 
> Latest working kernel version: n/a
> Earliest failing kernel version: 2.6.25.9
> Distribution: openSUSE 11.0
> Hardware Environment: 32bit x86 (AMD Athlon XP 2200+)
> Software Environment: openSUSE 11.0
> Problem Description:
> 
> When I enable jumbo frames the board still *appears* to work but
> nobody can communicate with it. The other machines (multiple) in the
> network don't see ANY traffic FROM the tg3.  On the machine with the
> tg3, tcpdump shows arp requests (from the other machines) and arp
> replies.
> 
> After much work, I have determined the problem to be a combination of
> scatter-gather and jumbo frames. When both are used, the card does not
> work correctly. Disabling *either* appears to work but no benefit is
> realized until the interface is brought down and back up again.
> 
> An "ethtool -t eth0" shows a single failed test (registers). I have a
> register dump and anything else anybody might want if this can be
> useful in bug-fixing.
> 
> I also saw this:
> 
> tg3: DEBUG: MAC_TX_STATUS[00000008] MAC_RX_STATUS[00000006]
> tg3: DEBUG: RDMAC_STATUS[00000000] WDMAC_STATUS[00000000]
> tg3: tg3_stop_block timed out, ofs=1400 enable_bit=2
> tg3: tg3_stop_block timed out, ofs=c00 enable_bit=2
> 
> 
> Steps to reproduce:
> 
> I've also tried the tg3.[c,h] compiled against 2.6.25.9 but using the latest
> git source from either linux-2.6 or netdev-2.6 as of 17 July 2008.
> 
> tg3.c:v3.92.1 (June 9, 2008)
> the tg3.c sha1sum is 97c198a8152045f2e7da5fe0d702df1cd185cb8d.
> 
> 

