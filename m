From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [Bugme-new] [Bug 33842] New: NULL pointer dereference in
 ip_fragment
Date: Mon, 25 Apr 2011 21:29:40 -0700
Message-ID: <20110425212940.a2e9dad7.akpm@linux-foundation.org>
References: <bug-33842-10286@https.bugzilla.kernel.org/>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: bugzilla-daemon@bugzilla.kernel.org,
	bugme-daemon@bugzilla.kernel.org, tom@dbservice.com
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp1.linux-foundation.org ([140.211.169.13]:43520 "EHLO
	smtp1.linux-foundation.org" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1750867Ab1DZEZk (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 26 Apr 2011 00:25:40 -0400
In-Reply-To: <bug-33842-10286@https.bugzilla.kernel.org/>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


(switched to email.  Please respond via emailed reply-to-all, not via the
bugzilla web interface).

On Sat, 23 Apr 2011 07:51:56 GMT bugzilla-daemon@bugzilla.kernel.org wrote:

> https://bugzilla.kernel.org/show_bug.cgi?id=33842
> 
>            Summary: NULL pointer dereference in ip_fragment

oops in ip_defragment().  Kernel is 2.6.39-rc4.  There are some
screenshots attached to the report.


>            Product: Networking
>            Version: 2.5
>           Platform: All
>         OS/Version: Linux
>               Tree: Mainline
>             Status: NEW
>           Severity: normal
>           Priority: P1
>          Component: Other
>         AssignedTo: acme@ghostprotocols.net
>         ReportedBy: tom@dbservice.com
>         Regression: No
> 
> 
> The host is using the ath9k driver. eth0+wlan0 are bridged. Shortly after I
> start using the wireless network with my macbook, the bug triggers. No idea if
> it's wireless related, because there's also a rtl8169_rx_interrupt entry in the
> stacktrace.
> 
> This is a transcript, since I don't (have/know of) any way to get the backtrace
> out of a crashed box.
> 
> IP: ip_fragment+0x52/0x840
> Call Trace:
>   <IRQ>
>   br_parse_ip_options
>   br_flood_deliver
>   br_parse_ip_options
>   br_nf_dev_queue_xmit
>   br_nf_post_routing
>   nf_iterate
> 
> then also:
>   lots of br_flood_deliver
>   lots of br_*_finish
>   one ? rtl8169_interrupt
>   one ? ath9k_ioread32
> 

