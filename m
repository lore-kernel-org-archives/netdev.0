From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] net: Fix test for VLAN TX checksum offload capability
Date: Mon, 16 Jun 2008 17:02:37 -0700 (PDT)
Message-ID: <20080616.170237.112856229.davem@davemloft.net>
References: <20080613223815.GD11300@solarflare.com>
	<48537C94.70009@trash.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: bhutchings@solarflare.com, netdev@vger.kernel.org,
	linux-net-drivers@solarflare.com
To: kaber@trash.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:45248
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1752143AbYFQACh (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 16 Jun 2008 20:02:37 -0400
In-Reply-To: <48537C94.70009@trash.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Patrick McHardy <kaber@trash.net>
Date: Sat, 14 Jun 2008 10:08:52 +0200

> Ben Hutchings wrote:
> > Selected device feature bits can be propagated to VLAN devices, so we
> > can make use of TX checksum offload and TSO on VLAN-tagged packets.
> > However, if the physical device does not do VLAN tag insertion or
> > generic checksum offload then the test for TX checksum offload in
> > dev_queue_xmit() will see a protocol of htons(ETH_P_8021Q) and yield
> > false.
> > 
> > This splits the checksum offload test into two functions:
> > 
> > - can_checksum_protocol() tests a given protocol against a feature bitmask
> > 
> > - dev_can_checksum() first tests the skb protocol against the device
> >   features; if that fails and the protocol is htons(ETH_P_8021Q) then
> >   it tests the encapsulated protocol against the effective device
> >   features for VLANs
> > 
> > Signed-off-by: Ben Hutchings <bhutchings@solarflare.com>
> 
> Acked-by: Patrick McHardy <kaber@trash.net>

Applied to net-2.6, thanks everyone!
