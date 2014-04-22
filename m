From: "K. Y. Srinivasan" <kys@microsoft.com>
Subject: Drivers: net: Hyperv
Date: Tue, 22 Apr 2014 11:22:13 -0700
Message-ID: <1398190933-8990-1-git-send-email-kys@microsoft.com>
To: davem@davemloft.net, netdev@vger.kernel.org, olaf@aepfle.de,
	jasowang@redhat.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from p3plsmtps2ded04.prod.phx3.secureserver.net ([208.109.80.198]:51339
	"EHLO p3plsmtps2ded04.prod.phx3.secureserver.net"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S933346AbaDVR0u (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 22 Apr 2014 13:26:50 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


I am trying to port the various offloads (checksum, TSO etc.) that I recently 
implemented for the Hyper-V network driver to a 2.6.32 kernel and while this
code works on the upstream bits, TCP checksum offload does not seem to work
on the 2.6.32 kernel. Would you know if there is a different way to turn on
checksum offload on 2.6.32 kernels?  I am setting the relevant feature flags:


        net->features =  NETIF_F_SG | NETIF_F_RXCSUM |
                        NETIF_F_IP_CSUM | NETIF_F_TSO;

What I am observing is that when the skb is presented to the driver for transmission,
The ip_summed field in the skb is set to 0.
On the kernel tip, I see this value set to CHECKSUM_PARTIAL and the offloads
work correctly on the kernel tip. The other difference I see is that on entry into the driver,
the eth_hdr state is not correctly set in the skb.
I need to invoke skb_reset_mac_header() to get this state correctly set.
Any help would be greatly appreciated.

Regards,

K. Y
