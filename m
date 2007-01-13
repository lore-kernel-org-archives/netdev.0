From: Andrew Morton <akpm@osdl.org>
Subject: Re: [Bugme-new] [Bug 7817] New: commit
 edfe21a29b1dca9ce5a938317868066d2e21c385 breaks IPv6 address
 autoconfiguration
Date: Sat, 13 Jan 2007 13:45:06 -0800
Message-ID: <20070113134506.6021cf79.akpm@osdl.org>
References: <200701131344.l0DDidDq007345@fire-2.osdl.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: yoshfuji@linux-ipv6.org, gernoth@informatik.uni-erlangen.de,
	"bugme-daemon@kernel-bugs.osdl.org"
	<bugme-daemon@bugzilla.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp.osdl.org ([65.172.181.24]:52703 "EHLO smtp.osdl.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1750931AbXAMVpQ (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sat, 13 Jan 2007 16:45:16 -0500
To: netdev@vger.kernel.org
In-Reply-To: <200701131344.l0DDidDq007345@fire-2.osdl.org>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

> On Sat, 13 Jan 2007 05:44:39 -0800 bugme-daemon@bugzilla.kernel.org wrote:
> http://bugzilla.kernel.org/show_bug.cgi?id=7817
> 
>            Summary: commit edfe21a29b1dca9ce5a938317868066d2e21c385 breaks
>                     IPv6 address autoconfiguration
>     Kernel Version: 2.6.19.2
>             Status: NEW
>           Severity: high
>              Owner: yoshfuji@linux-ipv6.org
>          Submitter: gernoth@informatik.uni-erlangen.de
> 
> 
> Most recent kernel where this bug did *NOT* occur: 2.6.19.1
> Distribution: Debian Testing
> Hardware Environment: About 100 different x86 boxes
> Software Environment: no special software involved, just the kernel. No modules are loaded on the 
> affected machines (everything needed is built into the kernel)
> 
> Problem Description:
> After booting kernel 2.6.19.2 on our machines they no longer do IPv6 address autoconfiguration, 
> although router advertisments can be seen on that interface:
> 14:19:14.254410 fe80::212:1eff:fe08:e040 > ip6-allnodes: icmp6: router advertisement(chlim=64, 
> pref=medium, router_ltime=1800, reachable_time=0, retrans_time=0)(src lladdr: 00:12:1e:08:e0:40)
> [ndp opt] (len 56, hlim 255)
> 
> ip -6 addr output is:
> 1: eth0: <BROADCAST,MULTICAST,UP,10000> mtu 1500 qlen 1000
>     inet6 fe80::209:3dff:fe10:ccda/64 scope link
>        valid_lft forever preferred_lft forever
> 2: eth1: <BROADCAST,MULTICAST,UP,10000> mtu 1500 qlen 1000
>     inet6 fe80::209:3dff:fe10:ccdb/64 scope link
>        valid_lft forever preferred_lft forever
> 3: lo: <LOOPBACK,UP,10000> mtu 16436
>     inet6 ::1/128 scope host
>        valid_lft forever preferred_lft forever
> (eth0 sees the advertisments)
> 
> Manually setting the address and default-route works.
> Reverting commit edfe21a29b1dca9ce5a938317868066d2e21c385 fixes this problem.
> 
> Steps to reproduce:
> 1. Upgrade to 2.6.19.2
> 2. Configure an interface for IPv4
> 3. The linklocal IPv6 address for the interface appears in ip -6 addr
> 4. Wait for a router advertisment
> 5. No Global IPv6 address and no IPv6 default route is set
> 
> ------- You are receiving this mail because: -------
> You are on the CC list for the bug, or are watching someone who is.
