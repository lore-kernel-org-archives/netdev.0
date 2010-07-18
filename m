From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] vlan_dev: VLAN 0 should be treated as "no vlan tag"
 (802.1p packet)
Date: Sun, 18 Jul 2010 15:39:10 -0700 (PDT)
Message-ID: <20100718.153910.67919508.davem@davemloft.net>
References: <a372414c0d74e9ab599d095627353d94@dondevamos.com>
	<1278015554.2782.11.camel@edumazet-laptop>
	<957a5becb6e742b6dc3255b68bef3ba8@dondevamos.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, kaber@trash.net, bhutchings@solarflare.com,
	eric.dumazet@gmail.com
To: pedro.netdev@dondevamos.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:53128
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1757384Ab0GRWiy (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 18 Jul 2010 18:38:54 -0400
In-Reply-To: <957a5becb6e742b6dc3255b68bef3ba8@dondevamos.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Pedro Garcia <pedro.netdev@dondevamos.com>
Date: Sun, 18 Jul 2010 18:43:25 +0200

> - Without the 8021q module loaded in the kernel, all 802.1p packets 
> (VLAN 0 but QoS tagging) are silently discarded (as expected, as 
> the protocol is not loaded).
>  
> - Without this patch in 8021q module, these packets are forwarded to 
> the module, but they are discarded also if VLAN 0 is not configured,
> which should not be the default behaviour, as VLAN 0 is not really
> a VLANed packet but a 802.1p packet. Defining VLAN 0 makes it almost
> impossible to communicate with mixed 802.1p and non 802.1p devices on
> the same network due to arp table issues.
> 
> - Changed logic to skip vlan specific code in vlan_skb_recv if VLAN 
> is 0 and we have not defined a VLAN with ID 0, but we accept the 
> packet with the encapsulated proto and pass it later to netif_rx.
> 
> - In the vlan device event handler, added some logic to add VLAN 0 
> to HW filter in devices that support it (this prevented any traffic
> in VLAN 0 to reach the stack in e1000e with HW filter under 2.6.35,
> and probably also with other HW filtered cards, so we fix it here).
> 
> - In the vlan unregister logic, prevent the elimination of VLAN 0 
> in devices with HW filter.
> 
> - The default behaviour is to ignore the VLAN 0 tagging and accept
> the packet as if it was not tagged, but we can still define a 
> VLAN 0 if desired (so it is backwards compatible).
> 
> Signed-off-by: Pedro Garcia <pedro.netdev@dondevamos.com>

Applied, thanks Pedro.
