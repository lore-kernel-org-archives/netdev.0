From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [Bugme-new] [Bug 14839] New: Trying to use a TUN device fir
 IPv6 traffic, cannot set destination address.
Date: Tue, 22 Dec 2009 15:12:38 -0800
Message-ID: <20091222151238.e7e44e36.akpm@linux-foundation.org>
References: <bug-14839-10286@http.bugzilla.kernel.org/>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: bugzilla-daemon@bugzilla.kernel.org,
	bugme-daemon@bugzilla.kernel.org, mcisho@yahoo.com
To: netdev@vger.kernel.org, Maxim Krasnyansky <maxk@qualcomm.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp1.linux-foundation.org ([140.211.169.13]:59524 "EHLO
	smtp1.linux-foundation.org" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1752792AbZLVXNa (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 22 Dec 2009 18:13:30 -0500
In-Reply-To: <bug-14839-10286@http.bugzilla.kernel.org/>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


(switched to email.  Please respond via emailed reply-to-all, not via the
bugzilla web interface).

On Sat, 19 Dec 2009 10:35:18 GMT
bugzilla-daemon@bugzilla.kernel.org wrote:

> http://bugzilla.kernel.org/show_bug.cgi?id=14839
> 
>            Summary: Trying to use a TUN device fir IPv6 traffic, cannot
>                     set destination address.
>            Product: Networking
>            Version: 2.5
>     Kernel Version: 2.6.31.6
>           Platform: All
>         OS/Version: Linux
>               Tree: Mainline
>             Status: NEW
>           Severity: normal
>           Priority: P1
>          Component: IPV6
>         AssignedTo: yoshfuji@linux-ipv6.org
>         ReportedBy: mcisho@yahoo.com
>         Regression: No
> 
> 
> I am modifying a program that uses a TUN device for IPv4 traffic so that the
> same TUN device can also be used for IPv6 traffic. Using ioctl SIOCSIFADDR will
> add an IPv6 address but ioctl SIOCSDSTADDR to add an IPv6 destination address
> always results in error ENODEV (19 No such device).
> 
> I searched around the source and found addrconf_set_dstaddr in addrconf.c which
> seems to be the routine called to set the destination address. However, the
> routine only sets a destination address for a SIT device, otherwise if returns
> ENODEV.
> 
> Below is the ifconfig output for the TUN device:-
> $ ifconfig tun3
> tun3      Link encap:UNSPEC  HWaddr
> 00-00-00-00-00-00-00-00-00-00-00-00-00-00-00-00  
>           inet addr:192.168.3.235  P-t-P:192.168.250.235  Mask:255.255.255.255
>           inet6 addr: fd00::3:235/128 Scope:Global
>           UP POINTOPOINT RUNNING  MTU:1344  Metric:1
>           RX packets:0 errors:0 dropped:0 overruns:0 frame:0
>           TX packets:0 errors:0 dropped:0 overruns:0 carrier:0
>           collisions:0 txqueuelen:500 
>           RX bytes:0 (0.0 b)  TX bytes:0 (0.0 b)
> 
> BTW, ifconfig cannot add an IPv6 destination address either, the code has a
> comment saying that the support needs to be written.
> 
> Can a TUN device be used for IPv6 traffic? I cannot find a definitive answer,
> only 'should'. Or is that nobody has ever wanted to use a TUN device for IPv6
> traffic, and so the kernel support has not been written? Or am I doing
> something wrong?
> 

