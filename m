From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [Bugme-new] [Bug 11571] New: u32_classify Kernel Panic
Date: Tue, 16 Sep 2008 09:15:08 -0700
Message-ID: <20080916091508.a0cd830e.akpm@linux-foundation.org>
References: <bug-11571-10286@http.bugzilla.kernel.org/>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: bugme-daemon@bugzilla.kernel.org, m0sia@plotinka.ru
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp1.linux-foundation.org ([140.211.169.13]:47350 "EHLO
	smtp1.linux-foundation.org" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1753187AbYIPQUT (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 16 Sep 2008 12:20:19 -0400
In-Reply-To: <bug-11571-10286@http.bugzilla.kernel.org/>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


(switched to email.  Please respond via emailed reply-to-all, not via the
bugzilla web interface).

On Mon, 15 Sep 2008 03:35:16 -0700 (PDT) bugme-daemon@bugzilla.kernel.org wrote:

> http://bugzilla.kernel.org/show_bug.cgi?id=11571
> 
>            Summary: u32_classify Kernel Panic
>            Product: Networking
>            Version: 2.5
>      KernelVersion: 2.6.26.5
>           Platform: All
>         OS/Version: Linux
>               Tree: Mainline
>             Status: NEW
>           Severity: high
>           Priority: P1
>          Component: Other
>         AssignedTo: acme@ghostprotocols.net
>         ReportedBy: m0sia@plotinka.ru
> 
> 
> Distribution: Debian
> 
> Problem Description:
> Kernel panic
> [<c023f2d8>]    dev_queue_xmit+0x175/0x2a1
> [<c0243861>]    neigh_resolve_output+0x1f8/0x2la
> [<c025a784>]    ip_finish_output+0x1d7/0x200
> [<c025aa2f>]    ip_output+0x6f/0x81
> [<c0258218>]    ip_forwardjinish+0x2c/0x2e
> [<c0257223>]    ip_rcv_f inish+0x263/0x27f
> [<c023cc62>]    netif_receive_skb+0x2c1/0x32b
> [<f886f26d>]    e1000_clean_rx_irq+0x395/0x46f [e1000]
> [<f886f5f7>]    e1000_clean+0x52/0x1db [e1000]
> [<c013e8e4>]    net_rx_action+0x8a/0x153
> [<c0128bfa>]    __do_softirq+0x5d/0xc1
> [<c0128c98>]    do_softirq+0x32/0x36
> [<c0185cb8>]    do_IRQ+0x52/0x66
> [<c01887fa>]    mwait_idle+0x8/0x32
> [<c018418b>]    common_interrupt+0x23/0x28
> [<c01887fa>]    mwait_idle+0xB/0x32
> [<c0188829>]    muait_idle+0x2f/0x32
> [<c0182545>]    cpu_ i d1e+0x88/0x9c
> 
> 
> Code: 0c 8b 80 90 00 00 00 c7 44 24 14 00 00 00 00 c7 44 24 18 00 00 00 00 89
> 44 
> 24 18 8b 54 24 0c 8b 74 aa 18 85 f6 0f 84 a0 01 00 00 <8b> 46 38 83 00 01 83 50 
> 04 00 8b 4c 24 04 8b 46 38 23 81 88 00
> EIP: [<f8bf3670>] u32_classify+0x41/0x23f [cls_u32] SS:ESP 8868:f746fd44
> Kernel panic - not syncing: Fatal exception in interrupt
> 
> Steps to reproduce:
> 
> tc qdisc add dev eth1 root handle 1: htb 
> 
> tc class add dev eth1 parent 1: classid 1:1 htb rate 3600Kbit
> tc class add dev eth1 parent 1:1 classid 1:11 htb rate 2800Kbit prio 0
> tc class add dev eth1 parent 1:1 classid 1:15 htb rate 100Kbit ceil 2800Kbit
> prio 0
> tc class add dev eth1 parent 1:1 classid 1:19 htb rate 100Kbit ceil 500Kbit
> prio 2
> 
> 
> N from 10 to 2000
> tc class add dev eth1 parent 1:{11,15,19} classid 1:$N htb rate 1Kbit ceil
> {$SPEED}Kbit
> tc filter add dev eth1 parent 1: protocol ip pref $N u32 match ip dst $IP
> flowid 1:$N
> 
> Everything worked with N smaller then 2000. The problem first acquired with
> kernel 2.6.18-6-686 and is still present in 2.6.26.5
> 
> 
> -- 
> Configure bugmail: http://bugzilla.kernel.org/userprefs.cgi?tab=email
> ------- You are receiving this mail because: -------
> You are on the CC list for the bug, or are watching someone who is.
