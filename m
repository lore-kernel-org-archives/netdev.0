From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 2/2] net: /proc/net/ip_mr_cache, display Iif as a
 signed short
Date: Wed, 03 Dec 2008 22:22:34 -0800 (PST)
Message-ID: <20081203.222234.172308424.davem@davemloft.net>
References: <20081202.150330.157587697.davem@davemloft.net>
	<49368E23.6070406@bull.net>
	<20081203143540.694846883@localhost.localdomain>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, shemminger@vyatta.com
To: benjamin.thery@bull.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:44392
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1753793AbYLDGWe (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 4 Dec 2008 01:22:34 -0500
In-Reply-To: <20081203143540.694846883@localhost.localdomain>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Benjamin Thery <benjamin.thery@bull.net>
Date: Wed, 03 Dec 2008 15:35:42 +0100

> Today, iproute2 fails to show multicast forwarding unresolved cache
> entries while scanning /proc/net/ip_mr_cache.
> 
> Indeed, it expects to see -1 in 'Iif' column to identify unresolved
> entries but the kernel outputs 65535. It's a signed/unsigned issue:
> 
> 'Iif', the source interface, is retrieved from member mfc_parent in
> struct mfc_cache. mfc_parent is a vifi_t: unsigned short, but is
> displayed in ipmr_mfc_seq_show() as "%-3d", signed integer.
> 
> In unresolevd entries, the 65535 value (0xFFFF) comes from this define:
> #define ALL_VIFS    ((vifi_t)(-1))
> 
> That may explains why the guy who added support for this in iproute2
> thought a -1 should be expected.
> 
> I don't know if this must be fixed in kernel or in iproute2. Who is
> right? What is the correct API? How was it designed originally?
> 
> I let you decide if it should goes in the kernel or be fixed in iproute2.
> 
> Signed-off-by: Benjamin Thery <benjamin.thery@bull.net>

For now I think the kernel is the best place to handle this,
thus applied to net-next-2.6

Thanks!
