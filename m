From: Ferenc Wagner <wferi@niif.hu>
Subject: IP-less bridge as a martian source
Date: Tue, 21 Oct 2008 14:06:48 +0200
Message-ID: <87tzb6nodj.fsf@tac.ki.iif.hu>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: wferi@niif.hu
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from tac.ki.iif.hu ([193.6.222.43]:55576 "EHLO tac.ki.iif.hu"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751937AbYJUNAm (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 21 Oct 2008 09:00:42 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi,

I expected an IP-less bridge interface to pick up no IP packets, but
apparently this isn't the case: broadcast packets with destination
address 255.255.255.255 are reported as martians by the 2.6.18
kernel, which I find counterintuitive (I know 2.6.18 is rather old,
but that's the one supported by Xen).

  1. Is this the expected behaviour?

  2. I tried to cut down the logs by explicit iptables drops, but
     didn't succeed.  Does martian detection happen before the
     netfilter rules?  (I know I can disable martian logging by
     interface, but wanted finer granularity.)

If somebody could also enlighten me on the following, I'd be very
grateful.  My setup consists of two Xen hosts, both with two physical
Ethernet interfaces aggregated into active-backup bonds.  There are
several .1q VLAN interfaces built on the bonds, which are put into
per-VLAN bridges.  The virtual interfaces of the Xen guest machines
are also put into these bridges, so each virtual interface sees the
native traffic of the corresponding VLAN.

In a specific scenario, I've got two guests running on different
hosts, connecting to VLAN 891:

xen2:~# brctl show
bridge name	bridge id		STP enabled	interfaces
br891		8000.00065b8e7272	no		vlan891
							vif5.0
xen1:~# brctl show
bridge name	bridge id		STP enabled	interfaces
br891		8000.00065b8e71d5	no		vif12.0
							vlan891

If I issue the ping -c1 -b 255.255.255.255 on either Xen guest
(remember, they are running on different hosts), the xen2 host logs
one martian packet "on dev br891", while the xen1 host logs two!

  3. Can anybody explain this? :)

I'm experiencing other strange things (like ARP replies sometimes not
getting through the bridges), but let's start with the above...

(Please Cc me, I'm not on the list.)
-- 
Thanks,
Feri.
