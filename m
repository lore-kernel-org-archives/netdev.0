From: Patrick McHardy <kaber@trash.net>
Subject: Re: [PATCH] net: Fix test for VLAN TX checksum offload capability
Date: Sat, 14 Jun 2008 10:08:52 +0200
Message-ID: <48537C94.70009@trash.net>
References: <20080613223815.GD11300@solarflare.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-15; format=flowed
Content-Transfer-Encoding: 7bit
Cc: David Miller <davem@davemloft.net>, netdev@vger.kernel.org,
	linux-net-drivers@solarflare.com
To: Ben Hutchings <bhutchings@solarflare.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from stinky.trash.net ([213.144.137.162]:64159 "EHLO
	stinky.trash.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753413AbYFNII4 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 14 Jun 2008 04:08:56 -0400
In-Reply-To: <20080613223815.GD11300@solarflare.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Ben Hutchings wrote:
> Selected device feature bits can be propagated to VLAN devices, so we
> can make use of TX checksum offload and TSO on VLAN-tagged packets.
> However, if the physical device does not do VLAN tag insertion or
> generic checksum offload then the test for TX checksum offload in
> dev_queue_xmit() will see a protocol of htons(ETH_P_8021Q) and yield
> false.
> 
> This splits the checksum offload test into two functions:
> 
> - can_checksum_protocol() tests a given protocol against a feature bitmask
> 
> - dev_can_checksum() first tests the skb protocol against the device
>   features; if that fails and the protocol is htons(ETH_P_8021Q) then
>   it tests the encapsulated protocol against the effective device
>   features for VLANs
> 
> Signed-off-by: Ben Hutchings <bhutchings@solarflare.com>

Acked-by: Patrick McHardy <kaber@trash.net>
