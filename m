From: Maciej Rutecki <maciej.rutecki@gmail.com>
Subject: Re: IPv6 flapping with kernel 3.3 (regression from 3.2.9)
Date: Sun, 25 Mar 2012 08:43:44 +0200
Message-ID: <201203250843.45055.maciej.rutecki@gmail.com>
References: <20120322073428.GA11510@torres.zugschlus.de>
Reply-To: maciej.rutecki@gmail.com
Mime-Version: 1.0
Content-Type: Text/Plain;
  charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: linux-kernel@vger.kernel.org, netdev@vger.kernel.org
To: Marc Haber <mh+linux-kernel@zugschlus.de>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-we0-f174.google.com ([74.125.82.174]:35588 "EHLO
	mail-we0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751555Ab2CYGnu (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 25 Mar 2012 02:43:50 -0400
In-Reply-To: <20120322073428.GA11510@torres.zugschlus.de>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On czwartek, 22 marca 2012 o 08:34:28 Marc Haber wrote:
> Hi,
> 
> I have a host which has IPv6 misbehaving when running with Linux 3.3.
> It is flawlessly working with Linux 3.2.9.
> 
> The host
> - is running Debian stable (x64_64) with a few locally built and/or
>   backported packages, including the kernel.
> - has native IPv6 connectivity on eth0
> - is not doing SLAAC on eth0, both IP address (from 2a01/16) and
>   default gateway (fe80::1) are statically configured
> - is running a handful of VMs using KVM/libvirt
> - has IPv6 forwarding enabled
> - does IPv4 NAT
> - has a handful of iptables rules, both for v4 and v6. ICMP and ICMPv6
>   are fully open
> 
> - the gateway is not under my control
> - the VMs are either bridged to br0 or to br1
> - both br0 and br1 have an IPv6 /64 and radvd running to provide IPv6
>   to the VMs
> 
> This setup is unique in my machine list, my other machines either are
> no KVM hosts or do only have IPv6 tunneled.
> 
> When I run the box with kernel 3.3, it drops off the IPv6 network
> every few minutes and is not responding to pings any more. This state
> stays like 30 seconds to a minute and then IPv6 resumes. It looks to
> me that the box does not lose its default route though. Once in a
> while, I see "fe80::1 dev eth0  router FAILED" in the ip neigh output.
> 
> Running a continuous ping in either direction doesn't seem to help.
> 
> Booting the box back to 3.2.9 immediately fixes the issue.
> 
> I have not yet re-tried going back to 3.3 since a few of the VMs are
> too important to reboot again today. I tried running tcpdump on eth0
> over night but hit br1 instead, so I don't have any packet dumps to
> show.
> 
> I guess that something goes wrong with neighbor detection regarding
> the IPv6 gateway.
> 
> Was there a relevant change between 3.2.9 and 3.3? Where do I look for
> the issue?
> 
> Greetings
> Marc

I created a Bugzilla entry at 
https://bugzilla.kernel.org/show_bug.cgi?id=42991
for your bug/regression report, please add your address to the CC list in 
there, thanks!

-- 
Maciej Rutecki
http://www.mrutecki.pl
