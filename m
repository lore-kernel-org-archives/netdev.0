From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [Bugme-new] [Bug 35862] New: arp requests from wrong src IP
Date: Wed, 25 May 2011 16:31:37 -0700
Message-ID: <20110525163137.6f04f26e.akpm@linux-foundation.org>
References: <bug-35862-10286@https.bugzilla.kernel.org/>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: bugzilla-daemon@bugzilla.kernel.org,
	bugme-daemon@bugzilla.kernel.org, matare@lih.rwth-aachen.de
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp1.linux-foundation.org ([140.211.169.13]:38169 "EHLO
	smtp1.linux-foundation.org" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1754156Ab1EYXcF (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 25 May 2011 19:32:05 -0400
In-Reply-To: <bug-35862-10286@https.bugzilla.kernel.org/>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


(switched to email.  Please respond via emailed reply-to-all, not via the
bugzilla web interface).

On Wed, 25 May 2011 23:27:48 GMT
bugzilla-daemon@bugzilla.kernel.org wrote:

> https://bugzilla.kernel.org/show_bug.cgi?id=35862
> 
>            Summary: arp requests from wrong src IP
>            Product: Networking
>            Version: 2.5
>           Platform: All
>         OS/Version: Linux
>               Tree: Mainline
>             Status: NEW
>           Severity: normal
>           Priority: P1
>          Component: IPV4
>         AssignedTo: shemminger@linux-foundation.org
>         ReportedBy: matare@lih.rwth-aachen.de
>         Regression: No
> 
> 
> I switched a host's ip address from 137.226.164.13 to 137.226.164.2. The .13 IP
> now belongs to the host that had .2 before (I swapped them). Now both hosts
> still arp from their old IPs although ifconfig as well as ip clearly tell
> otherwise. Examining the host which now has 137.226.164.13:
> 
> # ip addr show dev eth0
> 4: eth0: <BROADCAST,MULTICAST,UP,LOWER_UP> mtu 1500 qdisc mq state UP qlen 1000
>     link/ether 00:e0:81:41:1f:e4 brd ff:ff:ff:ff:ff:ff
>     inet 137.226.164.2/24 brd 137.226.164.255 scope global eth0
>     inet 192.168.23.2/24 brd 137.226.164.255 scope global eth0:0
> 
> but arping defaults to the old src IP (.13). I can manually correct this with
> the -s parameter, but it looks like linux still believes that 137.226.164.13 is
> this host's ip address. When I try to manually correct the arp table:
> # arp -s 137.226.164.13 00:30:48:70:91:95
> SIOCSARP: Invalid argument
> # arp -n 137.226.164.13
> 137.226.164.13 (137.226.164.13) -- no entry
> 
> And this is what arping does:
> # tcpdump -ieth0 -c1 -s0 -vvv -n arp & (sleep 1; arping 137.226.164.13 &>
> /dev/null)
> [1] 2217
> tcpdump: listening on eth0, link-type EN10MB (Ethernet), capture size 65535
> bytes
> 01:14:37.785126 arp who-has 137.226.164.13 (ff:ff:ff:ff:ff:ff) tell
> 137.226.164.13
> 
> Also, ifconfig doesn't even show the second IP address:
> # ifconfig eth0
> eth0      Link encap:Ethernet  HWaddr 00:e0:81:41:1f:e4  
>           inet addr:137.226.164.2  Bcast:137.226.164.255  Mask:255.255.255.0
>           UP BROADCAST RUNNING MULTICAST  MTU:1500  Metric:1
>           RX packets:103996345 errors:0 dropped:0 overruns:0 frame:0
>           TX packets:122352625 errors:0 dropped:0 overruns:0 carrier:0
>           collisions:0 txqueuelen:1000 
>           RX bytes:52478932087 (48.8 GiB)  TX bytes:110248931949 (102.6 GiB)
>           Interrupt:24
> 
> What's going on here? If this is by design, it's very unintuitive behaviour.
> 

