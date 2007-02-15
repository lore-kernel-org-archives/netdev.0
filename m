From: Holger Eitzenberger <holger@my-eitzenberger.de>
Subject: sky2 bonding problem, 802.3ad
Date: Thu, 15 Feb 2007 19:55:42 +0100
Message-ID: <871wkruu6p.fsf@kruemel.my-eitzenberger.de>
Mime-Version: 1.0
Content-Type: multipart/mixed; boundary="=-=-="
Cc: sk-drivers@lists.linux-foundation.org, netdev@vger.kernel.org
To: shemminger@linux-foundation.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from moutng.kundenserver.de ([212.227.126.186]:61547 "EHLO
	moutng.kundenserver.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1030557AbXBOSzx (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 15 Feb 2007 13:55:53 -0500
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

--=-=-=

Hi Steven,

I have problems using sky2 v1.10 with with bonding driver (802.3ad),
on 'Marvell 88E8053 PCI-E Gigabit Ethernet Controller'.  I have attached
the full lspci output.

My test was to setup a bond of two physical links (both links same
hardware) and ping 192.168.11.10, which is the address of the switch
itself.

I have tested v1.10 with kernel 2.6.19 and 2.6.16.36 (own backport),
which despite the bonding problem runs fine.  Both, kernel 2.6.19 and
2.6.16.36 show the same behaviour.  The 802.3ad aware switch is a Dell
PowerConnect 5324.  VLAN is not configured on all switch ports.  Another
test on a host running kernel 2.6.18.2 with two e1000's bonded runs
fine.  Using sk98lin (v8.41 & v10.0.4) worked also.

The host containing the Yukon-II has a total of 8 NICs, 4 PIC and 4
PCI-E, see attached lspci output.  The failed bond was created from two
PCI-E interfaces.

Find attached a short script which I use to set up the bond on both hosts,
also attached is a procfile (/proc/net/bonding/bond0) from
the "e1000 host" with a working bond as well as the procfile from the host
with the Yukon-II cards.

When looking at the working bond I see that both slave interfaces are
IFF_UP, the load is shared over both links.  When looking at the failing
sky2 bond I see that the bond is not IFF_UP, whereas both slave
interfaces are IFF_UP.  The 802.3ad "partner MAC address" is left all zero's, 
also both interfaces have different Aggregator IDs (1 & 2).  One of the
two failing interfaces always has IFF_NOARP set, caused by code
calling bond_main.c:bond_set_slave_inactive_flags().

I used both use_carrier=1 (default) as well as miimon=50 without luck.

Going through the bonding code, and comparing sky2 source to the e100
code, which I am quite familiar with, I see that sky2 does not use the
generic MII interface, which might point in the right direction.

I am currently going through the bonding code and try to understand the
master <-> slave <-> sky2 interaction, basically this is either through
calling the sky2 net_device ops and through the ethtool ops.

If you need further info or further testing from my side: i will gladly
do that.

Besides that, thanks for a great driver!

   /holger


--=-=-=
Content-Type: application/x-gtar
Content-Disposition: attachment; filename=bonding-prob.tgz
Content-Transfer-Encoding: base64
Content-Description: bonding-prob.tgz

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
--=-=-=--
