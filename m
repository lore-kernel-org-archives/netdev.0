From: Marc Haber <mh+linux-kernel@zugschlus.de>
Subject: IPv6 flapping with kernel 3.3 (regression from 3.2.9)
Date: Thu, 22 Mar 2012 08:34:28 +0100
Message-ID: <20120322073428.GA11510@torres.zugschlus.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
To: linux-kernel@vger.kernel.org, netdev@vger.kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hi,

I have a host which has IPv6 misbehaving when running with Linux 3.3.
It is flawlessly working with Linux 3.2.9.

The host
- is running Debian stable (x64_64) with a few locally built and/or
  backported packages, including the kernel.
- has native IPv6 connectivity on eth0
- is not doing SLAAC on eth0, both IP address (from 2a01/16) and
  default gateway (fe80::1) are statically configured
- is running a handful of VMs using KVM/libvirt
- has IPv6 forwarding enabled
- does IPv4 NAT
- has a handful of iptables rules, both for v4 and v6. ICMP and ICMPv6
  are fully open

- the gateway is not under my control
- the VMs are either bridged to br0 or to br1
- both br0 and br1 have an IPv6 /64 and radvd running to provide IPv6
  to the VMs

This setup is unique in my machine list, my other machines either are
no KVM hosts or do only have IPv6 tunneled.

When I run the box with kernel 3.3, it drops off the IPv6 network
every few minutes and is not responding to pings any more. This state
stays like 30 seconds to a minute and then IPv6 resumes. It looks to
me that the box does not lose its default route though. Once in a
while, I see "fe80::1 dev eth0  router FAILED" in the ip neigh output.

Running a continuous ping in either direction doesn't seem to help.

Booting the box back to 3.2.9 immediately fixes the issue.

I have not yet re-tried going back to 3.3 since a few of the VMs are
too important to reboot again today. I tried running tcpdump on eth0
over night but hit br1 instead, so I don't have any packet dumps to
show.

I guess that something goes wrong with neighbor detection regarding
the IPv6 gateway.

Was there a relevant change between 3.2.9 and 3.3? Where do I look for
the issue?

Greetings
Marc

-- 
-----------------------------------------------------------------------------
Marc Haber         | "I don't trust Computers. They | Mailadresse im Header
Mannheim, Germany  |  lose things."    Winona Ryder | Fon: *49 621 31958061
Nordisch by Nature |  How to make an American Quilt | Fax: *49 621 31958062
