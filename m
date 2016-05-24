From: Patrick Schaaf <netdev@bof.de>
Subject: kernel panic with kernel 3.14.70, LVS on keepalived restart
Date: Tue, 24 May 2016 17:44:13 +0200
Message-ID: <2116485.usCtNS6d1V@rofl>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7Bit
To: NETDEV <netdev@vger.kernel.org>, lvs-users@linuxvirtualserver.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mars.intermailgate.com ([80.242.145.70]:51352 "EHLO
	mars.intermailgate.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752466AbcEXPoS (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 24 May 2016 11:44:18 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Dear LVS users / netdev readers,

today I've got a pretty peculiar problem.

I've been running 3.14.48 (and some earlier 3.14 kernels) for a long time now 
in an LVS / keepalived driven loadbalancing cluster. See below for more detail 
on the setup.

Today I started to upgrade to the current 3.14.70 kernel. At first glance 
everything seems fine, I can failover _to_ the box with the new kernel, and 
traffic is flowing fine.

However, when I then switch BACK to a different box, the 3.14.70 kernel 
crashes. I've got an incomplete console dump (IPMI avi capture, single 
frame...) you can see here:

 https://plus.google.com/u/0/photos/photo/114613285248943487324/6288270822391242162

I usually manually failover by (having some automation) fiddle with 
keepalived.conf VRRP priority settings, then restart the daemon.

The issue / reboot only manifests when I RESTART the ACTIVE keepalived. It 
always happens, then, with 3.14.70. That never happened before.

On the other hand just reloading keepalived, with the prio-modified config, 
works fine!

As I don't remember why I restarted instead of reloading, I can for now change 
my automation easily - but the issue is weird anyway.

More info on the setup:

1) kernel is vanilla 3.14.70 (and was vanilla 3.14.48 without the issue), with 
a single (self written) patch to bonding applied (see 
http://permalink.gmane.org/gmane.linux.network/316758). Unfortunately I cannot 
live without that patch, i.e. can't try to reproduce with a pure vanilla 
vanilla kernel.

2) keepalived is 1.2.13

3) config uses "use_vmac" / "vmac_xmit_base", on multiple interfaces, i.e. 
MACVLAN interfaces on top of:

4) "normal" interfaces are both bridge-over-VLAN-over-LACP-bond-over-eth and 
ARP-bond-over-VLAN-over-eth

5) there is active conntracking including conntrackd (but excluding LVS 
state), LVS loadbalancing of some 15k pps, LVS sync, and heavy iptables use 
including ipset matching, going on. Just for completeness.

Anybody got any idea what the root cause might be?

best regards
  Patrick
