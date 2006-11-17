From: Andrew Morton <akpm@osdl.org>
Subject: Re: [Bugme-new] [Bug 7541] New: dhcp + suspend-to-RAM sometimes
 trashes the NIC
Date: Fri, 17 Nov 2006 00:18:39 -0800
Message-ID: <20061117001839.18d1abe5.akpm@osdl.org>
References: <200611170737.kAH7bI5s010256@fire-2.osdl.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: "bugme-daemon@kernel-bugs.osdl.org"
	<bugme-daemon@bugzilla.kernel.org>, joshua@openheartlogic.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp.osdl.org ([65.172.181.4]:39598 "EHLO smtp.osdl.org")
	by vger.kernel.org with ESMTP id S1424383AbWKQISx (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 17 Nov 2006 03:18:53 -0500
To: netdev@vger.kernel.org
In-Reply-To: <200611170737.kAH7bI5s010256@fire-2.osdl.org>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Thu, 16 Nov 2006 23:37:18 -0800
bugme-daemon@bugzilla.kernel.org wrote:

> http://bugzilla.kernel.org/show_bug.cgi?id=7541
> 
>            Summary: dhcp + suspend-to-RAM sometimes trashes the NIC
>     Kernel Version: 2.6.17.7
>             Status: NEW
>           Severity: normal
>              Owner: shemminger@osdl.org
>          Submitter: joshua@openheartlogic.org
> 
> 
> Most recent kernel where this bug did *NOT* occur: Sorry, dunno
> Distribution: Debian
> Hardware Environment: Fujitsu P-2040 laptop
> Software Environment: dhcp-client 2.0pl5-19.4 (debian)
> Problem Description:
> 
> I have hit this bug ever since I started using DHCP. Prior to DHCP, I never had
> a problem with suspend to RAM.
> 
> Steps to reproduce:
> 
> My laptop travels from home to work and back. Every time I switch on, I run
> "ifdown eth0" and "ifup eth0" to switch to the appropriate network configured
> using DHCP. Usually, this works fine. Here's my ethernet chipset:
> 
> 00:12.0 Ethernet controller: Realtek Semiconductor Co., Ltd.
> RTL-8139/8139C/8139C+ (rev 10)
> 
> Anyway, sometimes, maybe once a week, something goes wrong and I get this error:
> 
> SIOCSIFFLAGS: No such device
> 
> The NIC still exists, see:
> 
> emit:/home/joshua# ifconfig eth0
> eth0      Link encap:Ethernet  HWaddr 00:E0:00:8C:8B:8E
>           inet addr:192.168.0.4  Bcast:192.168.0.255  Mask:255.255.255.0
>           BROADCAST MULTICAST  MTU:1500  Metric:1
>           RX packets:739959 errors:4 dropped:5 overruns:3 frame:0
>           TX packets:441931 errors:0 dropped:0 overruns:2 carrier:0
>           collisions:0 txqueuelen:1000
>           RX bytes:1059867013 (1010.7 MiB)  TX bytes:37902281 (36.1 MiB)
>           Interrupt:9 Base address:0x4800
> 
> However, it's impossible to configure:
> 
> emit:/home/joshua# ifconfig eth0 132.147.1.109 up
> SIOCSIFFLAGS: No such device
> SIOCSIFFLAGS: No such device
> 
> Weird, huh?
