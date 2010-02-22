From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [Bugme-new] [Bug 15342] New: max_address parameter is not taken
 into consideration when IPv6 addresses are created
Date: Mon, 22 Feb 2010 13:08:58 -0800
Message-ID: <20100222130858.3c186888.akpm@linux-foundation.org>
References: <bug-15342-10286@http.bugzilla.kernel.org/>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: bugzilla-daemon@bugzilla.kernel.org,
	bugme-daemon@bugzilla.kernel.org, nedyalkor@gmail.com
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp1.linux-foundation.org ([140.211.169.13]:45406 "EHLO
	smtp1.linux-foundation.org" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1753153Ab0BVVKJ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 22 Feb 2010 16:10:09 -0500
In-Reply-To: <bug-15342-10286@http.bugzilla.kernel.org/>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


(switched to email.  Please respond via emailed reply-to-all, not via the
bugzilla web interface).

On Wed, 17 Feb 2010 14:12:28 GMT bugzilla-daemon@bugzilla.kernel.org wrote:

> http://bugzilla.kernel.org/show_bug.cgi?id=15342
> 
>            Summary: max_address parameter is not taken into consideration
>                     when IPv6 addresses are created
>            Product: Networking
>            Version: 2.5
>     Kernel Version: 2.6.32.5
>           Platform: All
>         OS/Version: Linux
>               Tree: Mainline
>             Status: NEW
>           Severity: low
>           Priority: P1
>          Component: IPV6
>         AssignedTo: yoshfuji@linux-ipv6.org
>         ReportedBy: nedyalkor@gmail.com
>         Regression: No
> 
> 
> >From ip-sysctl.txt file in kernel documentation I can see following description
> for max_addresses:
> max_addresses - INTEGER
>         Number of maximum addresses per interface.  0 disables limitation.
>         It is recommended not set too large value (or 0) because it would
>         be too easy way to crash kernel to allow to create too much of
>         autoconfigured addresses.
>         Default: 16
> 
> On my machine all parameters are set to default value 16:
> # sysctl -a|grep max_addresses
> net.ipv6.conf.all.max_addresses = 16
> net.ipv6.conf.default.max_addresses = 16
> net.ipv6.conf.lo.max_addresses = 16
> net.ipv6.conf.eth0.max_addresses = 16
> 
> To my understanding I should not be able to create more than 16 IP addresses,
> but in fact I am able do it:
> 
> # for i in `seq 1 16`; do ip addr add fec0::$i/64 dev eth0; done
> # ip addr add fec0::17/64 dev eth0
> # ip -6 addr
> 1: lo: <LOOPBACK,UP,LOWER_UP> mtu 16436
>     inet6 ::1/128 scope host
>        valid_lft forever preferred_lft forever
> 2: eth0: <BROADCAST,MULTICAST,UP,LOWER_UP> mtu 1500 qlen 1000
>     inet6 fec0::17/64 scope site
>        valid_lft forever preferred_lft forever
>     inet6 fec0::16/64 scope site
>        valid_lft forever preferred_lft forever
>     inet6 fec0::15/64 scope site
>        valid_lft forever preferred_lft forever
>     inet6 fec0::14/64 scope site
>        valid_lft forever preferred_lft forever
>     inet6 fec0::13/64 scope site
>        valid_lft forever preferred_lft forever
>     inet6 fec0::12/64 scope site
>        valid_lft forever preferred_lft forever
>     inet6 fec0::11/64 scope site
>        valid_lft forever preferred_lft forever
>     inet6 fec0::10/64 scope site
>        valid_lft forever preferred_lft forever
>     inet6 fec0::9/64 scope site
>        valid_lft forever preferred_lft forever
>     inet6 fec0::8/64 scope site
>        valid_lft forever preferred_lft forever
>     inet6 fec0::7/64 scope site
>        valid_lft forever preferred_lft forever
>     inet6 fec0::6/64 scope site
>        valid_lft forever preferred_lft forever
>     inet6 fec0::5/64 scope site
>        valid_lft forever preferred_lft forever
>     inet6 fec0::4/64 scope site
>        valid_lft forever preferred_lft forever
>     inet6 fec0::3/64 scope site
>        valid_lft forever preferred_lft forever
>     inet6 fec0::2/64 scope site
>        valid_lft forever preferred_lft forever
>     inet6 fec0::1/64 scope site
>        valid_lft forever preferred_lft forever
>     inet6 fe80::223:aeff:fe77:44ba/64 scope link
>        valid_lft forever preferred_lft forever
> 
>
> If this parameter applies only for auto-configured IP addressed, please state
> it more clearly in docs or rename the parameter to show that it refers to
> auto-configuration.
> 
