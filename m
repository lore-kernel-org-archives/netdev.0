From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [Bugme-new] [Bug 19492] New: sky2 wake on line stopped working
 in 2.6.34/2.6.35
Date: Mon, 4 Oct 2010 15:14:04 -0700
Message-ID: <20101004151404.df90d70b.akpm@linux-foundation.org>
References: <bug-19492-10286@https.bugzilla.kernel.org/>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: bugzilla-daemon@bugzilla.kernel.org,
	bugme-daemon@bugzilla.kernel.org, netdev@vger.kernel.org,
	Stephen Hemminger <shemminger@vyatta.com>,
	Ben Hutchings <bhutchings@solarflare.com>
To: arekm@maven.pl
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp1.linux-foundation.org ([140.211.169.13]:59955 "EHLO
	smtp1.linux-foundation.org" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1751560Ab0JDWOh (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 4 Oct 2010 18:14:37 -0400
In-Reply-To: <bug-19492-10286@https.bugzilla.kernel.org/>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


(switched to email.  Please respond via emailed reply-to-all, not via the
bugzilla web interface).

On Sat, 2 Oct 2010 08:30:14 GMT
bugzilla-daemon@bugzilla.kernel.org wrote:

> https://bugzilla.kernel.org/show_bug.cgi?id=19492
> 
>            Summary: sky2 wake on line stopped working in 2.6.34/2.6.35
>            Product: Drivers
>            Version: 2.5
>     Kernel Version: 2.6.34, 2.6.35
>           Platform: All
>         OS/Version: Linux
>               Tree: Mainline
>             Status: NEW
>           Severity: normal
>           Priority: P1
>          Component: Network
>         AssignedTo: drivers_network@kernel-bugs.osdl.org
>         ReportedBy: arekm@maven.pl
>         Regression: Yes
> 

A regression.

> sky2 WOL feature stopped working in 2.6.34 kernel. It was working fine in
> 2.6.33. ethtool 2.6.35 (and some earlier version before).
> 
> # ethtool -s eth0 wol g
> # ethtool eth0|grep Wake
>         Supports Wake-on: pg
>         Wake-on: g
> # ethtool -i eth0
> driver: sky2
> version: 1.28
> firmware-version: N/A
> bus-info: 0000:05:00.0
> # poweroff
> 
> When googling for solution I found /sys/class/net/eth0/device/power/wakeup
> which contains "disabled" before AND after I run ethtool. So I echoed "enabled"
> there, too but it didn't help. The machine doesn't wake up on magick packet.
> 
> ...
>

I can't immediately see any recent changes to the driver in that area
apart from "ethtool: Change ethtool_op_set_flags to validate flags". 
Perhaps you could run

	strace -f ethtool -s eth0 wol g

and see if it's getting an error when setting WOL mode.  If so, ethtool
is broken ;)

