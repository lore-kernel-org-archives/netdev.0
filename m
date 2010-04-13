From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [Bugme-new] [Bug 15777] New: Changing MTU after enabling
 GSO/GRO breaks incoming IPv6 neighbour discovery
Date: Tue, 13 Apr 2010 12:37:31 -0700
Message-ID: <20100413123731.63a31ff7.akpm@linux-foundation.org>
References: <bug-15777-10286@https.bugzilla.kernel.org/>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: bugzilla-daemon@bugzilla.kernel.org,
	bugme-daemon@bugzilla.kernel.org, roman@rm.pp.ru
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp1.linux-foundation.org ([140.211.169.13]:39919 "EHLO
	smtp1.linux-foundation.org" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1751737Ab0DMTik (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 13 Apr 2010 15:38:40 -0400
In-Reply-To: <bug-15777-10286@https.bugzilla.kernel.org/>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


(switched to email.  Please respond via emailed reply-to-all, not via the
bugzilla web interface).

On Tue, 13 Apr 2010 16:17:44 GMT
bugzilla-daemon@bugzilla.kernel.org wrote:

> https://bugzilla.kernel.org/show_bug.cgi?id=15777
> 
>            Summary: Changing MTU after enabling GSO/GRO breaks incoming
>                     IPv6 neighbour discovery
>            Product: Networking
>            Version: 2.5
>     Kernel Version: 2.6.33
>           Platform: All
>         OS/Version: Linux
>               Tree: Mainline
>             Status: NEW
>           Severity: normal
>           Priority: P1
>          Component: IPV6
>         AssignedTo: yoshfuji@linux-ipv6.org
>         ReportedBy: roman@rm.pp.ru
>         Regression: No
> 
> 
> I have discovered that on one machine, if I enable either GSO or GRO (with
> ethtool -K), and then change the interface MTU, the machine ceases to be IPv6
> neighbour-discoverable. After the following commands:
> 
>   ethtool -K eth0 gro on gso on # doesn't matter which of them, or both
>   ifconfig eth0 mtu 4082
> 
> the machine is no longer ping6'able from LAN by "new" hosts (which haven't seen
> it recently) -- until something ELSE is adjusted on the same interface of that
> machine, e.g. the following command helps (I don't know why, the PROMISC mode
> is already disabled when it runs):
> 
>   ifconfig eth0 -promisc
> 
> The NIC (using the "skge" driver):
> 
>   00:08.0 Ethernet controller: 3Com Corporation 3c940 10/100/1000Base-T
> [Marvell] (rev 10)
> 
> The system is a  Debian Squeeze with 2.6.33 kernel and ethtool 2.6.33.
> 
> The issue is 100% reproducible.

