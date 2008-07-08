From: John Morrissey <jwm@horde.net>
Subject: bnx2 hardware VLAN acceleration and PF_PACKET/tap interfaces
Date: Tue, 8 Jul 2008 16:05:08 -0400
Message-ID: <20080708200508.GA19505@boost.horde.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from boost.horde.net ([69.55.65.181]:60562 "EHLO boost.horde.net"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753240AbYGHU1u (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 8 Jul 2008 16:27:50 -0400
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

I'm struggling with VLAN tags being stripped the bnx2 driver/hardware when
hardware VLAN acceleration is enabled.

I'm trying to (a) tcpdump(8) on the main interface and see tagged traffic
and (b) place the main interface into a bridge group and attach a tap
interface to the bridge to give KVM virtual machines access to that
interface. The VMs would then have their own choice of VLANs without having
to create separate VLAN subints, bridge groups, and tap interfaces on the
KVM host for each VLAN that a VM needs access to.

I've seen these threads, which indicate this is due to the implementation
particulars of hardware VLAN acceleration:

http://marc.info/?l=linux-netdev&m=117269169822297&w=2
http://marc.info/?l=linux-netdev&m=119395331216242&w=2

The adapters are "NetXtreme II BCM5708S Gigabit Ethernet rev 12" in IBM
BladeCenter chassis. I've tried disabling the use of ASF_ENABLE_FLAG in
bnx2, but this doesn't seem to have changed its behavior any. The Broadcom
firmware upgarde utility says ASF isn't supported by this chipset when I try
to 'cfg -asf 0', so perhaps this adapter doesn't support ASF and I'm barking
up the wrong tree?

Flailing around, I tried #defining BCM_VLAN to 0 to disable hardware VLAN
acceleration. This breaks the driver build since there's an unguarded use of
struct bnx2->vlgrp in bnx2_start_xmit().

I'm also seeing some tcpdump(8) behavior that I don't understand. When I
tcpdump the main interface (not the VLAN subint), I see only *outbound*
traffic for the last VLAN configured on the interface, and no other traffic.
Is this some side-effect of the hardware VLAN acceleration?

Is there any hope of having this work? I'm working with 2.6.24 (from Ubuntu
8.04 FWIW) and have glanced at the bnx2 driver in 2.6.25, which seems
essentially the same.

john
-- 
John Morrissey          _o            /\         ----  __o
jwm@horde.net        _-< \_          /  \       ----  <  \,
www.horde.net/    __(_)/_(_)________/    \_______(_) /_(_)__
