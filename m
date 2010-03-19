From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [Bugme-new] [Bug 15530] New: ipip6 MTU cannot be set lower than
 1280
Date: Fri, 19 Mar 2010 14:19:53 -0700
Message-ID: <20100319141953.40316ebb.akpm@linux-foundation.org>
References: <bug-15530-10286@http.bugzilla.kernel.org/>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: bugzilla-daemon@bugzilla.kernel.org,
	bugme-daemon@bugzilla.kernel.org, berni@birkenwald.de
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp1.linux-foundation.org ([140.211.169.13]:33056 "EHLO
	smtp1.linux-foundation.org" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1751265Ab0CSVU7 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 19 Mar 2010 17:20:59 -0400
In-Reply-To: <bug-15530-10286@http.bugzilla.kernel.org/>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


(switched to email.  Please respond via emailed reply-to-all, not via the
bugzilla web interface).

On Sat, 13 Mar 2010 14:38:54 GMT
bugzilla-daemon@bugzilla.kernel.org wrote:

> http://bugzilla.kernel.org/show_bug.cgi?id=15530
> 
>            Summary: ipip6 MTU cannot be set lower than 1280
>            Product: Networking
>            Version: 2.5
>     Kernel Version: 2.6.32
>           Platform: All
>         OS/Version: Linux
>               Tree: Mainline
>             Status: NEW
>           Severity: low
>           Priority: P1
>          Component: IPV6
>         AssignedTo: yoshfuji@linux-ipv6.org
>         ReportedBy: berni@birkenwald.de
>         Regression: No
> 
> 
> The (inner) MTU of a ipip6 (IPv4-in-IPv6) tunnel cannot be set below 1280,
> which is the minimum MTU in IPv6. However, there should be no IPv6 on the
> tunnel interface at all (ipip6 cannot transport it), so the IPv6 rules should
> not apply.
> 
> root@pest:~# ip -6 tunnel add test1 mode ipip6 remote 2001:xxxx::26 local
> 2001:xxx::1:1
> root@pest:~# ip link set test1 mtu 1280
> root@pest:~# ip link set test1 mtu 1279
> RTNETLINK answers: Invalid argument
> 
> This prevents the tunnel from work on paths that only support a (outer) IPv6
> MTU of 1280, since the tunnel adds an additional overhead of 40 bytes.
> 
> Setting net.ipv6.conf.<if>.disable_ipv6=1 and/or removing the IPv6 link-local
> address on the tunnel interface does not help.
> 

