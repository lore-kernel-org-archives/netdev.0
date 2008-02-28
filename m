From: Pavel Krauz <krauz@cncz.cz>
Subject: Re: capturing vlan on 2.6.18
Date: Thu, 28 Feb 2008 12:26:08 +0100
Message-ID: <200802281226.08987.krauz@cncz.cz>
Mime-Version: 1.0
Content-Type: text/plain;
  charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from kwall.cncz.cz ([194.213.192.9]:8548 "EHLO kwall.cncz.cz"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755999AbYB1L0U (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 28 Feb 2008 06:26:20 -0500
Received: from asterix.domain.local (unknown [10.3.1.3])
	by kwall.cncz.cz (Postfix) with ESMTP id 67B68BA883
	for <netdev@vger.kernel.org>; Thu, 28 Feb 2008 12:26:17 +0100 (CET)
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

>> Is this a kernel bug or am I supposed to set something?
> It's an unfortunate side effect of hardware VLAN acceleration. It
> can't be turned off (apart from patching the driver to not advertise
> VLAN acceleration support).

For our ethernet monitoring this is a fatal problem. I have a traffic which
contains both the packets without VLAN and packets with different 
VLAN ids over single ethernet interface, and I am unable do distinguish
them now.
Also all our applications from 2.4 kernel expecting VLAN tag are unable
to filter on VLAN or get the information about VLAN tags for the user.

If we want to use 2.6 kernel we would have to patch drivers ourselfs
which we do not like to do at all for production system. And it will not be
available if we use Redhat AS for those who want a support.

I think that enabling VLAN tags shall be at least kernel run-time or boot time
 configurable option.

For a test I have tried to enable VLAN tags in the Broadcom NX2 network driver (drivers/net/bnx2.c)
and I got the VLAN back. Can you tell me if this is the correct way:

--- bnx2.c.bak  2008-02-28 11:47:29.000000000 +0100
+++ bnx2.c      2008-02-28 11:47:43.000000000 +0100
@@ -2039,6 +2039,7 @@
 #endif
        if (dev->flags & IFF_PROMISC) {
                /* Promiscuous mode. */
+               rx_mode |= BNX2_EMAC_RX_MODE_KEEP_VLAN_TAG;
                rx_mode |= BNX2_EMAC_RX_MODE_PROMISCUOUS;
                sort_mode |= BNX2_RPM_SORT_USER0_PROM_EN;
        }


I also tried to comment out the   dev->features |= NETIF_F_HW_VLAN_TX | NETIF_F_HW_VLAN_RX 
but the driver stopped working
if I undefined BCM_VLAN and made it compile, the VLAN was not present.

Thanks
Pavel

