From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next 0/3] net: vrf: Handle ipv6 multicast and
 link-local addresses
Date: Wed, 15 Jun 2016 12:34:48 -0700 (PDT)
Message-ID: <20160615.123448.416476723750890023.davem@davemloft.net>
References: <1465850659-27830-1-git-send-email-dsa@cumulusnetworks.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: dsa@cumulusnetworks.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:33488 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751867AbcFOTet (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 15 Jun 2016 15:34:49 -0400
In-Reply-To: <1465850659-27830-1-git-send-email-dsa@cumulusnetworks.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: David Ahern <dsa@cumulusnetworks.com>
Date: Mon, 13 Jun 2016 13:44:16 -0700

> IPv6 multicast and link-local addresses require special handling by the
> VRF driver. Rather than using the VRF device index and full FIB lookups,
> packets to/from these addresses should use direct FIB lookups based on
> the VRF device table.
> 
> Multicast routes do not make sense for the L3 master device directly.
> Accordingly, do not add mcast routes for the device, and the VRF driver
> should fail attempts to send packets to ipv6 mcast addresses on the
> device (e.g, ping6 ff02::1%<vrf> should fail)
> 
> With this change connections into and out of a VRF enslaved device work
> for multicast and link-local addresses (icmp, tcp, and udp).  e.g.,
> 
> 1. packets into VM with VRF config:
>     ping6 -c3 fe80::e0:f9ff:fe1c:b974%br1
>     ping6 -c3 ff02::1%br1
>     ssh -6 fe80::e0:f9ff:fe1c:b974%br1
> 
> 2. packets going out a VRF enslaved device:
>     ping6 -c3 fe80::18f8:83ff:fe4b:7a2e%eth1
>     ping6 -c3 ff02::1%eth1
>     ssh -6 root@fe80::18f8:83ff:fe4b:7a2e%eth1

Series applied.
