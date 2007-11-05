From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 1/2] NET: Re-add VLAN tag for devices incapable of
 keeping it
Date: Mon, 05 Nov 2007 15:15:44 -0800 (PST)
Message-ID: <20071105.151544.175839612.davem@davemloft.net>
References: <472A6089.7020104@hp.com>
	<18223.22291.622615.129374@zeus.sw.starentnetworks.com>
	<472F5A33.20906@trash.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: djohnson+linux-kernel@sw.starentnetworks.com,
	jes@trained-monkey.org, mchan@broadcom.com, ram.vepa@neterion.com,
	linux-kernel@vger.kernel.org, netdev@vger.kernel.org,
	bguo@sw.starentnetworks.com
To: kaber@trash.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:41737
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1754253AbXKEXPp (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 5 Nov 2007 18:15:45 -0500
In-Reply-To: <472F5A33.20906@trash.net>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Patrick McHardy <kaber@trash.net>
Date: Mon, 05 Nov 2007 19:00:19 +0100

> This looks like a rather expensive operation for the unlikely case
> that packets will be received by a packet socket. IMO it should only
> be reconstructed if actually needed, by af_packet itself.

Completely agreed.  We should not do this by default when %99
of the networking stack simply does not care about this.

> As we discussed some time back storing the VLAN tag in the CB on
> TX clashes with other users of the CB like qdiscs, so we need a
> new field in the skb for this anyway.

Someone will have to find a way to remove some other fields in
sk_buff before I'm going to allow more space to be eaten up
by this completely fringe case feature.
